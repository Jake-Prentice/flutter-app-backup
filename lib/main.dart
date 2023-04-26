import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_pi/pages/auth/auth.dart';
import 'package:flutter_pi/provider/MyThemes.dart';
import 'package:flutter_pi/pages/auth/verify_email.dart';
import 'package:flutter_pi/services/notifications.dart';
import 'package:flutter_pi/firebase_options.dart';
import 'package:flutter_pi/user_data/user_data.dart';
import 'package:flutter_pi/user_data/user_stats.dart';
import 'package:flutter_pi/buttons/change_theme_button.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialises Firebase for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialises notification service

  // Runs the app
  runApp(const PIApp());
}

class PIApp extends StatelessWidget {
  const PIApp({super.key});

  static const String title = "PI Application";

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    builder: (context, _) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.themeMode,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        home: const MainPage(),
      );
    },
  );
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(body: StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text("Something went wrong"));
      } else if (snapshot.hasData) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        UserData.destroyInstance();
        UserStats.statsLoaded = false;
        return const VerifyEmailPage();
      } else {
        return const AuthPage();
      }
    },
  ));
}
