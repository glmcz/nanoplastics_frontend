import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'settings_manager.dart';
import 'pdf_service.dart';
import 'logger_service.dart';
import 'update_service.dart';

/// Enum representing internet connectivity states
enum InternetState {
  connected, // Has internet connection
  disconnected, // No internet connection
  unknown, // Status unknown (initial state)
}

/// Service managing internet connectivity state
/// Provides unified offline/online state for all internet-dependent services
class InternetService {
  final Connectivity _connectivity = Connectivity();
  InternetState _currentState = InternetState.unknown;
  final List<Function(InternetState)> _stateListeners = [];

  InternetService._();

  /// Get current internet state
  InternetState get currentState => _currentState;

  /// Check if device has internet connection
  bool get isOnline => _currentState == InternetState.connected;

  /// Initialize connectivity monitoring
  /// Should be called once during app startup
  Future<void> initialize() async {
    try {
      // Check initial state
      final result = await _connectivity.checkConnectivity();
      _updateFromResult(result);

      // Listen for connectivity changes
      _connectivity.onConnectivityChanged.listen((results) {
        if (results.isNotEmpty) {
          _updateFromResult(results);
        }
      });

      LoggerService().logDebug(
        'internet_service_init',
        'Internet connectivity monitoring initialized',
      );
    } catch (e) {
      LoggerService().logError(
        'internet_service_init_failed',
        'Failed to initialize connectivity: $e',
      );
      _currentState = InternetState.unknown;
    }
  }

  /// Update state based on connectivity result(s)
  void _updateFromResult(dynamic result) {
    late List<ConnectivityResult> results;

    // Handle both single result and list of results
    if (result is List<ConnectivityResult>) {
      results = result;
    } else if (result is ConnectivityResult) {
      results = [result];
    } else {
      _currentState = InternetState.unknown;
      return;
    }

    // Check if any result indicates connection
    final isConnected = results.any((r) =>
        r != ConnectivityResult.none &&
        r != ConnectivityResult.bluetooth); // bluetooth added in newer versions

    final newState =
        isConnected ? InternetState.connected : InternetState.disconnected;

    if (_currentState != newState) {
      _currentState = newState;
      LoggerService().logUserAction(
        'Internet state changed',
        params: {'state': newState.toString()},
      );
      for (final listener in _stateListeners) {
        listener(_currentState);
      }
    }
  }

  /// Subscribe to internet state changes
  void addStateListener(Function(InternetState) callback) {
    _stateListeners.add(callback);
    callback(_currentState); // Notify immediately with current state
  }

  /// Unsubscribe from internet state changes
  void removeStateListener(Function(InternetState) callback) {
    _stateListeners.remove(callback);
  }

  /// Get user-friendly error message for offline state
  String getErrorMessage(String serviceName) {
    if (!isOnline) {
      return 'Cannot access "$serviceName" without internet. '
          'Please connect to WiFi or mobile data and try again.';
    }
    return 'Service "$serviceName" requires internet connection.';
  }
}

/// Global service locator for dependency injection
/// Ensures single instances of services are used throughout the app
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  late SettingsManager _settingsManager;
  late LoggerService _loggerService;
  late PdfService _pdfService;
  late UpdateService _updateService;
  late InternetService _internetService;

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  /// Initialize all services (call from main.dart after SettingsManager.init())
  /// Initialization order matters:
  /// 1. InternetService - needed for online/offline checks
  /// 2. LoggerService - needed for logging during init
  /// 3. SettingsManager - already initialized before this
  /// 4. PdfService - extracts bundled PDFs
  /// 5. UpdateService - checks for updates (requires internet service)
  Future<void> initialize() async {
    // Initialize internet service FIRST (before other services)
    _internetService = InternetService._();
    await _internetService.initialize();

    // Get already-initialized SettingsManager singleton
    _settingsManager = SettingsManager();

    // Initialize LoggerService first (needed for other services)
    _loggerService = LoggerService();
    await _loggerService.initialize();

    // Initialize PDF service to extract bundled PDFs
    _pdfService = PdfService(_settingsManager);
    await _pdfService.initialize();

    // Initialize Update service for version checking (uses internet service)
    _updateService = UpdateService();
  }

  @visibleForTesting
  Future<void> initializeForTesting() async {
    _settingsManager = SettingsManager();
    _loggerService = LoggerService();
  }

  /// Get the singleton SettingsManager instance
  SettingsManager get settingsManager => _settingsManager;

  /// Get the singleton LoggerService instance
  LoggerService get loggerService => _loggerService;

  /// Get the singleton PdfService instance
  PdfService get pdfService => _pdfService;

  /// Get the singleton UpdateService instance
  UpdateService get updateService => _updateService;

  /// Get the singleton InternetService instance
  InternetService get internetService => _internetService;
}
