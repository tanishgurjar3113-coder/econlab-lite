import 'package:flutter/material.dart';
import '../../widgets/app_text_field.dart';
import 'dart:math';
import '../../widgets/primary_button.dart';
import '../../widgets/result_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/growth_chart_card.dart';
import '../../widgets/investment_breakdown_card.dart';
import '../../widgets/gradient_background.dart';
import '../../animations/animated_entry.dart';
import '../../widgets/investment_insight_card.dart';
import '../../widgets/compound_interest_info_card.dart';
import '../../widgets/compounding_comparison_card.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  //Controllers
  final TextEditingController principalController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _breakdownKey = GlobalKey();
  bool _breakdownVisible = false;

  final GlobalKey _comparisonKey = GlobalKey();
  bool _comparisonVisible = false;

  final GlobalKey _chartKey = GlobalKey();
  bool _chartVisible = false;

  final GlobalKey _insightKey = GlobalKey();
  bool _insightVisible = false;

  double futureValue = 0.0;

  List<double> growthData = [];

  int frequency = 1;

  double investedAmount = 0.0;
  Map<String, double> compoundingComparison = {};

  bool get canCalculate {
    return principalController.text.trim().isNotEmpty &&
        rateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty;
  }

  Widget _responsiveRow({
    required BuildContext context,
    required Widget left,
    required Widget right,
  }) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 800) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: double.infinity, child: left),

          const SizedBox(height: 16),

          SizedBox(width: double.infinity, child: right),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(width: double.infinity, child: left),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: SizedBox(width: double.infinity, child: right),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    principalController.addListener(_onInputChanged);
    rateController.addListener(_onInputChanged);
    timeController.addListener(_onInputChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onInputChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    //Investment Breakdown Card
    if (!_breakdownVisible && growthData.isNotEmpty) {
      final breakdownContext = _breakdownKey.currentContext;

      if (breakdownContext != null) {
        final renderObject = breakdownContext.findRenderObject();

        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);

          final screenHeight = MediaQuery.sizeOf(breakdownContext).height;
          final cardHeight = renderObject.size.height;
          final visibleHeight = (screenHeight - position.dy).clamp(
            0.0,
            cardHeight,
          );

          final visiblePercentage = visibleHeight / cardHeight;
          if (visiblePercentage >= 0.8) {
            setState(() {
              _breakdownVisible = true;
            });
          }
        }
      }
    }

    if (!_insightVisible && growthData.isNotEmpty) {
      final insightContext = _insightKey.currentContext;

      if (insightContext != null) {
        final renderObject = insightContext.findRenderObject();

        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);

          final screenHeight = MediaQuery.sizeOf(insightContext).height;
          final cardHeight = renderObject.size.height;
          final visibleHeight = (screenHeight - position.dy).clamp(
            0.0,
            cardHeight,
          );

          final visiblePercentage = visibleHeight / cardHeight;
          if (visiblePercentage >= 0.8) {
            setState(() {
              _insightVisible = true;
            });
          }
        }
      }
    }

    //Compounding Frequency Comparison Card
    if (!_comparisonVisible && growthData.isNotEmpty) {
      final comparisonContext = _comparisonKey.currentContext;

      if (comparisonContext != null) {
        final renderObject = comparisonContext.findRenderObject();

        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);

          final screenHeight = MediaQuery.sizeOf(comparisonContext).height;

          final cardHeight = renderObject.size.height;

          final visibleHeight = (screenHeight - position.dy).clamp(
            0.0,
            cardHeight,
          );
          final visiblePercentage = visibleHeight / cardHeight;

          if (visiblePercentage >= 0.3) {
            setState(() {
              _comparisonVisible = true;
            });
          }
        }
      }
    }

    //Growth Chart Card
    if (!_chartVisible && growthData.isNotEmpty) {
      final chartContext = _chartKey.currentContext;

      if (chartContext != null) {
        final renderObject = chartContext.findRenderObject();

        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);
          final screenHeight = MediaQuery.sizeOf(chartContext).height;

          final cardHeight = renderObject.size.height;
          final visibleHeight = (screenHeight - position.dy).clamp(
            0.0,
            cardHeight,
          );

          final visiblePercentage = visibleHeight / cardHeight;
          if (visiblePercentage >= 0.8) {
            setState(() {
              _chartVisible = true;
            });
          }
        }
      }
    }
  }

  double _calculateFutureValue({
    required double principal,
    required double rate,
    required double time,
    required int frequency,
  }) {
    return principal * pow(1 + (rate / 100) / frequency, frequency * time);
  }

  Map<String, double> _calculateCompoundingComparison({
    required double principal,
    required double rate,
    required double time,
  }) {
    return {
      "Annually": _calculateFutureValue(
        principal: principal,
        rate: rate,
        time: time,
        frequency: 1,
      ),
      "Semi-Annually": _calculateFutureValue(
        principal: principal,
        rate: rate,
        time: time,
        frequency: 2,
      ),
      "Quarterly": _calculateFutureValue(
        principal: principal,
        rate: rate,
        time: time,
        frequency: 4,
      ),
      "Monthly": _calculateFutureValue(
        principal: principal,
        rate: rate,
        time: time,
        frequency: 12,
      ),
      "Daily": _calculateFutureValue(
        principal: principal,
        rate: rate,
        time: time,
        frequency: 365,
      ),
    };
  }

  void calculateCompoundInterest() {
    final double? principal = double.tryParse(principalController.text);

    final double? rate = double.tryParse(rateController.text);

    final double? time = double.tryParse(timeController.text);

    if (principal == null || principal <= 0) {
      showError("Please enter a valid principal amount.");
      return;
    }

    if (rate == null || rate < 0) {
      showError("Please enter a valid interest rate");
      return;
    }

    if (time == null || time <= 0) {
      showError("Please enter a valid time period");
      return;
    }

    final comparison = _calculateCompoundingComparison(
      principal: principal,
      rate: rate,
      time: time,
    );

    final double result = _calculateFutureValue(
      principal: principal,
      rate: rate,
      time: time,
      frequency: frequency,
    );

    final List<double> yearlyGrowth = [];

    for (int year = 0; year <= time; year++) {
      final double amount =
          principal * pow(1 + (rate / 100) / frequency, frequency * year);

      yearlyGrowth.add(amount);
    }

    setState(() {
      futureValue = result;
      growthData = yearlyGrowth;
      investedAmount = principal;
      compoundingComparison = comparison;

      _breakdownVisible = false;
      _chartVisible = false;
      _comparisonVisible = false;
      _insightVisible = false;
    });
  }

  List<FlSpot> _animatedGrowthSpots(double progress) {
    if (growthData.isEmpty) {
      return [];
    }

    if (progress <= 0) {
      return [FlSpot(0, growthData.first)];
    }

    if (progress >= 1) {
      return List.generate(
        growthData.length,
        (index) => FlSpot(index.toDouble(), growthData[index]),
      );
    }

    final double maxIndex = progress * (growthData.length - 1);

    final int completedIndex = maxIndex.floor();
    final List<FlSpot> spots = [];

    for (int i = 0; i <= completedIndex; i++) {
      spots.add(FlSpot(i.toDouble(), growthData[i]));
    }

    if (completedIndex < growthData.length - 1) {
      final int nextIndex = completedIndex + 1;

      final double localProgress = maxIndex - completedIndex;
      final double currentValue = growthData[completedIndex];

      final double nextValue = growthData[nextIndex];
      final double interpolatedValue =
          currentValue + (nextValue - currentValue) * localProgress;

      spots.add(FlSpot(completedIndex + localProgress, interpolatedValue));
    }

    return spots;
  }

  double _chartMinY() {
    if (growthData.isEmpty) {
      return 0;
    }

    final minValue = growthData.reduce(min);
    final maxValue = growthData.reduce(max);

    final range = maxValue - minValue;
    final padding = range == 0 ? maxValue * 0.1 : range * 0.08;

    return max(0, minValue - padding);
  }

  double _chartMaxY() {
    if (growthData.isEmpty) {
      return 1;
    }

    final minValue = growthData.reduce(min);
    final maxValue = growthData.reduce(max);

    final range = maxValue - minValue;
    final padding = range == 0 ? maxValue * 0.1 : range * 0.08;

    return maxValue + padding;
  }

  //Clears input and returns the calculator to its initial state
  void resetCalculator() {
    principalController.clear();
    rateController.clear();
    timeController.clear();

    setState(() {
      futureValue = 0.0;
      growthData = [];
      investedAmount = 0.0;
      frequency = 1;
      _breakdownVisible = false;
      _chartVisible = false;
      _comparisonVisible = false;
      _insightVisible = false;
      compoundingComparison = {};
    });

    FocusScope.of(context).unfocus();
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    principalController.removeListener(_onInputChanged);
    rateController.removeListener(_onInputChanged);
    timeController.removeListener(_onInputChanged);
    _scrollController.removeListener(_onScroll);

    _scrollController.dispose();
    principalController.dispose();
    rateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Compound Interest")),
      body: GradientBackground(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedEntry(
                delay: const Duration(milliseconds: 100),
                child: const Text(
                  "Compound Interest Calculator",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Calculate how your investments grow over time.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              // Principal Amount Field
              const SizedBox(height: 30),

              AnimatedEntry(
                delay: const Duration(milliseconds: 200),
                child: AppTextField(
                  controller: principalController,
                  label: "Principal Amount",
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 20),

              // Interest Rate Field
              AnimatedEntry(
                delay: const Duration(milliseconds: 300),
                child: AppTextField(
                  controller: rateController,
                  label: "Annual Interest Rate (%)",
                  icon: Icons.percent,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 20),

              // Time Field
              AnimatedEntry(
                delay: const Duration(milliseconds: 400),
                child: AppTextField(
                  controller: timeController,
                  label: "Time (Years)",
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 16),

              AnimatedEntry(
                delay: const Duration(milliseconds: 500),
                child: DropdownButtonFormField<int>(
                  initialValue: frequency,
                  decoration: InputDecoration(
                    labelText: "Compounding Frequency",
                    prefixIcon: const Icon(Icons.repeat),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Annually")),
                    DropdownMenuItem(value: 2, child: Text("Semi-Annually")),
                    DropdownMenuItem(value: 4, child: Text("Quarterly")),
                    DropdownMenuItem(value: 12, child: Text("Monthly")),
                    DropdownMenuItem(value: 365, child: Text("Daily")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      frequency = value ?? 1;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: canCalculate
                    ? PrimaryButton(
                        key: const ValueKey("calculate"),
                        text: "Calculate",
                        icon: Icons.calculate,
                        onPressed: calculateCompoundInterest,
                      )
                    : const SizedBox.shrink(key: ValueKey("empty")),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: resetCalculator,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset Calculator"),
              ),

              const SizedBox(height: 30),

              _responsiveRow(
                context: context,
                left: ResultCard(
                  title: "Future Value",
                  value: futureValue,
                  subtitle: "Total amount after your selected period",
                ),
                right: Container(
                  key: _insightKey,
                  child: _insightVisible
                      ? AnimatedEntry(
                          delay: Duration.zero,
                          duration: const Duration(milliseconds: 80),
                          child: InvestmentInsightCard(
                            investedAmount: investedAmount,
                            futureValue: futureValue,
                          ),
                        )
                      : const SizedBox(height: 135),
                ),
              ),

              if (growthData.isNotEmpty) ...[
                const SizedBox(height: 24),

                _responsiveRow(
                  context: context,
                  left: Container(
                    key: _breakdownKey,
                    child: _breakdownVisible
                        ? AnimatedEntry(
                            delay: Duration.zero,
                            duration: const Duration(milliseconds: 850),
                            child: InvestmentBreakdownCard(
                              investedAmount: investedAmount,
                              interestEarned: futureValue - investedAmount,
                              time: double.tryParse(timeController.text) ?? 0,

                              frequency: frequency,
                            ),
                          )
                        : const SizedBox(height: 135),
                  ),
                  right: Container(
                    key: _comparisonKey,
                    child: CompoundingComparisonCard(
                      comparison: compoundingComparison,
                      selectedFrequency: frequency,
                      animate: _comparisonVisible,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const CompoundInterestInfoCard(),

                const SizedBox(height: 24),

                TweenAnimationBuilder(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: _chartVisible ? 1.0 : 0.0,
                  ),
                  duration: const Duration(milliseconds: 1600),
                  curve: Curves.easeOutCubic,
                  builder: (context, progress, child) {
                    return Container(
                      key: _chartKey,
                      child: GrowthChartCard(
                        title: "Investment Growth",
                        chart: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: (growthData.length - 1).toDouble(),
                            minY: _chartMinY(),
                            maxY: _chartMaxY(),

                            gridData: const FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      "Year ${value.toInt()}",
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      "₹${value.toInt()}",
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),

                            lineBarsData: [
                              LineChartBarData(
                                spots: _animatedGrowthSpots(progress),
                                isCurved: true,
                                color: Colors.indigo,
                                barWidth: 4,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.indigo.withValues(alpha: 0.12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
