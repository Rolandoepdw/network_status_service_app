import 'package:flutter/material.dart';
import 'package:network_status_service/network/domain/network_status.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays the network status with animations and rich visuals.
class NetworkStatusView extends StatelessWidget {
  /// The current network status to display.
  final NetworkStatus status;

  /// {@macro network_status_view}
  ///
  /// Creates a [NetworkStatusView] with the given [status].
  const NetworkStatusView({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: _buildChild(context, status),
    );
  }

  Widget _buildChild(BuildContext context, NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return const _StatusDisplay(
          key: ValueKey(NetworkStatus.connected),
          icon: Icon(Icons.wifi, color: Color(0xFF2E7D32), size: 80),
          title: 'Connected',
          subtitle: 'The internet connection is stable and everything is fine.',
          color: Color(0xFF2E7D32),
        );
      case NetworkStatus.noService:
        return const _StatusDisplay(
          key: ValueKey(NetworkStatus.noService),
          icon: Icon(
            Icons.wifi_password_rounded,
            color: Color(0xFFFFA000),
            size: 80,
          ),
          title: 'Connected, No Internet',
          subtitle:
              'You are connected to a network, but there is no internet access.',
          color: Color(0xFFFFA000),
        );
      case NetworkStatus.disconnected:
        return const _StatusDisplay(
          key: ValueKey(NetworkStatus.disconnected),
          icon: Icon(Icons.wifi_off, color: Color(0xFF616161), size: 80),
          title: 'Disconnected',
          subtitle: 'There is no network connection available.',
          color: Color(0xFF616161),
        );
      case NetworkStatus.uninitialized:
        return const _ShimmerLoading(
          key: ValueKey(NetworkStatus.uninitialized),
        );
    }
  }
}

/// A private widget that displays a network status with an icon, title, and subtitle.
///
/// This widget is used internally by [NetworkStatusView] to present different
/// network states in a consistent visual manner.
class _StatusDisplay extends StatelessWidget {
  /// The icon to display, representing the network status.
  final Widget icon;

  /// The main title text for the status.
  final String title;

  /// A descriptive subtitle providing more details about the status.
  final String subtitle;

  /// The color associated with the current network status, used for styling.
  final Color color;

  /// Creates a [_StatusDisplay] widget.
  const _StatusDisplay({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 24),
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A private widget that displays a shimmering loading animation.
///
/// This widget is used internally by [NetworkStatusView] to indicate that
/// the network status is currently being determined (uninitialized state).
class _ShimmerLoading extends StatelessWidget {
  /// Creates a [_ShimmerLoading] widget.
  const _ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 32),
            Container(width: 180, height: 28, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: 360, height: 28, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
