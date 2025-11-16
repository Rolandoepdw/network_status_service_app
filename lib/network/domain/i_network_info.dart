import 'package:network_status_service/network/domain/network_status.dart';

/// Abstract class defining the contract for network connectivity information.
///
/// This interface allows different implementations for checking network status,
/// promoting testability and flexibility.
abstract class INetworkInfo {
  /// Provides a stream of [NetworkStatus] changes.
  ///
  /// Consumers can listen to this stream to react to real-time changes
  /// in the application's network connectivity.
  Stream<NetworkStatus> get onStatusChange;

  /// Provides the current [NetworkStatus] as a Future.
  ///
  /// Useful for a one-time check of the current network status.
  Future<NetworkStatus> get status;

  /// Immediately returns true if the last known network status was
  /// [NetworkStatus.connected].
  ///
  /// This provides a synchronous way to check for an active internet connection,
  /// useful for preventing network requests that would otherwise time out.
  bool get hasInternetConnection;
}
