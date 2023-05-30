import 'package:flutter/material.dart';

class AppCircularButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final bool showProgress;

  const AppCircularButton(this.label, {Key? key, required this.onPressed, this.showProgress = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () => onPressed,
      constraints: const BoxConstraints(),
      elevation: 2.0,
      fillColor: Colors.blue[300],
      padding: const EdgeInsets.all(10.0),
      shape: const CircleBorder(),
      child: showProgress
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ))
          : Text(
              label,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
