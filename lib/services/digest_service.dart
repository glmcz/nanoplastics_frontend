import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/digest_paper.dart';
import 'api_service.dart';
import 'encryption_service.dart';
import 'http/app_http_client.dart';
import 'logger_service.dart';
import 'settings_manager.dart';

enum CodeRequestResult { sent, invalidEmail, tooSoon, failed }

enum SignInResult { signedIn, wrongCode, locked, failed }

/// The research digest and the Vault, both kept on the server per user.
///
/// The server knows a user by a token bought with an emailed code (backend
/// `digest/auth.rs`). Until the user confirms their email the token is
/// missing, and the screens that need the server ask for the code first.
/// Requests still carry `email`, which only a server from before sign-in reads.
class DigestService {
  static final DigestService _instance = DigestService._internal();
  DigestService._internal();

  static DigestService? _testOverride;

  factory DigestService() => _testOverride ?? _instance;

  @visibleForTesting
  static void overrideForTesting(DigestService? svc) => _testOverride = svc;

  final _api = ApiService();
  final _settings = SettingsManager();

  // In-memory tresor cache — populated on syncUser(), updated on add/remove
  final Set<String> _tresorIds = {};
  Set<String> get tresorIds => Set.unmodifiable(_tresorIds);

  // ── Account ──────────────────────────────────────────────────────────────────

  static const _accountKey = 'hive_account';

  /// The token and the address it was issued for. A token for another address
  /// than the profile's no longer counts: the user changed their email.
  ({String email, String token})? _account;
  Future<void>? _accountLoad;

  /// The token push registration was waiting on, sent once the user signs in.
  String? _pendingFcmToken;

  static String _normalize(String email) => email.trim().toLowerCase();

  Future<void> _loadAccount() => _accountLoad ??= () async {
        final raw = await EncryptionService.secureRead(_accountKey);
        if (raw == null) return;
        try {
          final json = jsonDecode(raw) as Map<String, dynamic>;
          _account = (
            email: json['email'] as String,
            token: json['token'] as String,
          );
        } catch (_) {
          await EncryptionService.secureDelete(_accountKey);
        }
      }();

  /// Whether the user has confirmed the email in their profile.
  Future<bool> isSignedIn() async {
    await _loadAccount();
    final a = _account;
    return a != null &&
        _settings.email.isNotEmpty &&
        a.email == _normalize(_settings.email);
  }

  Future<String?> _token() async => await isSignedIn() ? _account!.token : null;

  Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await _token();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// A 401 means the token was revoked or the account deleted elsewhere.
  Future<void> _onStatus(int status) async {
    if (status == 401) await _forgetAccount();
  }

  Future<void> _forgetAccount() async {
    _account = null;
    _tresorIds.clear();
    await EncryptionService.secureDelete(_accountKey);
  }

