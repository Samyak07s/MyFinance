import 'package:flutter/material.dart';

class Dialogs {
  /// Show a loading indicator (progress bar)
  static void showProgressBar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Show a snackbar with a message
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }
}
