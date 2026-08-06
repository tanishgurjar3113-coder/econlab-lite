import 'package:flutter/material.dart';

class InflationScreen extends StatelessWidget {
  const InflationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inflation"),
      ),
      body: const Center(
        child: Text(
          "Inflation Calculator",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
              