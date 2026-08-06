import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

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
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}