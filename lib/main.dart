import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    '🔥 Firebase Connected',
  );

  runApp(
    const HandzyThozhanApp(),
  );
}

class HandzyThozhanApp extends StatelessWidget {
  const HandzyThozhanApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme:
          AppTheme.lightTheme,

      title:
          'Handzy Thozhan',

      home:
          const SplashScreen(),
    );
  }
}