import 'package:flutter/material.dart';

class InvestmentBreakdownCard extends StatelessWidget {
  final double investedAmount;
  final double interestEarned;
  final double time;
  final int frequency;

  const InvestmentBreakdownCard({
    super.key,
    required this.investedAmount,
    required this.interestEarned,
    required this.time,
    required this.frequency,
  });

  double get futureValue {
    return investedAmount + interestEarned;
  }

  double get interestShare {
    if (futureValue <= 0) {  
      return 0;
    }
    return interestEarned / futureValue;
  }

  String get frequencyLabel {
    switch (frequency) {
      case 1: return "Annually";
      case 2: return "Swmi-Annually";
      case 4: return "Quarterly";
      case 12: return "Monthly";
      case 365: return "Daily";
      default: return "Uknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Investment Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _BreakdownItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: "Starting Amount",
                    value: investedAmount,
                    color: Colors.indigo,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _BreakdownItem(
                    icon: Icons.trending_up,
                    label: "Interest Earned",
                    value: interestEarned,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _BreakdownItem(
                    icon: Icons.account_balance,
                    label: "Final Value",
                    value: futureValue,
                    color: Colors.indigo,
                  )
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _BreakdownItem(
                    icon: Icons.schedule,
                    label: "Investment Period",
                    value: time,
                    color: Colors.orange,
                    suffix: "Years",
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Growth Composition",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 12,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.12,),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  FractionallySizedBox(widthFactor: futureValue > 0
                    ? investedAmount / futureValue: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text("Compounded ${frequencyLabel.toLowerCase()} • "
                "${(interestShare * 100).toStringAsFixed(1)}% "
                "of your final value came from interest.",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.4,
                ),
            )
          ],
        ),
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final String? suffix;

  const _BreakdownItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),

        const SizedBox(height: 8),

        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),

        const SizedBox(height: 4),

        Text(
          suffix == null ? "₹${value.toStringAsFixed(2)}"
              :  "${value.toStringAsFixed(0)} $suffix",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
