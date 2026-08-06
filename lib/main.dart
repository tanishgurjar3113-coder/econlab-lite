import 'package:flutter/material.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EconLab Lite"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Welcome to EconLab Lite!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}