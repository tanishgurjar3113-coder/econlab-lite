import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class InvestmentInsightCard extends StatelessWidget{
  final double investedAmount;
  final double futureValue;

  const InvestmentInsightCard({
    super.key,
    required this.investedAmount,
    required this.futureValue,
  });

  double get interestEarned {
    return futureValue - investedAmount;
  }

  double get growthPercentage {
    if (investedAmount <= 0) {
      return 0;
    }
    return (interestEarned / investedAmount) * 100;
  }

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
            const Text("What This Means",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            ),
            
            const SizedBox(height: 16),

            _InsightRow(
              label: "Invested",
              value: investedAmount,
              isPercentage: false
            ),

            const SizedBox(height: 12),

            _InsightRow(
              label: "Interest Earned",
              value: interestEarned,
              isPercentage: false,
            ),

            const SizedBox(height: 12),

            _InsightRow(
              label: "Total Growth",
              value: growthPercentage,
              isPercentage: true,
            )
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isPercentage;

  const _InsightRow({
    required this.label,
    required this.value,
    required this.isPercentage,
  });

  String _formatValue(double value) {
    if (isPercentage) {
      return "${value.toStringAsFixed(1)}%";
    }
    return CurrencyFormatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        )),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: value,
          ),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Text(
              _formatValue(animatedValue),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            );
          }
        ),
      ],
    );
  }
}