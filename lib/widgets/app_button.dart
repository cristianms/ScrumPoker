import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final bool showProgress;
  final bool disabled;

  const AppButton(
    this.label, {
    super.key,
    this.onPressed,
    this.showProgress = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(10),
        shadowColor: Colors.blue,
        minimumSize: kIsWeb ? const Size(10, 60) : null,
      ),
      // color: Colors.blue,
      onPressed: disabled == false ? onPressed : null,
      child: showProgress
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
    );
  }
}
