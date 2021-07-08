import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:scrumpoker/utils/prefs.dart';


class ImagemUtils {

  static const String IMG_KEY = 'IMAGE_KEY';

  static void saveImageToPrefs(String value) async {
    Prefs.setString(IMG_KEY, value);
  }

  static Future<String> getImageFromPrefs() async {
    return Prefs.getString(IMG_KEY);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  static Image imageFromBase64String(String base64String) {
    return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.fill,
    );
  }
}