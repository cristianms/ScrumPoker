import 'package:flutter/material.dart';
import 'package:scrumpoker/utils/nav.dart';

alert(BuildContext context, String msg, {Function? callback}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text("ScrumPoker"),
          content: Text(msg),
          actions: <Widget>[
            // FlatButton(
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                pop(context);
                if (callback != null) {
                  callback();
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
