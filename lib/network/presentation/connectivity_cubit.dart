import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:network_status_service/network/domain/i_network_info.dart';
import 'package:network_status_service/network/domain/network_status.dart';

part 'connectivity_state.dart';

/// A [Cubit] that manages the application's network connectivity status.
///
/// This cubit listens to a stream of [NetworkStatus] updates from an
/// [INetworkInfo] instance. It interprets these updates to emit distinct states:
/// - [ConnectivityInitial]: The default state before any status is known.
/// - [ConnectivityStatusInitial]: Emitted once when the first network status is received.
/// - [ConnectivityStatusChanged]: Emitted for any subsequent changes in the network status.
///
/// This allows the UI to differentiate between the initial state and actual
/// connection/disconnection events.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final INetworkInfo _networkInfo;
  StreamSubscription? _networkInfoSubscription;

  /// Creates a [ConnectivityCubit] and starts listening to network changes.
  ConnectivityCubit(this._networkInfo) : super(ConnectivityInitial()) {
    // Start listening to network status changes.
    // The stream from NetworkInfo is designed to emit the current status upon subscription.
    _networkInfoSubscription = _networkInfo.onStatusChange.listen((status) {
      // If the state is still initial, this is the first status we've received.
      if (state is ConnectivityInitial) {
        emit(ConnectivityStatusInitial(status));
      } else {
        // Otherwise, it's a change from a previously known status.
        emit(ConnectivityStatusChanged(status));
      }
    });
  }

  @override
  Future<void> close() {
    _networkInfoSubscription?.cancel();
    return super.close();
  }
}
