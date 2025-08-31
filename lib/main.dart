import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'home_screen_navigator.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const BarApp(),
    ),
  );
}

class BarApp extends StatelessWidget {
  const BarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BarManager App',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF8C00),
        cardColor: const Color(0xFF1a1a1a),
        scaffoldBackgroundColor: const Color(0xFF0a0a0a),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        dividerColor: Colors.white.withOpacity(0.2),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomeScreenNavigator(),
    );
  }
}