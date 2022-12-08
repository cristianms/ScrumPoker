// @dart=2.9
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool password;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final TextInputAction action;
  final bool autoFocus;
  final FocusNode focusNode;
  final FocusNode nextFocus;
  final bool enable;

  const AppText(
    this.label,
    this.hint, {Key key, 
    this.controller,
    this.password = false,
    this.validator,
    this.keyboardType,
    this.action,
    this.autoFocus,
    this.focusNode,
    this.nextFocus,
    this.enable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: password,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: action,
      autofocus: autoFocus ?? false,
      focusNode: focusNode,
      enabled: enable,
      onFieldSubmitted: (String text) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      style: const TextStyle(
        fontSize: 20,
        color: Colors.blue,
      ),
      decoration: InputDecoration(
//          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(
          fontSize: 20,
          color: Colors.grey,
        ),
        labelText: label,
        hintText: hint,
      ),
      textCapitalization: TextCapitalization.words,
    );
  }
}
