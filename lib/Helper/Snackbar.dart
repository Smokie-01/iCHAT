import 'package:flutter/material.dart';

class CustomDialog {
  static void snackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static void showProgressIndicator(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return Center(child: CircularProgressIndicator());
        });
  }
}
