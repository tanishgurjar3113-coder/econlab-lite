import 'package:econlab_lite/widgets/home_hero.dart';
import 'package:flutter/material.dart';
import '../../widgets/tool_card.dart';
import '../compound_interest/compound_interest_screen.dart';
import '../inflation/inflation_screen.dart';
import '../emi/emi_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _toolsKey = GlobalKey();

  void _scrollToTools() {
    final context = _toolsKey.currentContext;

    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(context,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(children: [
          HomeHero(onExploreTools: _scrollToTools),

          Container(
            key: _toolsKey,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}