import 'package:econlab_lite/utils/currency_formatter.dart';
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

  final GlobalKey _infoKey = GlobalKey();
  bool _infoVisible = false;

  final GlobalKey _breakdownPairKey = GlobalKey();
  bool _resultPairVisible = false;
  bool _breakdownPairVisible = false;

  double futureValue = 0.0;

  List<double> growthData = [];

  List<double> growthTimes = [];

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

    if (width < 1000) {
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

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 1200;

    // Investment Breakdown + Compounding Comparison
    if (isWideScreen && !_breakdownPairVisible && growthData.isNotEmpty) {
      final pairContext = _breakdownPairKey.currentContext;

      if (pairContext != null) {
        final renderObject = pairContext.findRenderObject();

        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);

          final screenHeight = MediaQuery.sizeOf(context).height;
          final rowHeight = renderObject.size.height;
          final visibleHeight = (screenHeight - position.dy)
              .clamp(0.0, rowHeight);
          
          final visiblePercentage = visibleHeight / rowHeight;

          if (visiblePercentage >= 0.5) {
            setState(() {
              _breakdownPairVisible = true;
            });
          }
        }
      }
    }

    if (!isWideScreen && !_breakdownVisible && growthData.isNotEmpty) {
      final breakdownContext = _breakdownKey.currentContext;

      if (breakdownContext != null) {
        final renderObject = breakdownContext.findRenderObject();

        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);

          final screenHeight = MediaQuery.sizeOf(context).height;
          final cardHeight = renderObject.size.height;
          final visibleHeight = (screenHeight - position.dy).clamp(0.0, cardHeight);
          final visiblePercentage = visibleHeight / cardHeight;

          if (visiblePercentage >= 0.5) {
            setState(() {
              _breakdownVisible = true;
            });
          }
        }
      }
    }

    if (!isWideScreen && !_comparisonVisible && growthData.isNotEmpty) {
      final comparisonContext = _comparisonKey.currentContext;

      if (comparisonContext != null) {
        final renderObject = comparisonContext.findRenderObject();

        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);

          final screenHeight = MediaQuery.sizeOf(context).height;
          final cardHeight = renderObject.size.height;
          final visibleHeight = (screenHeight - position.dy).clamp(0.0, cardHeight);
          final visiblePercentage = visibleHeight / cardHeight;

          if (visiblePercentage >= 0.5) {
            setState(() {
              _comparisonVisible = true;
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
          if (visiblePercentage >= 0.5) {
            setState(() {
              _insightVisible = true;
            });
          }
        }
      }
    }

    if (!_infoVisible && growthData.isNotEmpty) {
      final infoContext = _infoKey.currentContext;

      if (infoContext != null) {
        final renderObject = infoContext.findRenderObject();

        if (renderObject is RenderBox && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);

          final screenHeight = MediaQuery.sizeOf(infoContext).height;
          final cardHeight = renderObject.size.height;
          final visibleHeight = (screenHeight - position.dy).clamp(
            0.0,
            cardHeight,
          );

          final visiblePercentage = visibleHeight / cardHeight;
          if (visiblePercentage >= 0.5) {
            setState(() {
              _infoVisible = true;
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
          if (visiblePercentage >= 0.5) {
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

    final List<double> calculatedGrowth = [];
    final List<double> calculatedTimes = [];

    final int fullYears = time.floor();

    for (int year = 0; year <= time; year++) {
      final double amount = _calculateFutureValue(
        principal: principal,
        rate: rate,
        time: year.toDouble(),
        frequency: frequency,
      );

      calculatedGrowth.add(amount);
      calculatedTimes.add(year.toDouble());
    }

    if (time > fullYears) {
      final double amount = _calculateFutureValue(
        principal: principal,
        rate: rate,
        time: time,
        frequency: frequency,
      );

      calculatedGrowth.add(amount);
      calculatedTimes.add(time);
    }

    setState(() {
      futureValue = result;
      growthData = calculatedGrowth;
      growthTimes = calculatedTimes;
      investedAmount = principal;
      compoundingComparison = comparison;

      _resultPairVisible = true;
      _breakdownVisible = false;
      _chartVisible = false;
      _comparisonVisible = false;
      _insightVisible = false;
      _infoVisible = false;
      _breakdownPairVisible = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
  }

  List<FlSpot> _animatedGrowthSpots(double progress) {
    if (growthData.isEmpty || growthTimes.isEmpty) {
      return [];
    }

    if (progress <= 0) {
      return [FlSpot(growthTimes.first, growthData.first)];
    }

    if (progress >= 1) {
      return List.generate(
        growthData.length,
        (index) => FlSpot(growthTimes[index], growthData[index]),
      );
    }

    final double maxIndex = progress * (growthData.length - 1);

    final int completedIndex = maxIndex.floor();
    final List<FlSpot> spots = [];

    for (int i = 0; i <= completedIndex; i++) {
      spots.add(FlSpot(growthTimes[i], growthData[i]));
    }

    if (completedIndex < growthData.length - 1) {
      final int nextIndex = completedIndex + 1;

      final double localProgress = maxIndex - completedIndex;
      final double currentTime = growthTimes[completedIndex];
      final double nextTime = growthTimes[nextIndex];

      final double currentValue = growthData[completedIndex];
      final double nextValue = growthData[nextIndex];

      final double interpolatedTime =
          currentTime + (nextTime - currentTime) * localProgress;
      final double interpolatedValue =
          currentValue + (nextValue - currentValue) * localProgress;

      spots.add(FlSpot(interpolatedTime, interpolatedValue));
    }

    return spots;
  }

  double _chartXPadding() {
    final totalYears = growthData.length - 1;

    if (totalYears <= 10) {
      return 0.35;
    }

    if (totalYears <= 25) {
      return 0.5;
    }
    return 0.75;
  }

  int _chartYearInterval() {
    if (growthTimes.isEmpty) {
      return 1;
    }
    final double totalYears = growthTimes.last;

    if (totalYears <= 6) {
      return 1;
    }
    if (totalYears <= 12) {
      return 2;
    }
    if (totalYears <= 24) {
      return 4;
    }
    if (totalYears <= 40) {
      return 5;
    }
    if (totalYears <= 80) {
      return 10;
    }

    return 20;
  }

  double _chartMaxX() {
    if (growthTimes.isEmpty) {
      return 1;
    }
    return growthTimes.last + _chartXPadding();
  }

  double _chartMinY() {
    if (growthData.isEmpty) {
      return 0;
    }

    final minValue = investedAmount;
    final maxValue = futureValue;

    if (minValue == maxValue) {
      return minValue - 1;
    }

    final range = maxValue - minValue;

    return minValue - range * 0.08;
  }

  double _chartMaxY() {
    if (growthData.isEmpty) {
      return 1;
    }

    final minValue = investedAmount;
    final maxValue = futureValue;

    if (minValue == maxValue) {
      return maxValue + 1;
    }

    final range = maxValue - minValue;

    return maxValue + range * 0.08;
  }

  //Clears input and returns the calculator to its initial state
  void resetCalculator() {
    principalController.clear();
    rateController.clear();
    timeController.clear();

    setState(() {
      futureValue = 0.0;
      growthData = [];
      growthTimes = [];
      investedAmount = 0.0;
      frequency = 1;
      _breakdownVisible = false;
      _chartVisible = false;
      _comparisonVisible = false;
      _insightVisible = false;
      _infoVisible = false;
      _resultPairVisible = false;
      _breakdownPairVisible = false;
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
    final isWideScreen = MediaQuery.sizeOf(context).width >= 1200;
    
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

              if (isWideScreen) ...[
                _responsiveRow(
                  context: context,
                  left: Container(
                    child: _resultPairVisible ?
                        AnimatedEntry(
                          delay: Duration.zero,
                          duration: const Duration(milliseconds: 850),
                          child: ResultCard(
                            title: "Fuure Value",
                            value: futureValue,
                            subtitle: "Total amount after your selected period",
                          ),
                        ): const SizedBox(height: 135,),
                  ),
                  right: Container(
                    child: _resultPairVisible ?
                        AnimatedEntry(
                          delay: Duration.zero,
                          duration: const Duration(milliseconds: 850,),
                          child: InvestmentInsightCard(
                            investedAmount: investedAmount,
                            futureValue: futureValue,
                          ),
                        ): const SizedBox(height: 135,),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ResultCard(
                    title: "Future Value",
                    value: futureValue,
                    subtitle: "Total amount after your selected period",
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  key: _insightKey,
                  child: _insightVisible ?
                      AnimatedEntry(
                        delay: Duration.zero,
                        duration: const Duration(milliseconds: 850),
                        child: InvestmentInsightCard(
                        investedAmount: investedAmount,
                        futureValue: futureValue,
                        ),
                      ): const SizedBox(height: 135,),
                ),
              ],

              const SizedBox(height: 24),

              if (growthData.isNotEmpty) ...[
                const SizedBox(height: 24),

              Container(
                key: _breakdownPairKey,
                child: _responsiveRow(
                  context: context,
                  left: Container(
                    key: _breakdownKey,
                    child: isWideScreen
                       ? (_breakdownPairVisible
                            ? AnimatedEntry(
                                delay: Duration.zero,
                                duration: const Duration(milliseconds: 850,),
                                child: InvestmentBreakdownCard(
                                  investedAmount: investedAmount,
                                  interestEarned: futureValue - investedAmount,
                                  time: double.tryParse(timeController.text) ?? 0,
                                  frequency: frequency,
                                ),
                              ): const SizedBox(height: 135))
                            : (_breakdownVisible ?
                            AnimatedEntry(
                              delay: Duration.zero,
                              duration: const Duration(milliseconds: 850),
                              child: InvestmentBreakdownCard(
                                investedAmount: investedAmount,
                                interestEarned: futureValue - investedAmount,
                                time: double.tryParse(timeController.text) ?? 0,
                                frequency: frequency,
                              ),
                            ): const SizedBox(height: 135,)),
                          ),
                      right: Container(
                        key: _comparisonKey,
                        child: isWideScreen ?
                        (_breakdownPairVisible
                          ? AnimatedEntry(
                            delay: Duration.zero,
                            duration: const Duration(milliseconds: 850,),
                            child: CompoundingComparisonCard(
                              comparison: compoundingComparison,
                              selectedFrequency: frequency,
                              animate: true,
                            ),
                          ): const SizedBox(height: 340,))
                          : (_comparisonVisible ? 
                          AnimatedEntry(
                            delay: Duration.zero,
                            duration: const Duration(milliseconds: 850,),
                            child: CompoundingComparisonCard(
                              comparison: compoundingComparison,
                              selectedFrequency: frequency,
                              animate: true,
                            ),
                          ): const SizedBox(height: 340)),
                      ),
                    ),
              ),
                const SizedBox(height: 16),

                Container(
                  key: _infoKey,
                  child: _infoVisible ? 
                      AnimatedEntry(
                        delay: Duration.zero,
                        duration: const Duration(milliseconds: 850,),
                        child: const CompoundInterestInfoCard(),
                      ) : const SizedBox(height: 220,),
                ),

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
                      child: SizedBox(
                        width: double.infinity,
                        child: GrowthChartCard(
                          title: "Investment Growth",
                          chart: Padding(
                            padding: const EdgeInsetsGeometry.symmetric(
                              horizontal: 20,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: AspectRatio(
                                aspectRatio: 2.15,
                                child: LineChart(
                                  LineChartData(
                                    minX: -_chartXPadding(),
                                    maxX: _chartMaxX(),
                                    minY: _chartMinY(),
                                    maxY: _chartMaxY(),

                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border(
                                        left: BorderSide(
                                          color: Colors.black.withValues(alpha: 0.18),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    lineTouchData: LineTouchData(
                                      enabled: true,
                                      handleBuiltInTouches: true,
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            return LineTooltipItem(
                                              "Year ${spot.x.toInt()}\n"
                                              "${CurrencyFormatter.format(spot.y)}",
                                              const TextStyle(fontWeight: FontWeight.w600,),
                                            );
                                          }).toList();
                                        }
                                      )
                                    ),

                                    extraLinesData: ExtraLinesData(
                                      horizontalLines: [
                                        HorizontalLine(y: investedAmount,
                                            strokeWidth: 1,
                                            color: Colors.indigo.withValues(alpha: 0.18,),
                                            dashArray: [6, 6],
                                        ),
                                      ],
                                    ),
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false,
                                          reservedSize: 0,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          reservedSize: 32,
                                          getTitlesWidget: (value, meta) {
                                            final double totalYears = growthTimes.last;

                                            if (value < 0) {
                                              return const SizedBox.shrink();
                                            }

                                            final year = value.round();
                                            if ((value - year).abs() > 0.01) {
                                              return const SizedBox.shrink();
                                            }

                                            if (year > totalYears) {
                                              return const SizedBox.shrink();
                                            }
                                            final interval = _chartYearInterval();

                                            final isRegularTick = year % interval == 0;

                                            if (!isRegularTick && year != totalYears) {
                                              return const SizedBox.shrink();
                                            }

                                            if (year == totalYears && !isRegularTick) {
                                              final previousTick = (totalYears ~/ interval) * interval;
                                              final gap = totalYears - previousTick;
                                              final minimumGap = interval * 0.7;

                                              if (gap < minimumGap) {
                                                return const SizedBox.shrink();
                                              }
                                            }

                                            return SideTitleWidget(
                                              meta: meta, space: 6,
                                              fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                                              child: Text(
                                                "Year $year",
                                              style: const TextStyle(fontSize: 10),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 75,
                                          interval: _chartMaxY() - _chartMinY(),
                                          getTitlesWidget: (value, meta) {
                                            final minY = _chartMinY();
                                            final maxY = _chartMaxY();

                                            if ((value - minY).abs() < 0.01) {
                                              return SideTitleWidget(
                                                meta: meta, space: 6,
                                                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                                                child: Text(
                                                  CurrencyFormatter.format(investedAmount),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  )
                                                ),
                                              );
                                            }

                                            if ((value - maxY).abs() < 0.01) {
                                              return SideTitleWidget(
                                                meta: meta, space: 6,
                                                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                                                child: Text(
                                                  CurrencyFormatter.format(futureValue),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  )
                                                ),
                                              );
                                            }
                                            
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                    ),

                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _animatedGrowthSpots(progress),
                                        isCurved: true,
                                        color: Colors.indigo,
                                        barWidth: 4.5,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.indigo.withValues(alpha: 0.10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
