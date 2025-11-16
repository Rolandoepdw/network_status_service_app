// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_status_service/network/domain/network_status.dart';
import 'package:network_status_service/network/infrastructure/network_info.dart';
import 'package:rxdart/rxdart.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([Connectivity, InternetConnection])
void main() {
  late MockConnectivity mockConnectivity;
  late MockInternetConnection mockInternetConnection;
  late NetworkInfo networkInfo;

  // Stream controllers to simulate the behavior of the external packages
  late StreamController<List<ConnectivityResult>> connectivityController;
  // Use a BehaviorSubject for the internet status to mimic the real package's
  // behavior of emitting the last known value upon listening.
  late BehaviorSubject<InternetStatus> internetConnectionController;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockInternetConnection = MockInternetConnection();

    connectivityController =
        StreamController<List<ConnectivityResult>>.broadcast();
    // Initialize with a default status. This ensures that any subscriber
    // immediately gets a value, preventing timeouts in CombineLatestStream.
    internetConnectionController = BehaviorSubject<InternetStatus>.seeded(
      InternetStatus.disconnected,
    );

    // Mock the streams
    when(
      mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
    when(
      mockInternetConnection.onStatusChange,
    ).thenAnswer((_) => internetConnectionController.stream);
  });

  tearDown(() {
    connectivityController.close();
    internetConnectionController.close();
  });

  group('NetworkInfo', () {
    test(
      'emits [NetworkStatus.disconnected] when connectivity check returns none',
      () async {
        // Arrange
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);

        // Act
        // Creating the NetworkInfo instance subscribes to the streams.
        // The BehaviorSubject immediately provides its seeded value.
        // The checkConnectivity future completes.
        // CombineLatestStream fires with ([ConnectivityResult.none], InternetStatus.disconnected).
        networkInfo = NetworkInfo(
          connectivity: mockConnectivity,
          internetConnection: mockInternetConnection,
        );

        // Assert
        // The stream should emit the disconnected status almost immediately.
        await expectLater(
          networkInfo.onStatusChange,
          emits(NetworkStatus.disconnected),
        );
      },
    );

    test(
      'emits [NetworkStatus.noService] when there is connectivity but no internet',
      () async {
        // Arrange
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        internetConnectionController.add(InternetStatus.disconnected);

        // Act
        networkInfo = NetworkInfo(
          connectivity: mockConnectivity,
          internetConnection: mockInternetConnection,
        );

        // Assert
        await expectLater(
          networkInfo.onStatusChange,
          emits(NetworkStatus.noService),
        );
      },
    );

    test(
      'emits [NetworkStatus.connected] when there is connectivity and internet',
      () async {
        // Arrange
        when(
          mockConnectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        internetConnectionController.add(InternetStatus.connected);

        // Act
        networkInfo = NetworkInfo(
          connectivity: mockConnectivity,
          internetConnection: mockInternetConnection,
        );

        // Assert
        await expectLater(
          networkInfo.onStatusChange,
          emits(NetworkStatus.connected),
        );
      },
    );

    test('status getter returns correct status on one-time check', () async {
      // Arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.mobile]);
      when(
        mockInternetConnection.hasInternetAccess,
      ).thenAnswer((_) async => true);

      // Act
      networkInfo = NetworkInfo(
        connectivity: mockConnectivity,
        internetConnection: mockInternetConnection,
      );
      final status = await networkInfo.status;

      // Assert
      expect(status, NetworkStatus.connected);
    });

    test('emits status changes correctly over time', () async {
      // Arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);
      internetConnectionController.add(InternetStatus.connected);

      // Act
      networkInfo = NetworkInfo(
        connectivity: mockConnectivity,
        internetConnection: mockInternetConnection,
      );

      // Assert
      expectLater(
        networkInfo.onStatusChange,
        emitsInOrder([
          NetworkStatus.connected,
          NetworkStatus.noService,
          NetworkStatus.disconnected,
          NetworkStatus.noService,
          NetworkStatus.connected,
        ]),
      );

      // Act: Simulate status changes with delays to prevent race conditions
      await Future.delayed(Duration.zero);
      internetConnectionController.add(InternetStatus.disconnected);

      await Future.delayed(Duration.zero);
      connectivityController.add([ConnectivityResult.none]);

      await Future.delayed(Duration.zero);
      connectivityController.add([ConnectivityResult.mobile]);

      await Future.delayed(Duration.zero);
      internetConnectionController.add(InternetStatus.connected);
    });
  });
}
