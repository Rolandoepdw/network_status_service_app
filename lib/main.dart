import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_status_service/injection/service_locator.dart';
import 'package:network_status_service/network/domain/network_status.dart';
import 'package:network_status_service/network/presentation/connectivity_cubit.dart';
import 'package:network_status_service/network/presentation/widgets/network_status_view.dart';
import 'package:network_status_service/network/presentation/widgets/status_snackbar_widget.dart';

void main() async {
  // Ensures that the Flutter binding is initialized before any Flutter-specific
  // code is executed.
  WidgetsFlutterBinding.ensureInitialized();
  // Sets up the service locator for dependency injection.
  await setupLocator();
  runApp(const MyApp());
}

/// The root widget of the application.
///
/// This widget sets up the global [BlocProvider] for [ConnectivityCubit]
/// and a [BlocListener] to display [SnackBar] notifications in response to
/// network status changes.
class MyApp extends StatelessWidget {
  /// {@macro my_app}
  ///
  /// The root widget of the application.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectivityCubit>(
      // Creates the instance of ConnectivityCubit, which will be available
      // to all descendant widgets.
      create: (context) => sl<ConnectivityCubit>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Connectivity App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        builder: (context, child) {
          // The BlocListener is placed here, high in the widget tree, to handle
          // global UI events like showing SnackBars.
          return BlocListener<ConnectivityCubit, ConnectivityState>(
            // `listenWhen` prevents the listener from firing for the initial status,
            // ensuring SnackBars only appear for subsequent connection changes.
            listenWhen: (previous, current) =>
                current is ConnectivityStatusChanged,
            listener: (context, state) {
              // We can safely assume state is ConnectivityStatusChanged due to listenWhen.
              final status = (state as ConnectivityStatusChanged).status;

              ScaffoldMessenger.of(context).removeCurrentSnackBar();

              if (status == NetworkStatus.connected) {
                showStatusSnackBar(
                  context,
                  'Connection Restored',
                  Icons.check_circle,
                  Colors.green.shade700,
                );
              } else if (status == NetworkStatus.noService) {
                showStatusSnackBar(
                  context,
                  'Connected, but no internet access.',
                  Icons.warning,
                  Colors.orange.shade800,
                );
              } else if (status == NetworkStatus.disconnected) {
                showStatusSnackBar(
                  context,
                  'Network connection lost.',
                  Icons.error,
                  Colors.red.shade700,
                );
              }
            },
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const HomePage(),
      ),
    );
  }
}

/// The main page of the application.
///
/// This widget displays the current network status by listening to the
/// [ConnectivityCubit] with a [BlocBuilder].
class HomePage extends StatelessWidget {
  /// {@macro home_page}
  ///
  /// The main page of the application.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Status'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blueGrey.shade800,
      ),
      body: Center(
        // BlocBuilder rebuilds the view whenever the ConnectivityState changes.
        child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, state) {
            // It handles any state that has a status property.
            if (state is ConnectivityStatusState) {
              return NetworkStatusView(status: state.status);
            }
            // Shows a loading view for the initial, undetermined state.
            return const NetworkStatusView(status: NetworkStatus.uninitialized);
          },
        ),
      ),
    );
  }
}
