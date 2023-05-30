import 'package:flutter/material.dart';

class Snack {
  static void show(BuildContext context, String str, {bool replace = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(str)),
    );
  }
}
