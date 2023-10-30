import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lyricscribe/color_schemes.g.dart';
import 'package:lyricscribe/entities/music.dart';
import 'package:lyricscribe/entities/transcription_segment.dart';
import 'package:lyricscribe/firebase_options.dart';
import 'package:lyricscribe/helpers/hive.dart';
import 'package:lyricscribe/pages/home/view.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      Hive
        ..registerAdapter(MusicAdapter())
        ..registerAdapter(TranscriptionSegmentAdapter())
        ..registerAdapter(TranscriptionWordAdapter());
      await openBox<Music>(BoxName.musics);

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await FirebaseAuth.instance.signInAnonymously();

      if (kIsWeb) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }

      runApp(
        ProviderScope(
          child: MaterialApp(
            onGenerateRoute: _onGenerateRoute,
            initialRoute: 'home',
            theme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
            darkTheme:
                ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
          ),
        ),
      );
    },
    (error, stackTrace) {
      print('runZonedGuarded: Caught error in my root zone.');
      print('error\n$error');
      print('stacktrace\n$stackTrace');
    },
  );
}

Route<dynamic> _onGenerateRoute(RouteSettings settings) =>
    PageRouteBuilder<Widget>(
      settings: settings,
      pageBuilder: (_, __, ___) {
        final name = settings.name;
        if (name == null) {
          return const Home();
        }
        if (name == 'home') {
          return const Home();
        }
        return const Home();
      },
    );
