
import 'package:flutter/material.dart';

class TextError extends StatelessWidget {
  final String msg;

  const TextError(this.msg, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 22,
        ),
      ),
    );
  }
}
