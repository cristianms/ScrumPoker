import 'package:flutter/material.dart';

Future push(NavigatorState navigator, Widget page, {bool replace = false}) {
  if (replace) {
    return navigator.pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }
  return navigator.push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return page;
      },
    ),
  );
}
