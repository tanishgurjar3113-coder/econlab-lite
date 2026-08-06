import 'package:flutter/material.dart';
import '../../widgets/tool_card.dart';
import '../../widgets/hero_section.dart';
import '../compound_interest/compound_interest_screen.dart';
import '../inflation/inflation_screen.dart';
import '../emi/emi_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EconLab Lite"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const HeroSection(),

            const SizedBox(height: 30),

            const Text(
              "Financial Tools",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ToolCard(
              icon: Icons.trending_up,
              title: "Compound Interest",
              subtitle: "Grow your investments over time",
              
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompoundInterestScreen(),
                  ),
                );
              },
            ),

            ToolCard(
              icon: Icons.show_chart,
              title: "Inflation Calculator",
              subtitle: "Measure your purchasing power",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InflationScreen(),
                  ),
                );
              }
            ),

            ToolCard(
              icon: Icons.account_balance,
              title: "EMI Calculator",
              subtitle: "Plan your loan repayments",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmiScreen(),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}