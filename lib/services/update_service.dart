import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'settings_manager.dart';
import 'logger_service.dart';

/// Version metadata response from backend
class VersionMetadata {
  final String latestVersion;
  final String minSupportedVersion;
  final String downloadUrl;

  VersionMetadata({
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.downloadUrl,
  });

  factory VersionMetadata.fromJson(Map<String, dynamic> json) {
    return VersionMetadata(
      latestVersion: json['latest_version'] ?? '1.0.0',
      minSupportedVersion: json['min_supported_version'] ?? '1.0.0',
      downloadUrl: json['download_url'] ?? '',
    );
  }
}

/// Service for handling in-app updates
/// Checks for new versions from backend and manages Android flexible updates
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();

  factory UpdateService() {
    return _instance;
  }

  UpdateService._internal();

  final String _versionEndpoint = 'http://37.27.247.129/meta/version';

  /// Check if update is available and notify user
  Future<bool> checkForUpdates() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      LoggerService().logUserAction(
        'Checking for updates',
        params: {'current_version': currentVersion},
      );

      // Fetch version metadata from backend
      final versionMetadata = await _fetchVersionMetadata();
      if (versionMetadata == null) {
        LoggerService().logUserAction('Failed to fetch version metadata');
        return false;
      }

      // Save last checked time
      final settingsManager = SettingsManager();
      await settingsManager.setLastVersionCheck(DateTime.now());

      // Compare versions
      if (_isVersionGreater(
        versionMetadata.latestVersion,
        currentVersion,
      )) {
        // Update available
        await settingsManager.setUpdateAvailable(true);
        await settingsManager.setLatestVersion(versionMetadata.latestVersion);
        await settingsManager.setUpdateDownloadUrl(versionMetadata.downloadUrl);

        LoggerService().logUserAction(
          'Update available',
          params: {
            'current': currentVersion,
            'latest': versionMetadata.latestVersion,
          },
        );
        return true;
      } else {
        await settingsManager.setUpdateAvailable(false);
        LoggerService().logUserAction('App is up to date',
            params: {'version': currentVersion});
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService().logError(
        'Error checking for updates',
        e.toString(),
        stackTrace,
      );
      return false;
    }
  }

  /// Fetch version metadata from backend
  Future<VersionMetadata?> _fetchVersionMetadata() async {
    try {
      final response = await http.get(
        Uri.parse(_versionEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Version check timeout'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return VersionMetadata.fromJson(json);
      } else {
        throw Exception('Failed to fetch version: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService().logError(
          'Error fetching version metadata', e.toString(), StackTrace.current);
      return null;
    }
  }

  /// Compare version strings (e.g., "1.0.5" > "1.0.4")
  bool _isVersionGreater(String version1, String version2) {
    try {
      final v1Parts = version1.split('.').map(int.parse).toList();
      final v2Parts = version2.split('.').map(int.parse).toList();

      // Pad with zeros
      while (v1Parts.length < v2Parts.length) {
        v1Parts.add(0);
      }
      while (v2Parts.length < v1Parts.length) {
        v2Parts.add(0);
      }

      for (int i = 0; i < v1Parts.length; i++) {
        if (v1Parts[i] > v2Parts[i]) return true;
        if (v1Parts[i] < v2Parts[i]) return false;
      }
      return false;
    } catch (e) {
      LoggerService().logError(
          'Error comparing versions', e.toString(), StackTrace.current);
      return false;
    }
  }

  /// Start Android flexible update process
  /// Returns true if update was successfully started
  Future<bool> startUpdate() async {
    try {
      LoggerService().logUserAction('Starting in-app update');

      // Request flexible update
      await InAppUpdate.checkForUpdate();

      // Start flexible update
      await InAppUpdate.startFlexibleUpdate();

      LoggerService().logUserAction('Flexible update started');
      return true;
    } catch (e, stackTrace) {
      LoggerService().logError(
        'Error starting update',
        e.toString(),
        stackTrace,
      );
      return false;
    }
  }

  /// Complete flexible update (install downloaded update)
  Future<void> completeUpdate() async {
    try {
      LoggerService().logUserAction('Completing flexible update');
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e, stackTrace) {
      LoggerService().logError(
        'Error completing update',
        e.toString(),
        stackTrace,
      );
    }
  }
}
