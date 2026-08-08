import 'package:flutter/material.dart';
import '../../widgets/app_text_field.dart';
import 'dart:math';
import '../../widgets/primary_button.dart';
import '../../widgets/result_card.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/growth_chart_card.dart';

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

void calculateCompoundInterest() {
  final double? principal =
      double.tryParse(principalController.text);

  final double? rate =
      double.tryParse(rateController.text);

  final double? time =
      double.tryParse(timeController.text);

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

  final double result = principal *
      pow(1 + (rate / 100) / frequency,
        frequency * time,
      );

  final List<double> yearlyGrowth = [];

  for (int year = 0; year <= time; year++) {
    final double amount = principal * 
        pow(1 + (rate / 100) / frequency,
        frequency * year);

    yearlyGrowth.add(amount);
  }

  setState(() {
    futureValue = result;
    growthData = yearlyGrowth;
  });
}

void showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

  @override
  void dispose() {
    principalController.dispose();
    rateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compound Interest"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Compound Interest Calculator",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Calculate how your investments grow over time.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

          // Principal Amount Field
            const SizedBox(height: 30),

            AppTextField(
              controller: principalController,
              label: "Principal Amount",
              icon: Icons.account_balance_wallet,
              keyboardType: TextInputType.number,
            ),  

            const SizedBox(height: 20),

            // Interest Rate Field
            AppTextField(
              controller: rateController,
              label: "Annual Interest Rate (%)",
              icon: Icons.percent,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // Time Field
            AppTextField(
              controller: timeController,
              label: "Time (Years)",
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: frequency,
              decoration: InputDecoration(
                labelText: "Compounding Frequency",
                prefixIcon: const Icon(Icons.repeat),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: 1,
                  child: Text("Annually"),
                ),
                  DropdownMenuItem(
                  value: 2,
                  child: Text("Semi-Annually"),
                ),
                  DropdownMenuItem(
                  value: 4,
                  child: Text("Quarterly"),
                ),
                  DropdownMenuItem(
                  value: 12,
                  child: Text("Monthly"),
                ),
                  DropdownMenuItem(
                  value: 365,
                  child: Text("Daily"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  frequency = value ?? 1;
                });
              },
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              text: "Calculate",
              icon: Icons.calculate,
              onPressed: calculateCompoundInterest,
            ),

            const SizedBox(height: 30),

            ResultCard(
              title: "Future Value",
              value: "₹${futureValue.toStringAsFixed(2)}",
              subtitle: "Total amount after your selected period",
            ),

            if (growthData.isNotEmpty) ...[
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
                          showTitles: true, interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Text("Year ${value.toInt()}",
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
                            return Text( "₹${value.toInt()}",
                            style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          growthData.length, (index) => FlSpot(
                            index.toDouble(), growthData[index],
                          ),
                        ),
                        isCurved: true,
                        color: Colors.indigo,
                        barWidth: 4, 
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true,
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
    ); 
  }
}
              