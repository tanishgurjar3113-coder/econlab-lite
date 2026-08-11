import 'package:flutter/material.dart';
import '../animations/animated_number.dart';

class ResultCard extends StatefulWidget {
  final String title;
  final double value;
  final String? subtitle;

  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            AnimatedNumber(
              value: widget.value,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),

            if (widget.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.subtitle!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
