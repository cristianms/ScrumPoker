import 'package:flutter/material.dart';

alert(BuildContext context, String msg, {Function? callback}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('ScrumPoker'),
          content: Text(msg),
          actions: <Widget>[
            // FlatButton(
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
