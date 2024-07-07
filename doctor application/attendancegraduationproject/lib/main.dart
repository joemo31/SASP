import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
  } else {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await WindowManager.instance.setMinimumSize(const Size(480, 800));

      //  setWindowMinSize(const Size(512, 384));
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Application',
      theme: ThemeData(useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}
