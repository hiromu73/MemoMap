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
    apiKey: 'AIzaSyCkWX4JegpjCrmokbjfxX5iHkmC-biO-Os',
    appId: '1:754083471312:web:04117d3e385755ced4e3d5',
    messagingSenderId: '754083471312',
    projectId: 'flutter-crudapp-688ac',
    authDomain: 'flutter-crudapp-688ac.firebaseapp.com',
    storageBucket: 'flutter-crudapp-688ac.appspot.com',
    measurementId: 'G-DTX259WD31',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCycSH4q0f6B1zUsrD8jbuxJ7rH9Fha2Mc',
    appId: '1:754083471312:android:1ab0443effcadbe4d4e3d5',
    messagingSenderId: '754083471312',
    projectId: 'flutter-crudapp-688ac',
    storageBucket: 'flutter-crudapp-688ac.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMNN4yRMqAQNROEFR-malNRKFOH7vKhPo',
    appId: '1:754083471312:ios:c4f4e35cf109af23d4e3d5',
    messagingSenderId: '754083471312',
    projectId: 'flutter-crudapp-688ac',
    storageBucket: 'flutter-crudapp-688ac.appspot.com',
    iosClientId: '754083471312-hbgrtr90stuq0fsp0rbv4vlokfl56gn9.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterCrudapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCMNN4yRMqAQNROEFR-malNRKFOH7vKhPo',
    appId: '1:754083471312:ios:c4f4e35cf109af23d4e3d5',
    messagingSenderId: '754083471312',
    projectId: 'flutter-crudapp-688ac',
    storageBucket: 'flutter-crudapp-688ac.appspot.com',
    iosClientId: '754083471312-hbgrtr90stuq0fsp0rbv4vlokfl56gn9.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterCrudapp',
  );
}