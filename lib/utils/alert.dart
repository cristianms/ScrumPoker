import 'package:flutter/material.dart';

alert(BuildContext context, String msg, {Function callback}) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("ScrumPoker"),
            content: Text(msg),
            actions: <Widget>[
//              FlatButton(
//                child: Text("Cancelar"),
//                onPressed: () {
//                  Navigator.pop(context);
//                  print("Cancelado");
//                },
//              ),
              // FlatButton(
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  print("OK");
                  if (callback != null) {
                    callback();
                  }
                },
              ),
            ],
          ),
        );
      });
}