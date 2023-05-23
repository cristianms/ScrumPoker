
import 'package:flutter/material.dart';

class TextError extends StatelessWidget {
  final String msg;

  const TextError(this.msg, {Key? key}) : super(key: key);

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
