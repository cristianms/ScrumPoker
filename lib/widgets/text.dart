import 'package:flutter/material.dart';

Text text(String texto, {double fontSize = 16, color = Colors.black, bold = false}) {
  return Text(
    texto ?? "",
    style: TextStyle(
      fontSize: fontSize,
//      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}
