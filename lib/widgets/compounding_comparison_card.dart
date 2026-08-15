import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class CompoundingComparisonCard extends StatelessWidget {
  final Map<String, double> comparison;
  final int selectedFrequency;
  final bool animate;

  const CompoundingComparisonCard({
    super.key,
    required this.comparison,
    required this.selectedFrequency,
    required this.animate,
  });

  String _frequencyKey(int frequency) {
    switch (frequency) {
      case 1:
        return "Annually";
      case 2:
        return "Semi-Annually";
      case 4:
        return "Quarterly";
      case 12:
        return "Monthly";
      case 365:
        return "Daily";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = _frequencyKey(selectedFrequency);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Compounding Comparison",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "See how compounding frequency affects your final value.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 18),

            _ComparisonRow(
              label: "Annually",
              value: comparison["Annually"] ?? 0,
              isSelected: selectedLabel == "Annually",
              animate: animate,
            ),

            const SizedBox(height: 10),

            _ComparisonRow(
              label: "Semi-Annually",
              value: comparison["Semi-Annually"] ?? 0,
              isSelected: selectedLabel == "Semi-Annually",
              animate: animate,
            ),

            const SizedBox(height: 10),

            _ComparisonRow(
              label: "Quarterly",
              value: comparison["Quarterly"] ?? 0,
              isSelected: selectedLabel == "Quarterly",
              animate: animate,
            ),

            const SizedBox(height: 10),

            _ComparisonRow(
              label: "Monthly",
              value: comparison["Monthly"] ?? 0,
              isSelected: selectedLabel == "Monthly",
              animate: animate,
            ),

            const SizedBox(height: 10),

            _ComparisonRow(
              label: "Daily",
              value: comparison["Daily"] ?? 0,
              isSelected: selectedLabel == "Daily",
              animate: animate,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isSelected;
  final bool animate;

  const _ComparisonRow({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isSelected
            ? Colors.indigo.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isSelected)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.indigo,
                  ),
                ),

              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.indigo : Colors.black87,
                ),
              ),
            ],
          ),

          TweenAnimationBuilder<double>(
            key: ValueKey(animate),
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                CurrencyFormatter.format(animatedValue),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
