import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'settings_manager.dart';
import 'logger_service.dart';

/// GitHub release metadata from GitHub API
class GitHubRelease {
  final String tagName;
  final String name;
  final bool isPrerelease;
  final DateTime publishedAt;
  final String? fullBuildUrl;
  final String? liteBuildUrl;

  GitHubRelease({
    required this.tagName,
    required this.name,
    required this.isPrerelease,
    required this.publishedAt,
    this.fullBuildUrl,
    this.liteBuildUrl,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    final assets = (json['assets'] as List<dynamic>?) ?? [];
    String? fullUrl;
    String? liteUrl;

    for (final asset in assets) {
      final assetName = asset['name'] ?? '';
      if (assetName == 'nanoplastics_app.apk') {
        fullUrl = asset['browser_download_url'];
      } else if (assetName == 'nanoplastics_app_lite.apk') {
        liteUrl = asset['browser_download_url'];
      }
    }

    return GitHubRelease(
      tagName: json['tag_name'] ?? 'unknown',
      name: json['name'] ?? 'Release',
      isPrerelease: json['prerelease'] ?? false,
      publishedAt:
          DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      fullBuildUrl: fullUrl,
      liteBuildUrl: liteUrl,
    );
  }
}

/// Service for handling in-app updates
/// Checks for new versions from GitHub releases and manages Android flexible updates
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();

  factory UpdateService() {
    return _instance;
  }

  UpdateService._internal();

  static const String _githubApiUrl =
      'https://api.github.com/repos/glmcz/nanoplastics_frontend/releases/latest';
  static const Duration _checkInterval = Duration(hours: 12); // 2x per day

  /// Check if update is available based on GitHub release tag
  /// Returns true only if a new release tag is detected (not already saved)
  Future<bool> checkForUpdates() async {
    try {
      final settingsManager = SettingsManager();

      // Check if enough time has passed since last check (12 hour interval = 2x per day)
      final lastCheck = settingsManager.lastUpdateCheckTime;
      if (lastCheck != null) {
        final timeSinceLastCheck = DateTime.now().difference(lastCheck);
        if (timeSinceLastCheck < _checkInterval) {
          LoggerService().logUserAction(
            'Skipping update check - checked recently',
            params: {'minutes_ago': (timeSinceLastCheck.inMinutes)},
          );
          return false; // Don't check again yet
        }
      }

      // Fetch latest release from GitHub
      final release = await _fetchLatestRelease();
      if (release == null) {
        LoggerService().logUserAction('Failed to fetch GitHub release');
        await settingsManager.setLastUpdateCheckTime(DateTime.now());
        return false;
      }

      // Update check timestamp
      await settingsManager.setLastUpdateCheckTime(DateTime.now());

      // Get previously saved tag ID
      final savedTagId = settingsManager.lastReleaseTagId;
      final currentTagId = release.tagName;

      // If tag is different (new release), update is available
      if (savedTagId != currentTagId) {
        // Get appropriate download URL based on build type
        final buildType = settingsManager.buildType;
        String? downloadUrl;

        if (buildType.toLowerCase() == 'full') {
          downloadUrl = release.fullBuildUrl;
        } else {
          downloadUrl = release.liteBuildUrl;
        }

        if (downloadUrl == null) {
          LoggerService().logUserAction('APK URL not found in GitHub release',
              params: {'build_type': buildType});
          return false;
        }

        // Save new tag ID and update info
        await settingsManager.setLastReleaseTagId(currentTagId);
        await settingsManager.setUpdateAvailable(true);
        await settingsManager.setLatestVersion(currentTagId);
        await settingsManager.setUpdateDownloadUrl(downloadUrl);

        LoggerService().logUserAction(
          'New release detected',
          params: {
            'tag': currentTagId,
            'build_type': buildType,
            'url': downloadUrl,
          },
        );
        return true; // New release available
      } else {
        // Same tag - no new update
        await settingsManager.setUpdateAvailable(false);
        LoggerService()
            .logUserAction('App is up to date', params: {'tag': currentTagId});
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

  /// Fetch latest release from GitHub API
  Future<GitHubRelease?> _fetchLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(_githubApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.github.v3+json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('GitHub API timeout'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GitHubRelease.fromJson(json);
      } else {
        throw Exception(
            'Failed to fetch GitHub release: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService().logError(
          'Error fetching GitHub release', e.toString(), StackTrace.current);
      return null;
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
