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
    apiKey: 'AIzaSyDklQgELcqfEZwggtQ3PQuqnbbCcSnbVUk',
    appId: '1:459570418745:web:11983ed853c2fb3e2aa9e8',
    messagingSenderId: '459570418745',
    projectId: 'bookiee-1a30c',
    authDomain: 'bookiee-1a30c.firebaseapp.com',
    storageBucket: 'bookiee-1a30c.appspot.com',
    measurementId: 'G-0FY37X2T8M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1f4nMksEZFFBWDeMcNS47cB6kgj-7ol0',
    appId: '1:459570418745:android:64a4e165b52d57af2aa9e8',
    messagingSenderId: '459570418745',
    projectId: 'bookiee-1a30c',
    storageBucket: 'bookiee-1a30c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDf5EfT8iHmVZY2Q9iI2wIazYE-VfsPeiQ',
    appId: '1:459570418745:ios:730d21cbdf2e061c2aa9e8',
    messagingSenderId: '459570418745',
    projectId: 'bookiee-1a30c',
    storageBucket: 'bookiee-1a30c.appspot.com',
    iosBundleId: 'com.example.bookiee',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDf5EfT8iHmVZY2Q9iI2wIazYE-VfsPeiQ',
    appId: '1:459570418745:ios:730d21cbdf2e061c2aa9e8',
    messagingSenderId: '459570418745',
    projectId: 'bookiee-1a30c',
    storageBucket: 'bookiee-1a30c.appspot.com',
    iosBundleId: 'com.example.bookiee',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDklQgELcqfEZwggtQ3PQuqnbbCcSnbVUk',
    appId: '1:459570418745:web:ebb66930416bf5182aa9e8',
    messagingSenderId: '459570418745',
    projectId: 'bookiee-1a30c',
    authDomain: 'bookiee-1a30c.firebaseapp.com',
    storageBucket: 'bookiee-1a30c.appspot.com',
    measurementId: 'G-P6VGZ5HL45',
  );

}