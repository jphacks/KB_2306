// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members, do_not_use_environment, constant_identifier_names
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

const flavorName = String.fromEnvironment('flavor');

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (flavorName.isEmpty) {
      throw UnsupportedError(
        'No flavor specified. Please specify a flavor with dart-define-from-file.',
      );
    }

    if (kIsWeb) {
      if (flavorName == 'dev') {
        return _dev_web;
      }
      if (flavorName == 'prod') {
        return _prod_web;
      }
      throw UnsupportedError(
        'Flavor $flavorName does not support Web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Flavor $flavorName does not support Android.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Flavor $flavorName does not support iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
      // ignore: no_default_cases
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions _dev_web = FirebaseOptions(
    apiKey: 'AIzaSyBo9vQWKo-vBrNuqkm1LnTNTEfxzcI234w',
    appId: '1:677078728287:web:888e5c52ef55cab137a5ea',
    messagingSenderId: '677078728287',
    projectId: 'lyrics-transcriber-dev',
    authDomain: 'lyrics-transcriber-dev.firebaseapp.com',
    storageBucket: 'lyrics-transcriber-dev.appspot.com',
  );

  static const FirebaseOptions _prod_web = FirebaseOptions(
    apiKey: 'AIzaSyCJq-fWFTg3-KJuKuSUw08VIHGKaUqt_sE',
    appId: '1:53766241023:web:98acc08ccd86347b246aca',
    messagingSenderId: '53766241023',
    projectId: 'lyrics-transcriber',
    authDomain: 'lyrics-transcriber.firebaseapp.com',
    storageBucket: 'lyrics-transcriber.appspot.com',
  );
}
