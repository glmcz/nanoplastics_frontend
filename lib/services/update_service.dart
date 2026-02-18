import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'logger_service.dart';
import 'service_locator.dart';

/// Enum representing the different states of the app update process
enum UpdateState {
  idle,
  checking,
  available,
  downloading,
  downloaded,
  installing,
  installed,
  failed,
}

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
/// Provides state tracking and progress monitoring for update process
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();

  factory UpdateService() {
    return _instance;
  }

  UpdateService._internal();

  static const String _githubApiUrl =
      'https://api.github.com/repos/glmcz/nanoplastics_frontend/releases/latest';
  static const Duration _checkInterval = Duration(hours: 12); // 2x per day

  // State and progress tracking
  UpdateState _currentState = UpdateState.idle;
  double _downloadProgress = 0.0;
  final List<Function(UpdateState, double)> _stateListeners = [];

  /// Get current update state
  UpdateState get currentState => _currentState;

  /// Get current download progress (0.0 to 1.0)
  double get downloadProgress => _downloadProgress;

  /// Subscribe to state changes
  /// Callback receives (state, progress) tuple
  void addStateListener(Function(UpdateState, double) callback) {
    _stateListeners.add(callback);
    // Immediately notify with current state
    callback(_currentState, _downloadProgress);
  }

  /// Unsubscribe from state changes
  void removeStateListener(Function(UpdateState, double) callback) {
    _stateListeners.remove(callback);
  }

  /// Notify all listeners of state change
  void _notifyStateChange(UpdateState newState, {double? progress}) {
    _currentState = newState;
    if (progress != null) {
      _downloadProgress = progress.clamp(0.0, 1.0);
    }
    for (final listener in _stateListeners) {
      listener(_currentState, _downloadProgress);
    }
  }

  /// Check if update is available based on GitHub release tag
  /// Returns true only if a new release is newer than the installed app version
  /// Notifies listeners of state changes during check
  /// Returns false if no internet connection (offline mode)
  Future<bool> checkForUpdates({bool force = false}) async {
    final internetService = ServiceLocator().internetService;

    // Check internet first - skip if offline
    if (!internetService.isOnline) {
      LoggerService().logUserAction(
        'Update check skipped - no internet',
        params: {
          'internet_state': internetService.currentState.toString(),
        },
      );
      _notifyStateChange(UpdateState.failed);
      return false; // Offline - can't check
    }

    _notifyStateChange(UpdateState.checking);
    try {
      final settingsManager = ServiceLocator().settingsManager;

      // Check if enough time has passed since last check (12 hour interval = 2x per day)
      if (!force) {
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

      // Get installed app version (fallback to last known tag if needed)
      final installedVersion = await _getInstalledVersion();
      final savedTagId = settingsManager.lastReleaseTagId;
      final currentTagId = release.tagName;

      // If installed version is known, only update when release is newer
      if (installedVersion != null) {
        if (!isNewerVersion(currentTagId, installedVersion)) {
          await settingsManager.setLastReleaseTagId(currentTagId);
          await settingsManager.setUpdateAvailable(false);
          LoggerService().logUserAction(
            'App is up to date',
            params: {'tag': currentTagId, 'installed': installedVersion},
          );
          _notifyStateChange(UpdateState.idle);
          return false;
        }
      } else if (savedTagId != null) {
        if (!isNewerVersion(currentTagId, savedTagId)) {
          await settingsManager.setUpdateAvailable(false);
          LoggerService().logUserAction(
            'App is up to date',
            params: {'tag': currentTagId},
          );
          _notifyStateChange(UpdateState.idle);
          return false;
        }
      } else {
        // No installed version and no saved tag: avoid false positive
        await settingsManager.setLastReleaseTagId(currentTagId);
        await settingsManager.setUpdateAvailable(false);
        LoggerService().logUserAction(
          'Update check skipped - no local version baseline',
          params: {'tag': currentTagId},
        );
        _notifyStateChange(UpdateState.idle);
        return false;
      }

      // If tag is different (new release), update is available
      // Use semantic version comparison to handle version numbering correctly
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
      _notifyStateChange(UpdateState.available);
      return true; // New release available
    } catch (e, stackTrace) {
      LoggerService().logError(
        'Error checking for updates',
        e.toString(),
        stackTrace,
      );
      _notifyStateChange(UpdateState.failed);
      return false;
    }
  }

  /// Get installed app version string (e.g., "1.2.3")
  Future<String?> _getInstalledVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (e) {
      LoggerService().logError(
        'Error reading installed app version',
        e.toString(),
        StackTrace.current,
      );
      return null;
    }
  }

  /// Compare two semantic version strings
  /// Returns true if newVersion > currentVersion
  /// Handles tags like "v1.2.3", "1.2.3", or "release-1.2.3"
  bool isNewerVersion(String newVersion, String currentVersion) {
    try {
      // Strip common prefixes: "v", "release-", etc but keep the version number
      final newClean = newVersion
          .replaceFirst(RegExp(r'^v'), '') // Remove leading 'v'
          .replaceFirst(RegExp(r'^release-'), ''); // Remove 'release-' prefix
      final currentClean = currentVersion
          .replaceFirst(RegExp(r'^v'), '')
          .replaceFirst(RegExp(r'^release-'), '');

      // Extract only the numeric parts (major.minor.patch...) and ignore suffixes
      final newMatch = RegExp(r'^(\d+(?:\.\d+)*)').firstMatch(newClean);
      final currentMatch = RegExp(r'^(\d+(?:\.\d+)*)').firstMatch(currentClean);

      final newVersionStr = newMatch?.group(1) ?? '0';
      final currentVersionStr = currentMatch?.group(1) ?? '0';

      final newParts =
          newVersionStr.split('.').map((p) => int.tryParse(p) ?? 0).toList();
      final currentParts = currentVersionStr
          .split('.')
          .map((p) => int.tryParse(p) ?? 0)
          .toList();

      // Pad to same length
      while (newParts.length < currentParts.length) newParts.add(0);
      while (currentParts.length < newParts.length) currentParts.add(0);

      // Compare major.minor.patch...
      for (int i = 0; i < newParts.length; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }
      return false; // Same version
    } catch (e) {
      LoggerService().logError(
        'Version comparison error',
        'new: $newVersion, current: $currentVersion',
        StackTrace.current,
      );
      return false; // Default to no update on error
    }
  }

  /// Setup listener for Android flexible update completion
  /// Monitors InAppUpdate events and updates state when download completes
  void _setupAndroidUpdateListener() {
    // TODO: InAppUpdate plugin doesn't provide built-in listener for flexible updates
    // This would require either:
    // 1. Periodic polling of InAppUpdate.completeFlexibleUpdate()
    // 2. Platform channel communication from native Android code
    // For now, state changes must be driven by UI layer (e.g., retry button detecting completion)
    LoggerService().logDebug(
      'update_listener',
      'Android update listener setup - monitoring for download completion',
    );
  }

  /// Fetch latest release from GitHub API (single attempt)
  /// User must manually retry if network fails
  /// Prevents hidden auto-retry that confuses users
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

  /// Start update process (GitHub APK download in custom tab)
  /// Returns true if update was successfully started, false if offline or error
  /// Notifies listeners of state changes during download and installation
  Future<bool> startUpdate() async {
    final internetService = ServiceLocator().internetService;
    final settingsManager = ServiceLocator().settingsManager;
    final updateDownloadUrl = settingsManager.updateDownloadUrl;

    // Check internet first - prevent starting if offline
    if (!internetService.isOnline) {
      LoggerService().logUserAction(
        'Update start blocked - no internet',
        params: {
          'internet_state': internetService.currentState.toString(),
        },
      );
      _notifyStateChange(UpdateState.failed);
      return false; // Offline - can't download
    }

    if (updateDownloadUrl == null) {
      LoggerService().logUserAction(
        'Update start blocked - missing download URL',
      );
      _notifyStateChange(UpdateState.failed);
      return false;
    }

    try {
      LoggerService().logUserAction('Starting in-app update');

      if (Platform.isAndroid) {
        _notifyStateChange(UpdateState.downloading);
        final updateUri = Uri.parse(updateDownloadUrl);
        var launched = false;

        try {
          final options = custom_tabs.CustomTabsOptions(
            shareState: custom_tabs.CustomTabsShareState.off,
            urlBarHidingEnabled: true,
            showTitle: true,
            browser: const custom_tabs.CustomTabsBrowserConfiguration(
              fallbackCustomTabs: [
                'com.android.chrome',
                'com.chrome.beta',
                'com.chrome.dev',
              ],
            ),
          );

          await custom_tabs.launchUrl(
            updateUri,
            customTabsOptions: options,
            safariVCOptions: const custom_tabs.SafariViewControllerOptions(
              barCollapsingEnabled: true,
              dismissButtonStyle:
                  custom_tabs.SafariViewControllerDismissButtonStyle.close,
            ),
          );
          launched = true;
          LoggerService()
              .logUserAction('Android update URL launched in custom tab');
        } catch (e) {
          LoggerService().logUserAction(
            'Custom tabs launch failed, falling back to browser',
            params: {'error': e.toString()},
          );
        }

        if (!launched) {
          final fallbackLaunched = await launchUrl(
            updateUri,
            mode: LaunchMode.externalApplication,
          );

          if (!fallbackLaunched) {
            LoggerService().logUserAction('Android update URL launch failed');
            _notifyStateChange(UpdateState.failed);
            return false;
          }
        }

        LoggerService().logUserAction('Android update download started');
        _notifyStateChange(UpdateState.downloaded);
      } else if (Platform.isIOS) {
        // iOS: Redirect to App Store
        // Note: Actual implementation requires URL_LAUNCHER package
        // TODO: Implement iOS App Store redirect
        LoggerService()
            .logUserAction('iOS update redirect not yet implemented');
        _notifyStateChange(UpdateState.failed);
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      LoggerService().logError(
        'Error starting update',
        e.toString(),
        stackTrace,
      );
      _notifyStateChange(UpdateState.failed);
      return false;
    }
  }

  /// Complete flexible update (install downloaded update)
  /// Transitions state to installing then installed
  Future<void> completeUpdate() async {
    try {
      LoggerService().logUserAction('Completing flexible update');
      _notifyStateChange(UpdateState.installing);
      await InAppUpdate.completeFlexibleUpdate();
      _notifyStateChange(UpdateState.installed);
    } catch (e, stackTrace) {
      LoggerService().logError(
        'Error completing update',
        e.toString(),
        stackTrace,
      );
      _notifyStateChange(UpdateState.failed);
    }
  }

  /// Check if update download has completed
  /// Should be called periodically or triggered by UI when user retries
  /// Returns true if update is ready to install
  Future<bool> isUpdateDownloadComplete() async {
    try {
      if (!Platform.isAndroid) return false;

      // InAppUpdate doesn't directly expose download status
      // Try calling completeFlexibleUpdate - if it succeeds, update is ready
      // If it fails, download is still in progress
      await InAppUpdate.completeFlexibleUpdate();
      _notifyStateChange(UpdateState.downloaded);
      return true;
    } catch (e) {
      // Download still in progress
      return false;
    }
  }
}
