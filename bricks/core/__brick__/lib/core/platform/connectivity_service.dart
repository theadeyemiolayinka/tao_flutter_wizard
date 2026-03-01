{{#connectivity}}
import 'package:connectivity_plus/connectivity_plus.dart';

/// Possible connectivity states for the app.
enum ConnectivityStatus { online, offline }

/// Wraps [connectivity_plus] into a simple connectivity service.
///
/// Provides:
/// - [onStatusChange] - stream of [ConnectivityStatus] changes
/// - [isConnected] - one-time check
///
/// Register as a singleton in [registerCoreDependencies]:
/// ```dart
/// getIt.registerSingleton<ConnectivityService>(ConnectivityService());
/// ```
///
/// Then listen in [AppBloc]:
/// ```dart
/// _connectivityService.onStatusChange.listen(
///   (status) => add(AppEvent.connectivityChanged(status)),
/// );
/// ```
class ConnectivityService {
  ConnectivityService() : _connectivity = Connectivity();

  final Connectivity _connectivity;

  /// Stream of connectivity changes.
  Stream<ConnectivityStatus> get onStatusChange {
    return _connectivity.onConnectivityChanged.map(_mapResult);
  }

  /// Check current connectivity status.
  Future<ConnectivityStatus> get currentStatus async {
    final result = await _connectivity.checkConnectivity();
    return _mapResult(result);
  }

  /// One-time boolean check.
  Future<bool> get isConnected async {
    return (await currentStatus) == ConnectivityStatus.online;
  }

  ConnectivityStatus _mapResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityStatus.offline;
    final hasConnection = results.any(
      (r) => r != ConnectivityResult.none,
    );
    return hasConnection
        ? ConnectivityStatus.online
        : ConnectivityStatus.offline;
  }
}
{{/connectivity}}
