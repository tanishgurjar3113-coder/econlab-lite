import 'package:econlab_lite/widgets/home_hero.dart';
import 'package:econlab_lite/widgets/market_card.dart';
import 'package:flutter/material.dart';
import '../../widgets/tool_card.dart';
import '../compound_interest/compound_interest_screen.dart';
import '../inflation/inflation_screen.dart';
import '../emi/emi_screen.dart';
import '../../models/market_data.dart';
import '../../service/market_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _toolsKey = GlobalKey();
  final MarketDataService _marketDataService = MarketDataService();
  final Map<String, List<double>> _marketHistories = {};
  final GlobalKey _marketKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();

  // ignore: unused_field
  List<MarketData> _marketData = [];

  Future<void> _loadMarketData() async {
    try {
      final data = await _marketDataService.getMarketData();
      final histories = <String, List<double>>{};

      for (final market in data) {
        histories[market.symbol] = await _marketDataService.getPriceHistory(
          market.symbol,
        );
      }

      if (!mounted) return;

      setState(() {
        _marketData = data;
        _marketHistories.clear();
        _marketHistories.addAll(histories);
      });
    } catch (error) {
      debugPrint('Market data error: $error');
    }
  }

  void _scrollToTools() {
    final context = _toolsKey.currentContext;

    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToMarket() {
  final context = _marketKey.currentContext;

  if (context == null) {
    return;
  }

  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeOutCubic,
  );
}

void _scrollToAbout() {
  final context = _aboutKey.currentContext;

  if (context == null) {
    return;
  }

  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeOutCubic,
  );
}

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Widget _buildAboutSection() {
    return Container(
      key: _aboutKey,
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 24,
      ),
      padding: const EdgeInsets.fromLTRB(
        24,
        32,
        24,
        32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About EconLab',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'EconLab is an educational finance platform designed to make '
            'economic and financial concepts easier to understand through '
            'interactive tools, real-world data, and clear explanations.',
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'From understanding inflation and compound interest to exploring '
            'loan repayments and market movements, EconLab brings practical '
            'financial ideas into one accessible learning environment.',
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 20,
                color: Colors.indigo,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Built for learning, exploration, and financial literacy.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketSection() {
    if (_marketData.isEmpty) {
      return const SizedBox.shrink();
    }

    final market = _marketData.first;

    return Container(
      key: _marketKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Snapshot',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              'Latest available market data for Reliance',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),

            const SizedBox(height: 20),

            MarketCard(
              data: market,
              chartPoints: _marketHistories[market.symbol] ?? const [],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HomeHero(
              onExploreTools: _scrollToTools,
              onExploreMarket: _scrollToMarket,
              onAbout: _scrollToAbout,
            ),

            const SizedBox(height: 56),

            _buildMarketSection(),
            const SizedBox(height: 100),

            Container(
              key: _toolsKey,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Financial Tools",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    },
                  ),

                  ToolCard(
                    icon: Icons.account_balance,
                    title: "EMI Calculator",
                    subtitle: "Plan your loan repayments",

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmiScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 100),

                  _buildAboutSection(),

                  const SizedBox(height: 40),
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
