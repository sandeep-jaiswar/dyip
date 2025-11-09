// Firebase configuration using environment variables for security
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static String _getEnv(String key, {String defaultValue = ''}) {
    try {
      return dotenv.env[key] ?? defaultValue;
    } catch (e) {
      // dotenv not loaded or key not found
      return defaultValue;
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_WEB', defaultValue: 'test-key'),
    appId: _getEnv('FIREBASE_APP_ID_WEB', defaultValue: '1:123456789:web:test'),
    messagingSenderId: _getEnv(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '123456789',
    ),
    projectId: _getEnv('FIREBASE_PROJECT_ID', defaultValue: 'test-project'),
    authDomain: _getEnv(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'test-project.firebaseapp.com',
    ),
    databaseURL: _getEnv(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://test-project.firebaseio.com',
    ),
    storageBucket: _getEnv(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'test-project.appspot.com',
    ),
    measurementId: _getEnv('FIREBASE_MEASUREMENT_ID_WEB'),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_ANDROID', defaultValue: 'test-key'),
    appId: _getEnv(
      'FIREBASE_APP_ID_ANDROID',
      defaultValue: '1:123456789:android:test',
    ),
    messagingSenderId: _getEnv(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '123456789',
    ),
    projectId: _getEnv('FIREBASE_PROJECT_ID', defaultValue: 'test-project'),
    databaseURL: _getEnv(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://test-project.firebaseio.com',
    ),
    storageBucket: _getEnv(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'test-project.appspot.com',
    ),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_IOS', defaultValue: 'test-key'),
    appId: _getEnv('FIREBASE_APP_ID_IOS', defaultValue: '1:123456789:ios:test'),
    messagingSenderId: _getEnv(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '123456789',
    ),
    projectId: _getEnv('FIREBASE_PROJECT_ID', defaultValue: 'test-project'),
    databaseURL: _getEnv(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://test-project.firebaseio.com',
    ),
    storageBucket: _getEnv(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'test-project.appspot.com',
    ),
    iosBundleId: _getEnv(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.jspl.dyip',
    ),
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_IOS', defaultValue: 'test-key'),
    appId: _getEnv('FIREBASE_APP_ID_IOS', defaultValue: '1:123456789:ios:test'),
    messagingSenderId: _getEnv(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '123456789',
    ),
    projectId: _getEnv('FIREBASE_PROJECT_ID', defaultValue: 'test-project'),
    databaseURL: _getEnv(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://test-project.firebaseio.com',
    ),
    storageBucket: _getEnv(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'test-project.appspot.com',
    ),
    iosBundleId: _getEnv(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.jspl.dyip',
    ),
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_WINDOWS', defaultValue: 'test-key'),
    appId: _getEnv(
      'FIREBASE_APP_ID_WINDOWS',
      defaultValue: '1:123456789:windows:test',
    ),
    messagingSenderId: _getEnv(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '123456789',
    ),
    projectId: _getEnv('FIREBASE_PROJECT_ID', defaultValue: 'test-project'),
    authDomain: _getEnv(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'test-project.firebaseapp.com',
    ),
    databaseURL: _getEnv(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'https://test-project.firebaseio.com',
    ),
    storageBucket: _getEnv(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'test-project.appspot.com',
    ),
    measurementId: _getEnv('FIREBASE_MEASUREMENT_ID_WINDOWS'),
  );
}
