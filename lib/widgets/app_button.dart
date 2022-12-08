// @dart=2.9
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final bool showProgress;
  final bool disabled;

  AppButton(this.label, {this.onPressed, this.showProgress = false, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(10),
        shadowColor: Colors.blue,
      ),
      child: showProgress
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ))
          : Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
      // color: Colors.blue,
      onPressed: disabled == false ? onPressed : null,
    );
  }
}
