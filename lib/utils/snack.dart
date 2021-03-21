import 'package:flutter/material.dart';
import 'package:scrumpoker/utils/global_scaffold.dart';

class Snack {
  static void show(String str, {bool replace = true}) {
    final scaffold = GlobalScaffold.instance.scaffoldKey.currentState;
    // if (replace) {
    //   scaffold..hideCurrentSnackBar();
    // }
    scaffold
      // ignore: deprecated_member_use
      ..showSnackBar(
        SnackBar(
          // duration: const Duration(seconds: 4),
          // behavior: SnackBarBehavior.fixed,
          content: Text(str),
        ),
      );
  }
}
