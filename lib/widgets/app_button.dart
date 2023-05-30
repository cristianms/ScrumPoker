import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final bool? showProgress;
  final bool? disabled;

  /// Construtor
  const AppButton(
    this.label, {
    Key? key,
    required this.onPressed,
    this.showProgress = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(10),
        shadowColor: Colors.blue,
        minimumSize: kIsWeb ? const Size(10, 60) : null,
      ),
      onPressed: disabled == false ? () => onPressed() : null,
      child: (showProgress ?? false)
          ? const Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ))
          : Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
    );
  }
}
