// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCPCUzOPvEQ66we_qKdcLQFHyvzFSzgLSM',
    appId: '1:95831549681:web:0bdf21831b6c59dc8c6b50',
    messagingSenderId: '95831549681',
    projectId: 'scrumpoker-1fa35',
    authDomain: 'scrumpoker-1fa35.firebaseapp.com',
    databaseURL: 'https://scrumpoker-1fa35.firebaseio.com',
    storageBucket: 'scrumpoker-1fa35.appspot.com',
    measurementId: 'G-F3WRG249VT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBD3jUV3rNbKcG1emrl2Cw961M2iJHfs54',
    appId: '1:95831549681:android:02f113e6cacee0c28c6b50',
    messagingSenderId: '95831549681',
    projectId: 'scrumpoker-1fa35',
    databaseURL: 'https://scrumpoker-1fa35.firebaseio.com',
    storageBucket: 'scrumpoker-1fa35.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB5CEwQH22SqBn1C2mmSy8Ftlj6NFMP3VM',
    appId: '1:95831549681:ios:6c8af4b8e68b7ee98c6b50',
    messagingSenderId: '95831549681',
    projectId: 'scrumpoker-1fa35',
    databaseURL: 'https://scrumpoker-1fa35.firebaseio.com',
    storageBucket: 'scrumpoker-1fa35.appspot.com',
    androidClientId: '95831549681-001jiqjaos3pfetggqqj9obhhnj7umji.apps.googleusercontent.com',
    iosClientId: '95831549681-1bk34ccqceqk1kr8crv165l4k1tgjoao.apps.googleusercontent.com',
    iosBundleId: 'br.com.cristiandemellos.scrumpoker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB5CEwQH22SqBn1C2mmSy8Ftlj6NFMP3VM',
    appId: '1:95831549681:ios:6c8af4b8e68b7ee98c6b50',
    messagingSenderId: '95831549681',
    projectId: 'scrumpoker-1fa35',
    databaseURL: 'https://scrumpoker-1fa35.firebaseio.com',
    storageBucket: 'scrumpoker-1fa35.appspot.com',
    androidClientId: '95831549681-001jiqjaos3pfetggqqj9obhhnj7umji.apps.googleusercontent.com',
    iosClientId: '95831549681-1bk34ccqceqk1kr8crv165l4k1tgjoao.apps.googleusercontent.com',
    iosBundleId: 'br.com.cristiandemellos.scrumpoker',
  );
}