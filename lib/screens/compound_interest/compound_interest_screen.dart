import 'package:flutter/material.dart';
import '../../widgets/app_text_field.dart';
import 'dart:math';
import '../../widgets/primary_button.dart';
import '../../widgets/result_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/growth_chart_card.dart';
import '../../widgets/investment_breakdown_card.dart';
import '../../widgets/gradient_background.dart';
import '../../utils/currency_formatter.dart';
import '../../animations/animated_entry.dart';

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

  double futureValue = 0.0;

  List<double> growthData = [];

  int frequency = 1;

  double investedAmount = 0.0;

  bool get canCalculate {
    return principalController.text.trim().isNotEmpty &&
        rateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    principalController.addListener(_onInputChanged);
    rateController.addListener(_onInputChanged);
    timeController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {});
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

    final double result =
        principal * pow(1 + (rate / 100) / frequency, frequency * time);

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
    });
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

              ResultCard(
                title: "Future Value",
                value: CurrencyFormatter.format(futureValue),
                subtitle: "Total amount after your selected period",
              ),

              if (growthData.isNotEmpty) ...[
                const SizedBox(height: 24),

                InvestmentBreakdownCard(
                  investedAmount: investedAmount,
                  interestEarned: futureValue - investedAmount,
                ),

                const SizedBox(height: 24),

                GrowthChartCard(
                  title: "Investment Growth",
                  chart: LineChart(
                    LineChartData(
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
                          spots: List.generate(
                            growthData.length,
                            (index) =>
                                FlSpot(index.toDouble(), growthData[index]),
                          ),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
