
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps
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
    apiKey: 'AIzaSyDnmZ9ozzHJ8btdV6mHqw5Cmqe7SOIgTus',
    appId: '1:117460258962:web:e84498cf6742ec6772164b',
    messagingSenderId: '117460258962',
    projectId: 'flutter-a46bb',
    authDomain: 'flutter-a46bb.firebaseapp.com',
    storageBucket: 'flutter-a46bb.firebasestorage.app',
    measurementId: 'G-Q5B2TYC0GM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAW0eBtgRyy601SmGLg3MumGnqz1cteE-k',
    appId: '1:117460258962:android:bc92b6435195040572164b',
    messagingSenderId: '117460258962',
    projectId: 'flutter-a46bb',
    storageBucket: 'flutter-a46bb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkfzS_JbS1CbQot1Y5ti1lYpHOYD5MfIo',
    appId: '1:117460258962:ios:eb730b539475514e72164b',
    messagingSenderId: '117460258962',
    projectId: 'flutter-a46bb',
    storageBucket: 'flutter-a46bb.firebasestorage.app',
    iosBundleId: 'com.example.l4Seance2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAkfzS_JbS1CbQot1Y5ti1lYpHOYD5MfIo',
    appId: '1:117460258962:ios:eb730b539475514e72164b',
    messagingSenderId: '117460258962',
    projectId: 'flutter-a46bb',
    storageBucket: 'flutter-a46bb.firebasestorage.app',
    iosBundleId: 'com.example.l4Seance2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDnmZ9ozzHJ8btdV6mHqw5Cmqe7SOIgTus',
    appId: '1:117460258962:web:e54ad9d5d7962ab772164b',
    messagingSenderId: '117460258962',
    projectId: 'flutter-a46bb',
    authDomain: 'flutter-a46bb.firebaseapp.com',
    storageBucket: 'flutter-a46bb.firebasestorage.app',
    measurementId: 'G-JSCF8BRQ79',
  );
}
