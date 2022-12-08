import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:scrumpoker/utils/prefs.dart';


class ImagemUtils {

  static const String imgKey = 'IMAGE_KEY';

  static void saveImageToPrefs(String value) async {
    Prefs.setString(imgKey, value);
  }

  static Future<String> getImageFromPrefs() async {
    return Prefs.getString(imgKey);
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