import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_status_service/network/domain/i_network_info.dart';
import 'package:network_status_service/network/domain/network_status.dart';
import 'package:network_status_service/network/presentation/connectivity_cubit.dart';

import 'connectivity_cubit_test.mocks.dart';

@GenerateMocks([INetworkInfo])
void main() {
  late MockINetworkInfo mockNetworkInfo;

  setUp(() {
    mockNetworkInfo = MockINetworkInfo();
  });

  group('ConnectivityCubit', () {
    // Test the initial state
    test('initial state is ConnectivityInitial', () {
      // Arrange
      when(
        mockNetworkInfo.onStatusChange,
      ).thenAnswer((_) => Stream.value(NetworkStatus.connected));
      // Act
      final cubit = ConnectivityCubit(mockNetworkInfo);
      // Assert
      expect(cubit.state, ConnectivityInitial());
    });

    // Test state emissions with bloc_test
    blocTest<ConnectivityCubit, ConnectivityState>(
      'emits [ConnectivityStatusInitial] when network status is received for the first time',
      build: () {
        when(
          mockNetworkInfo.onStatusChange,
        ).thenAnswer((_) => Stream.fromIterable([NetworkStatus.connected]));
        return ConnectivityCubit(mockNetworkInfo);
      },
      expect: () => [const ConnectivityStatusInitial(NetworkStatus.connected)],
    );

    blocTest<ConnectivityCubit, ConnectivityState>(
      'emits [ConnectivityStatusChanged] for subsequent network status changes',
      build: () {
        when(mockNetworkInfo.onStatusChange).thenAnswer(
          (_) => Stream.fromIterable([
            NetworkStatus.connected,
            NetworkStatus.disconnected,
          ]),
        );
        return ConnectivityCubit(mockNetworkInfo);
      },
      // Skip the first emission since we are testing subsequent changes
      skip: 1,
      expect: () => [
        const ConnectivityStatusChanged(NetworkStatus.disconnected),
      ],
    );

    blocTest<ConnectivityCubit, ConnectivityState>(
      'emits correct sequence of states for multiple changes',
      build: () {
        when(mockNetworkInfo.onStatusChange).thenAnswer(
          (_) => Stream.fromIterable([
            NetworkStatus.disconnected,
            NetworkStatus.noService,
            NetworkStatus.connected,
          ]),
        );
        return ConnectivityCubit(mockNetworkInfo);
      },
      expect: () => [
        const ConnectivityStatusInitial(NetworkStatus.disconnected),
        const ConnectivityStatusChanged(NetworkStatus.noService),
        const ConnectivityStatusChanged(NetworkStatus.connected),
      ],
    );
  });
}
