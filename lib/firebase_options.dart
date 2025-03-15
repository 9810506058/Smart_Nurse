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
    apiKey: 'AIzaSyBUT7jtwBMnpynY_EmHwWnSdmEq5g7LEic',
    appId: '1:720691763699:web:5d44e44c725d6739761a86',
    messagingSenderId: '720691763699',
    projectId: 'smartnurse-9202b',
    authDomain: 'smartnurse-9202b.firebaseapp.com',
    storageBucket: 'smartnurse-9202b.firebasestorage.app',
    measurementId: 'G-L4X6KDZZRV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5WwWYjEPrvAwz51C2DGcBS7i09SpSXB0',
    appId: '1:720691763699:android:091d447a3b15e46c761a86',
    messagingSenderId: '720691763699',
    projectId: 'smartnurse-9202b',
    storageBucket: 'smartnurse-9202b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCu1TK_XGg79XtG6AjumlIt05lCfxR_TAo',
    appId: '1:720691763699:ios:3619cfd8e44e5288761a86',
    messagingSenderId: '720691763699',
    projectId: 'smartnurse-9202b',
    storageBucket: 'smartnurse-9202b.firebasestorage.app',
    iosBundleId: 'com.example.smartnurse',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCu1TK_XGg79XtG6AjumlIt05lCfxR_TAo',
    appId: '1:720691763699:ios:3619cfd8e44e5288761a86',
    messagingSenderId: '720691763699',
    projectId: 'smartnurse-9202b',
    storageBucket: 'smartnurse-9202b.firebasestorage.app',
    iosBundleId: 'com.example.smartnurse',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBUT7jtwBMnpynY_EmHwWnSdmEq5g7LEic',
    appId: '1:720691763699:web:a8b8aad2a12dd830761a86',
    messagingSenderId: '720691763699',
    projectId: 'smartnurse-9202b',
    authDomain: 'smartnurse-9202b.firebaseapp.com',
    storageBucket: 'smartnurse-9202b.firebasestorage.app',
    measurementId: 'G-KQ4X639BGN',
  );
}
