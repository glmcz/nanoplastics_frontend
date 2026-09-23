import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/solver.dart';
import '../models/solver_idea.dart';
import '../models/idea_attachment.dart';
import '../config/backend_config.dart';
import 'http/app_http_client.dart';
import 'logger_service.dart';
import 'settings_manager.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  ApiService._internal();

  factory ApiService() => _instance;

  /// Get backend base URL from centralized config
  /// Can be overridden at build time using:
  ///   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000
  /// Or via GitHub Actions secrets at build time
  String get baseUrl => BackendConfig.getBaseUrl();

  /// Health check to verify backend connectivity
  Future<bool> healthCheck() async {
    try {
      final response = await AppHttpClient.instance.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      LoggerService().logUserAction(
        'backend_health_check_failed',
        params: {'error': e.toString()},
      );
      return false;
    }
  }

  /// Submit an idea to the backend
  /// Swapped in tests so the multipart body can be inspected. The call-site
  /// fake in ServiceLocator covers behaviour; this covers the wire format.
  @visibleForTesting
  http.Client client = AppHttpClient.instance;

  Future<Map<String, dynamic>> submitIdea({
    required String description,
    String? category,
    List<IdeaAttachment>? attachments,
    String? email,
    String? turnstileToken,
    Map<String, dynamic>? context,
    bool anonymous = false,
  }) async {
    try {
      final settings = SettingsManager();
      final userEmail = anonymous ? '' : (email ?? settings.email);
      final userNickName = anonymous ? '' : settings.displayName;

      // Create multipart request
      final uri = Uri.parse('$baseUrl/api/ideas');
      final request = http.MultipartRequest('POST', uri);
      request.fields['description'] = description;

      if (category != null && category.isNotEmpty) {
        request.fields['category'] = category;
      }

      // Why the idea exists, not only what it says. Private on the server:
      // never returned by any public ideas endpoint.
      if (context != null) {
        request.fields['context'] = jsonEncode(context);
      }

      if (userNickName.isNotEmpty) {
        request.fields['nick_name'] = userNickName;
      }

      if (userEmail.isNotEmpty) {
        request.fields['email'] = userEmail;
      }

      if (turnstileToken != null && turnstileToken.isNotEmpty) {
        request.fields['cf-turnstile-response'] = turnstileToken;
      }

      // Attach files
      for (final att in attachments ?? []) {
        if (att.bytes != null && att.bytes!.isNotEmpty) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'attachment',
              att.bytes!,
              contentType: MediaType.parse(att.mimeType),
              filename: att.name,
            ),
          );
          continue;
        }

        if (att.path.trim().isEmpty) {
          return {
            'success': false,
            'type': 'attachment',
            'message':
                'One or more attachments could not be read. Please re-attach and try again.',
          };
        }

        request.files.add(await http.MultipartFile.fromPath(
          'attachment',
          att.path,
          contentType: MediaType.parse(att.mimeType),
          filename: att.name,
        ));
      }

      LoggerService().logUserAction(
        'submitting_idea_to_backend',
        params: {
          'url': uri.toString(),
          'category': category ?? 'none',
          'description_length': description.length,
          'attachment_count': (attachments ?? []).length,
        },
      );

      if (description.length < 10 &&
          (attachments == null || attachments.isEmpty)) {
        return {
          'success': false,
          'message': 'The idea description should have at least 10 characters.',
        };
      }

      // Extended timeout to allow large file uploads (videos, audio)
      final streamedResponse = await client.send(request).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw TimeoutException('Request timeout after 45 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      LoggerService().logNetworkCall(
        '/api/ideas',
        method: 'POST',
        statusCode: response.statusCode,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Validate body is real server response, not a proxy/captive portal page
        Map<String, dynamic>? parsedBody;
        try {
          parsedBody = json.decode(response.body) as Map<String, dynamic>?;
        } catch (_) {}

        if (parsedBody == null || !parsedBody.containsKey('id')) {
          LoggerService().logError(
            'idea_submission_fake_success',
            'Got ${response.statusCode} but body missing id field. Likely proxy intercept. Body: ${response.body.substring(0, response.body.length.clamp(0, 200))}',
          );
          return {
            'success': false,
            'type': 'connection',
            'message':
                'Server is temporarily unavailable. Please try again later.',
            'error': 'Invalid response body',
          };
        }

        LoggerService().logUserAction(
          'idea_submitted_successfully',
          params: {
            'category': category ?? 'none',
            'description_length': description.length,
          },
        );
        return {
          'success': true,
          'message': 'Idea submitted successfully',
          'response_body': response.body,
        };
      } else if (response.statusCode == 502 || response.statusCode == 503) {
        LoggerService().logError(
          'idea_submission_backend_down',
          'Backend unreachable via proxy: ${response.statusCode}: ${response.body}',
        );
        return {
          'success': false,
          'type': 'connection',
          'message':
              'Server is temporarily unavailable. Please try again later.',
          'error': response.body,
        };
      } else {
        LoggerService().logError(
          'idea_submission_failed',
          'Remote server is not available. Getting: ${response.statusCode}: ${response.body}',
        );
        return {
          'success': false,
          'message': 'Failed to submit idea: HTTP ${response.statusCode}',
          'error': response.body,
        };
      }
    } on SocketException catch (e, stackTrace) {
      LoggerService().logError('idea_submission_no_connection', e, stackTrace);
      return {
        'success': false,
        'type': 'connection',
        'message': 'Server is unreachable. Check your internet connection.',
        'error': e.toString(),
      };
    } on TimeoutException catch (e, stackTrace) {
      LoggerService().logError('idea_submission_timeout', e, stackTrace);
      return {
        'success': false,
        'type': 'timeout',
        'message': 'Server is not responding. Please try again later.',
        'error': e.toString(),
      };
    } catch (e, stackTrace) {
      LoggerService().logError(
        'idea_submission_exception',
        e,
        stackTrace,
      );
      return {
        'success': false,
        'type': 'unknown',
        'message': 'Error submitting idea: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Fetch top solvers from backend API
  Future<List<Solver>> getTopSolvers() async {
    try {
      final response = await AppHttpClient.instance.get(
        Uri.parse('$baseUrl/api/solvers'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final solvers = data['solvers'] as List<dynamic>;

        return solvers
            .map((solverData) => Solver(
                  rank: solverData['rank'] as int,
                  name: solverData['name'] as String,
                  solutionsCount: solverData['contributions'] as int,
                  totalScore: (solverData['total_score'] as num?)?.toInt() ?? 0,
                  rating: (solverData['rating'] as num).toDouble(),
                  specialty: solverData['specialty'] as String? ?? 'General',
                  category: solverData['specialty'] as String?,
                  isRegistered: solverData['is_registered'] as bool,
                  hasAbstract: solverData['has_abstract'] as bool? ?? false,
                ))
            .toList();
      } else {
        LoggerService()
            .logError('Failed to load solvers: ${response.statusCode}', '');
        return [];
      }
    } on SocketException {
      // Expected: device has no internet — not a bug, skip Crashlytics
      LoggerService()
          .logNetworkCall('/api/solvers', method: 'GET', statusCode: 0);
      return [];
    } on TimeoutException {
      // Expected: slow network — not a bug, skip Crashlytics
      LoggerService()
          .logNetworkCall('/api/solvers', method: 'GET', statusCode: 408);
      return [];
    } catch (e, stackTrace) {
      LoggerService().logError('Failed to fetch solvers', e, stackTrace);
      return [];
    }
  }

  /// Fetch ideas with abstracts for a specific solver
  Future<List<SolverIdea>> getSolverIdeas(String solverName) async {
    try {
      final encodedName = Uri.encodeComponent(solverName);
      final response = await AppHttpClient.instance.get(
        Uri.parse('$baseUrl/api/solvers/$encodedName/ideas'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final ideas = data['ideas'] as List<dynamic>;
        return ideas
            .map((e) => SolverIdea.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        LoggerService().logError(
            'Failed to load solver ideas: ${response.statusCode}', '');
        return [];
      }
    } on SocketException {
      LoggerService().logNetworkCall('/api/solvers/.../ideas',
          method: 'GET', statusCode: 0);
      return [];
    } on TimeoutException {
      LoggerService().logNetworkCall('/api/solvers/.../ideas',
          method: 'GET', statusCode: 408);
      return [];
    } catch (e, stackTrace) {
      LoggerService().logError('Failed to fetch solver ideas', e, stackTrace);
      return [];
    }
  }
}
