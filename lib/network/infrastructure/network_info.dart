import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:network_status_service/network/domain/i_network_info.dart';
import 'package:network_status_service/network/domain/network_status.dart';
import 'package:rxdart/rxdart.dart';

/// A concrete implementation of [INetworkInfo] that uses [Connectivity]
/// and [InternetConnection] to determine the network status.
///
/// This class combines the capabilities of both packages to provide a more
/// granular and accurate representation of the device's network state. It listens
/// to streams from both sources and synthesizes them into a single, reliable

/// [NetworkStatus] stream.
class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;
  final InternetConnection _internetConnection;

  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();

  // Subscription is managed internally and lives for the app's lifecycle.
  // late final StreamSubscription _combinedSubscription;
  NetworkStatus _lastStatus = NetworkStatus.uninitialized;

  /// Creates an instance of [NetworkInfo] and initializes the listeners.
  NetworkInfo({
    Connectivity? connectivity,
    InternetConnection? internetConnection,
  }) : _connectivity = connectivity ?? Connectivity(),
       _internetConnection = internetConnection ?? InternetConnection() {
    // The stream from `connectivity_plus` does not emit an initial value on listen,
    // so it must be seeded with a one-time check.
    final connectivityStream =
        Stream.fromFuture(
          _connectivity.checkConnectivity(),
        ).asBroadcastStream().concatWith([
          _connectivity.onConnectivityChanged.flatMap(Stream.value),
        ]);

    // The stream from `internet_connection_checker_plus` emits the last known
    // status upon listening, so it can be used directly.
    final internetStream = _internetConnection.onStatusChange;

    CombineLatestStream.combine2(connectivityStream, internetStream, (
          List<ConnectivityResult> connectivityResults,
          InternetStatus internetStatus,
        ) {
          // The connectivity_plus stream can emit a list. We just need to know
          // if it's empty or contains 'none'.
          final hasNetworkInterface =
              connectivityResults.isNotEmpty &&
              !connectivityResults.contains(ConnectivityResult.none);

          if (hasNetworkInterface) {
            return internetStatus == InternetStatus.connected
                ? NetworkStatus.connected
                : NetworkStatus.noService;
          } else {
            return NetworkStatus.disconnected;
          }
        })
        // Use a distinct() operator to only emit when the status actually changes.
        .distinct()
        .listen((NetworkStatus status) {
          _lastStatus = status;
          _statusController.add(status);
        });
  }

  @override
  Stream<NetworkStatus> get onStatusChange => _statusController.stream;

  @override
  bool get hasInternetConnection => _lastStatus == NetworkStatus.connected;

  @override
  Future<NetworkStatus> get status async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final hasInternet = await _internetConnection.hasInternetAccess;

    final hasNetworkInterface =
        connectivityResults.isNotEmpty &&
        !connectivityResults.contains(ConnectivityResult.none);

    if (hasNetworkInterface) {
      return hasInternet ? NetworkStatus.connected : NetworkStatus.noService;
    } else {
      return NetworkStatus.disconnected;
    }
  }
}
