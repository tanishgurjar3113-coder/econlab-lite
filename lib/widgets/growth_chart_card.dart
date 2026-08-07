import 'package:flutter/material.dart';

class GrowthChartCard extends StatelessWidget {
  final String title;
  final Widget chart;

  const GrowthChartCard({
    super.key,
    required this.title,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}