// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyCFIA-Ni-Hk6Tfkb4xXqzOmpK81RyuYGQs',
    appId: '1:348404299583:web:d8cb2feac5a57c4b35c58a',
    messagingSenderId: '348404299583',
    projectId: 'unishare-63c0e',
    authDomain: 'unishare-63c0e.firebaseapp.com',
    storageBucket: 'unishare-63c0e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxm665kWbpY4ZP8qCLp4t3UelPq7fgERg',
    appId: '1:348404299583:android:2b935530a6459f5635c58a',
    messagingSenderId: '348404299583',
    projectId: 'unishare-63c0e',
    storageBucket: 'unishare-63c0e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCkK3VDsjJomeul9WILW8Hmf_CO3eLt3ZY',
    appId: '1:348404299583:ios:523a31187f8a1fe035c58a',
    messagingSenderId: '348404299583',
    projectId: 'unishare-63c0e',
    storageBucket: 'unishare-63c0e.appspot.com',
    iosBundleId: 'com.example.bookiee',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCkK3VDsjJomeul9WILW8Hmf_CO3eLt3ZY',
    appId: '1:348404299583:ios:523a31187f8a1fe035c58a',
    messagingSenderId: '348404299583',
    projectId: 'unishare-63c0e',
    storageBucket: 'unishare-63c0e.appspot.com',
    iosBundleId: 'com.example.bookiee',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCFIA-Ni-Hk6Tfkb4xXqzOmpK81RyuYGQs',
    appId: '1:348404299583:web:f6696589ef151d1635c58a',
    messagingSenderId: '348404299583',
    projectId: 'unishare-63c0e',
    authDomain: 'unishare-63c0e.firebaseapp.com',
    storageBucket: 'unishare-63c0e.appspot.com',
  );

}