  Future<CodeRequestResult> requestCode(String email) async {
    try {
      final resp = await AppHttpClient.instance
          .post(
            Uri.parse('${_api.baseUrl}/api/users/auth/request-code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim()}),
          )
          .timeout(const Duration(seconds: 15));
      return switch (resp.statusCode) {
        202 => CodeRequestResult.sent,
        400 => CodeRequestResult.invalidEmail,
        429 => CodeRequestResult.tooSoon,
        _ => CodeRequestResult.failed,
      };
    } catch (e, st) {
      LoggerService().logError('requestCode', e, st);
      return CodeRequestResult.failed;
    }
  }

  /// Checks the emailed code. On success the token is stored and the profile
  /// takes the confirmed address.
  Future<SignInResult> verifyCode(String email, String code) async {
    try {
      final resp = await AppHttpClient.instance
          .post(
            Uri.parse('${_api.baseUrl}/api/users/auth/verify-code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'code': code.trim(),
              if (_settings.displayName.isNotEmpty)
                'display_name': _settings.displayName,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode == 401) return SignInResult.wrongCode;
      if (resp.statusCode == 429) return SignInResult.locked;
      if (resp.statusCode != 200) return SignInResult.failed;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final confirmed = _normalize(json['email'] as String);
      _account = (email: confirmed, token: json['token'] as String);
      await EncryptionService.secureWrite(_accountKey,
          jsonEncode({'email': confirmed, 'token': _account!.token}));
      if (_normalize(_settings.email) != confirmed) {
        await _settings.setEmail(confirmed);
      }
      final pending = _pendingFcmToken;
      if (pending != null) await updateFcmToken(pending);
      await syncUser();
      return SignInResult.signedIn;
    } catch (e, st) {
      LoggerService().logError('verifyCode', e, st);
      return SignInResult.failed;
    }
  }

  /// Erases the account on the server: profile, digest settings, push token
  /// and Vault. Ideas stay, without the name and email.
  Future<bool> deleteAccount() async {
    final headers = await _headers();
    if (!headers.containsKey('Authorization')) return false;
    try {
      final resp = await AppHttpClient.instance
          .delete(Uri.parse('${_api.baseUrl}/api/users/me'), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode == 204) {
        await _forgetAccount();
        return true;
      }
      return false;
    } catch (e, st) {
      LoggerService().logError('deleteAccount', e, st);
      return false;
    }
  }

  // ── User sync ────────────────────────────────────────────────────────────────

  /// Called fire-and-forget on app start, and after sign-in. Reads the
  /// keywords and warms the tresor cache.
  Future<void> syncUser() async {
    if (!await isSignedIn()) return;
    final email = _settings.email;

    try {
      final meResp = await AppHttpClient.instance
          .get(
            Uri.parse(
                '${_api.baseUrl}/api/users/me?email=${Uri.encodeComponent(email)}'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 8));
      await _onStatus(meResp.statusCode);
      if (meResp.statusCode == 200) _syncKeywordsFromJson(meResp.body);

      final ids = await getTresorIds();
      _tresorIds
        ..clear()
        ..addAll(ids);
    } catch (e) {
      LoggerService()
          .logUserAction('digest_sync_failed', params: {'error': e.toString()});
    }
  }

  void _syncKeywordsFromJson(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final kws = (json['search_keywords'] as List<dynamic>?)?.cast<String>();
      if (kws != null) {
        _settings.setDigestKeywords(kws);
      }
    } catch (_) {}
  }

  // ── Papers ───────────────────────────────────────────────────────────────────

  /// Recent papers about micro- and nanoplastics, newest first. Public: no
  /// account needed. The on-device vault tests pick their papers from here.
  Future<List<DigestPaper>> fetchLatest({
    DateTime? since,
    List<String>? keywords,
  }) async {
    final sinceDate = since ?? DateTime.now().subtract(const Duration(days: 7));
    final dateStr =
        '${sinceDate.year}-${sinceDate.month.toString().padLeft(2, '0')}-${sinceDate.day.toString().padLeft(2, '0')}';

    var url = '${_api.baseUrl}/api/digest/latest?since=$dateStr';
    if (keywords != null && keywords.isNotEmpty) {
      url += '&keywords=${Uri.encodeComponent(keywords.join(','))}';
    }

    final resp = await AppHttpClient.instance
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) return [];

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = json['papers'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(DigestPaper.fromJson)
        .toList();
  }

  Future<DigestPaper?> fetchPaperById(String paperId) async {
    try {
      final resp = await AppHttpClient.instance
          .get(Uri.parse('${_api.baseUrl}/api/digest/paper/$paperId'))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) {
        LoggerService()
            .logError('fetchPaperById', 'HTTP ${resp.statusCode}', null);
        return null;
      }
      return DigestPaper.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>);
    } catch (e, st) {
      LoggerService().logError('fetchPaperById', e, st);
      return null;
    }
  }

  // ── Preferences ──────────────────────────────────────────────────────────────

  Future<bool> updatePreferences({
    bool? enabled,
    int? digestHour,
    bool? emailEnabled,
    bool? monthlyEnabled,
    List<String>? keywords,
  }) async {
    final email = _settings.email;
    if (email.isEmpty) {
      LoggerService()
          .logError('updatePreferences', 'email empty, skipping PUT');
      return false;
    }

    try {
      final body = <String, dynamic>{'email': email};
      if (enabled != null) body['daily_digest_enabled'] = enabled;
      if (digestHour != null) {
        body['digest_hour'] = digestHour;
      }
      if (emailEnabled != null) body['email_digest_enabled'] = emailEnabled;
      if (monthlyEnabled != null) {
        body['monthly_summary_enabled'] = monthlyEnabled;
      }
      // digest_hour is read on this clock, so it travels with every save.
      final timezone = await _localTimezone();
      if (timezone != null) body['timezone'] = timezone;
      if (keywords != null) body['search_keywords'] = keywords;

      final url = '${_api.baseUrl}/api/users/preferences';
      final resp = await AppHttpClient.instance
          .put(
            Uri.parse(url),
            headers: await _headers(json: true),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      LoggerService()
          .logNetworkCall(url, method: 'PUT', statusCode: resp.statusCode);
      await _onStatus(resp.statusCode);
      if (resp.statusCode != 200) {
        LoggerService().logError(
            'updatePreferences', 'status ${resp.statusCode}: ${resp.body}');
      }

      if (resp.statusCode == 200 && keywords != null) {
        _settings.setDigestKeywords(keywords);
      }

      return resp.statusCode == 200;
    } catch (e, st) {
      LoggerService().logError('updatePreferences', e, st);
      return false;
    }
  }

  /// The device's IANA zone, e.g. "Europe/Prague"; null if the platform won't say.
  Future<String?> _localTimezone() async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (e, st) {
      LoggerService().logError('localTimezone', e, st);
      return null;
    }
  }

  List<String> getKeywords() {
    return _settings.digestKeywords;
  }

  /// Fetches the user's current digest preferences from the server, or
  /// null if the user doesn't exist yet / the request fails.
  Future<
      ({
        bool enabled,
        int digestHour,
        bool emailEnabled,
        bool monthlyEnabled
      })?> fetchPreferences() async {
    final email = _settings.email;
    if (email.isEmpty) return null;

    try {
      final resp = await AppHttpClient.instance
          .get(
            Uri.parse(
                '${_api.baseUrl}/api/users/me?email=${Uri.encodeComponent(email)}'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 8));
      await _onStatus(resp.statusCode);
      if (resp.statusCode != 200) return null;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return (
        enabled: json['daily_digest_enabled'] as bool? ?? false,
        digestHour: json['digest_hour'] as int? ?? 9,
        emailEnabled: json['email_digest_enabled'] as bool? ?? false,
        monthlyEnabled: json['monthly_summary_enabled'] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Tresor ───────────────────────────────────────────────────────────────────

  Uri _userUri(String path) => Uri.parse(
      '${_api.baseUrl}$path?email=${Uri.encodeComponent(_settings.email)}');

  Future<List<String>> getTresorIds() async {
    if (_settings.email.isEmpty) return [];

    try {
      final resp = await AppHttpClient.instance
          .get(_userUri('/api/users/tresor'), headers: await _headers())
          .timeout(const Duration(seconds: 10));
      await _onStatus(resp.statusCode);
      if (resp.statusCode != 200) return [];
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return ((json['paper_ids'] as List<dynamic>?) ?? []).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<bool> addToTresor(String paperId) async {
    final email = _settings.email;
    if (email.isEmpty) return false;

    try {
      final resp = await AppHttpClient.instance
          .post(
            Uri.parse('${_api.baseUrl}/api/users/tresor'),
            headers: await _headers(json: true),
            body: jsonEncode({'email': email, 'paper_id': paperId}),
          )
          .timeout(const Duration(seconds: 8));
      await _onStatus(resp.statusCode);

      if (resp.statusCode == 201) {
        _tresorIds.add(paperId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeFromTresor(String paperId) async {
    if (_settings.email.isEmpty) return false;

    try {
      final resp = await AppHttpClient.instance
          .delete(_userUri('/api/users/tresor/$paperId'),
              headers: await _headers())
          .timeout(const Duration(seconds: 8));
      await _onStatus(resp.statusCode);

      if (resp.statusCode == 204) {
        _tresorIds.remove(paperId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Registers this device for the push. Before sign-in the server would not
  /// know whose device it is, so the token waits for [verifyCode].
  Future<void> updateFcmToken(String token) async {
    final email = _settings.email;
    if (email.isEmpty || !await isSignedIn()) {
      _pendingFcmToken = token;
      return;
    }

    try {
      final resp = await AppHttpClient.instance
          .put(
            Uri.parse('${_api.baseUrl}/api/users/fcm-token'),
            headers: await _headers(json: true),
            body: jsonEncode({'email': email, 'token': token}),
          )
          .timeout(const Duration(seconds: 8));
      await _onStatus(resp.statusCode);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        LoggerService().logError(
            'updateFcmToken', 'HTTP ${resp.statusCode}: ${resp.body}', null);
      } else {
        _pendingFcmToken = null;
      }
    } catch (e, st) {
      // Silence here meant a device that could never be pushed to, with nothing
      // anywhere to say so.
      LoggerService().logError('updateFcmToken', e, st);
    }
  }

  Future<List<DigestPaper>> fetchSavedPapers() async {
    if (_settings.email.isEmpty) return [];

    try {
      final resp = await AppHttpClient.instance
          .get(_userUri('/api/users/tresor/papers'), headers: await _headers())
          .timeout(const Duration(seconds: 15));
      await _onStatus(resp.statusCode);

      if (resp.statusCode != 200) return [];
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = json['papers'] as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(DigestPaper.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> exportTresor() async {
    if (_settings.email.isEmpty) return null;

    try {
      final resp = await AppHttpClient.instance
          .get(_userUri('/api/users/tresor/export'), headers: await _headers())
          .timeout(const Duration(seconds: 15));
      await _onStatus(resp.statusCode);

      return resp.statusCode == 200 ? resp.body : null;
    } catch (_) {
      return null;
    }
  }
}
