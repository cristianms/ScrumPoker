// @dart=2.9
import 'package:flutter/material.dart';

class AppCircularButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final bool showProgress;

  AppCircularButton(this.label, {this.onPressed, this.showProgress = false});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: BoxConstraints(),
      elevation: 2.0,
      fillColor: Colors.blue[300],
      padding: EdgeInsets.all(10.0),
      shape: CircleBorder(),
      child: showProgress
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ))
          : Text(
              label,
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
