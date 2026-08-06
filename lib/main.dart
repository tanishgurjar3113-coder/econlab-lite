import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EconLabApp());
}

class EconLabApp extends StatelessWidget {
  const EconLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EconLab Lite',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}