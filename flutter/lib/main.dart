import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/color_schemes.g.dart';
import 'package:flutter_firebase/firebase_options.dart';
import 'package:flutter_firebase/pages/home/view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await FirebaseAuth.instance.signInAnonymously();

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
