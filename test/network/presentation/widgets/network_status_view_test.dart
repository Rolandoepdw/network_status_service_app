import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_status_service/network/domain/network_status.dart';
import 'package:network_status_service/network/presentation/widgets/network_status_view.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  // Helper function to wrap the widget in a MaterialApp
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('NetworkStatusView', () {
    testWidgets('renders ShimmerLoading for uninitialized status', (
      WidgetTester tester,
    ) async {
      // Arrange
      const view = NetworkStatusView(status: NetworkStatus.uninitialized);

      // Act
      await tester.pumpWidget(buildTestableWidget(view));

      // Let the animation run
      await tester.pump();

      // Assert
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('renders correctly for disconnected status', (
      WidgetTester tester,
    ) async {
      // Arrange
      const view = NetworkStatusView(status: NetworkStatus.disconnected);

      // Act
      await tester.pumpWidget(buildTestableWidget(view));
      // Trigger the AnimatedSwitcher transition
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Disconnected'), findsOneWidget);
      expect(
        find.text('There is no network connection available.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('renders correctly for noService status', (
      WidgetTester tester,
    ) async {
      // Arrange
      const view = NetworkStatusView(status: NetworkStatus.noService);

      // Act
      await tester.pumpWidget(buildTestableWidget(view));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Connected, No Internet'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_password_rounded), findsOneWidget);
    });

    testWidgets('renders PulsingIcon for connected status', (
      WidgetTester tester,
    ) async {
      // Arrange
      const view = NetworkStatusView(status: NetworkStatus.connected);

      // Act
      await tester.pumpWidget(buildTestableWidget(view));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Connected'), findsOneWidget);
      // We can't easily test for _PulsingIcon as it's a private class.
      // Instead, we test for the icon it's supposed to display.
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      // And confirm the Shimmer is gone
      expect(find.byType(Shimmer), findsNothing);
    });
  });
}
