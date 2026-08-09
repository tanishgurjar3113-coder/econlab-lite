import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class InvestmentBreakdownCard extends StatelessWidget{
  final double investedAmount;
  final double interestEarned;

  const InvestmentBreakdownCard({
    super.key,
    required this.investedAmount,
    required this.interestEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Investment Breakdown",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _BreakdownItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: "Invested",
                    value: CurrencyFormatter.format(investedAmount),
                    color: Colors.indigo, 
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _BreakdownItem(
                    icon: Icons.trending_up,
                    label: "Interest Earned",
                    value: CurrencyFormatter.format(interestEarned),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _BreakdownItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color,),

        const SizedBox(height: 8),

        Text(
          label, style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(value, style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        ),
      ],
    );
  }
}