import 'package:flutter/material.dart';

class AnimatedCurrencyValue extends StatelessWidget {
  final double value;
  final double fontSize;
  final Duration duration;

  const AnimatedCurrencyValue({
    super.key,
    required this.value,
    this.fontSize = 19,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0, end: value,
      ),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          "₹${animatedValue.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    );
  }
}