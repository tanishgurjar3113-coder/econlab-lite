import 'package:flutter/material.dart';

class CompoundInterestInfoCard extends StatelessWidget {
  const CompoundInterestInfoCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("How Compound Interest Works",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),

          const SizedBox(height: 12),

          const Text(
            "Compound interest allows your investment to earn"
            " interest on both the original amount and the interest"
            " that has already accumulated.",
            style: TextStyle(
              fontSize: 14, color: Colors.grey, height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.indigo.withValues(alpha: 0.08),
            ),
            child: const Text(
              "FV = P(1 + r/n)ⁿᵗ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricRow(symbol: "P",
              description:"principal amount",
              ),
              _MetricRow(symbol: "r",
              description:"annual interest rate",
              ),
              _MetricRow(symbol: "n",
              description:"compounding frequency",
              ),
              _MetricRow(symbol: "t",
              description:"time period",
              ),
            ],
          )
        ],
      ),
    ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String symbol;
  final String description;

  const _MetricRow({
    required this.symbol,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "$symbol = ",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            )),
            TextSpan(
            text: description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            )),
          ],
        ),
      ),
    );
  }
}