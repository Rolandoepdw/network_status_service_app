import 'package:flutter/material.dart';

/// Displays a styled [SnackBar] notification.
void showStatusSnackBar(
  BuildContext context,
  String message,
  IconData icon,
  Color color,
) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(StatusSnackBar(message: message, icon: icon, color: color));
}

/// A custom [SnackBar] widget designed to display styled status notifications.
///
/// This snack bar includes an icon, a message, and a background color,
/// and is configured with a floating behavior and rounded corners.
class StatusSnackBar extends SnackBar {
  /// The message to be displayed in the snack bar.
  final String message;

  /// The icon to be displayed alongside the message.
  final IconData icon;

  /// The background color of the snack bar.
  final Color color;

  /// Creates a [StatusSnackBar].
  ///
  /// The [message], [icon], and [color] are required to configure the snack bar's appearance.
  StatusSnackBar({
    required this.message,
    required this.icon,
    required this.color,
    super.key,
  }) : super(
         content: Row(
           children: [
             Icon(icon, color: Colors.white),
             const SizedBox(width: 16),
             Expanded(child: Text(message)),
           ],
         ),
         backgroundColor: color,
         behavior: SnackBarBehavior.floating,
         margin: const EdgeInsets.all(16),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         duration: const Duration(seconds: 3),
       );
}
