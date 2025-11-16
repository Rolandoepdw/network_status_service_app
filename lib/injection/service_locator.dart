// ignore_for_file: cascade_invocations

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:network_status_service/network/domain/i_network_info.dart';
import 'package:network_status_service/network/infrastructure/network_info.dart';
import 'package:network_status_service/network/presentation/connectivity_cubit.dart';

/// A global service locator instance for dependency injection.
final sl = GetIt.instance;

/// Sets up the service locator with all the necessary dependencies.
///
/// This function should be called once at application startup.
Future<void> setupLocator() async {
  //------------------------------------------------------ External Dependencies
  sl
    ..registerLazySingleton(() => InternetConnection())
    ..registerLazySingleton(() => Connectivity())
    //------------------------------------------------------------- Network Info
    ..registerLazySingleton<INetworkInfo>(
      () => NetworkInfo(connectivity: sl(), internetConnection: sl()),
    );
  //--------------------------------------------------------- Connectivity Cubit
  sl.registerFactory(() => ConnectivityCubit(sl()));
}
