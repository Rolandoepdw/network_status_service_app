part of 'connectivity_cubit.dart';

/// The base class for all connectivity-related states.
abstract class ConnectivityState extends Equatable {
  /// {@macro connectivity_state}
  ///
  /// Constructs a [ConnectivityState].
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

/// The initial state of the cubit, indicating that the network status has not
/// yet been determined.
class ConnectivityInitial extends ConnectivityState {}

/// A base state representing that the network status is known.
///
/// This class holds the [status] and is extended by more specific states.
abstract class ConnectivityStatusState extends ConnectivityState {
  /// The current network status.
  final NetworkStatus status;

  /// {@macro connectivity_status_state}
  ///
  /// Constructs a [ConnectivityStatusState] with the given [status].
  const ConnectivityStatusState(this.status);

  @override
  List<Object> get props => [status];
}

/// A state emitted when the network status is determined for the first time.
class ConnectivityStatusInitial extends ConnectivityStatusState {
  /// {@macro connectivity_status_initial}
  ///
  /// Constructs a [ConnectivityStatusInitial] with the given [status].
  const ConnectivityStatusInitial(super.status);
}

/// A state emitted when the network status changes after the initial check.
class ConnectivityStatusChanged extends ConnectivityStatusState {
  /// {@macro connectivity_status_changed}
  ///
  /// Constructs a [ConnectivityStatusChanged] with the given [status].
  const ConnectivityStatusChanged(super.status);
}
