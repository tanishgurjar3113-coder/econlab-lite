import 'dart:math';
import 'package:flutter/material.dart';
import '../../animations/animated_entry.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/primary_button.dart';

class EmiScreen extends StatefulWidget {
  const EmiScreen({super.key});

  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen> {
  final TextEditingController loanController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();

  double emi = 0.0;
  double totalInterest = 0.0;
  double totalPayment = 0.0;
  double loanPrincipal = 0.0;

  bool calculated = false;

  bool get canCalculate {
    return loanController.text.trim().isNotEmpty &&
        rateController.text.trim().isNotEmpty &&
        tenureController.text.trim().isNotEmpty;
  }

  double _calculateEmi({
    required double principal,
    required double annualRate,
    required double years,
  }) {
    final monthlyRate = annualRate / 100 / 12;
    final totalMonths = (years * 12).round();

    if (totalMonths <= 0) {
      return 0.0;
    }

    if (monthlyRate == 0) {
      return principal / totalMonths;
    }

    final factor = pow(1 + monthlyRate, totalMonths);

    return principal * monthlyRate * factor / (factor - 1);
  }

  void calculateEmi() {
    final principalInput = double.tryParse(loanController.text);

    final annualRateInput = double.tryParse(rateController.text);
    final yearsInput = double.tryParse(tenureController.text);

    if (principalInput == null || principalInput <= 0) {
      _showError("Please enter a valid loan amount.");
      return;
    }

    if (annualRateInput == null || annualRateInput < 0) {
      _showError("Please enter a valud interest rate.");
      return;
    }

    if (yearsInput == null || yearsInput <= 0) {
      _showError("Please enter a valid loan tenure.");
      return;
    }
    final double principal = principalInput;
    final double annualRate = annualRateInput;
    final double years = yearsInput;

    final monthlyEmi = _calculateEmi(
      principal: principal,
      annualRate: annualRate,
      years: years,
    );

    final months = (years * 12).round();
    final payment = monthlyEmi * months;
    final interest = payment - principal;

    setState(() {
      emi = monthlyEmi;
      totalPayment = payment;
      totalInterest = interest;
      loanPrincipal = principal;
      calculated = true;
    });
  }

  void resetCalculator() {
    loanController.clear();
    rateController.clear();
    tenureController.clear();

    setState(() {
      emi = 0.0;
      totalPayment = 0.0;
      totalInterest = 0.0;
      loanPrincipal = 0.0;
      calculated = false;
    });

    FocusScope.of(context).unfocus();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();

    loanController.addListener(_onInputChanged);
    rateController.addListener(_onInputChanged);
    tenureController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    loanController.removeListener(_onInputChanged);
    rateController.removeListener(_onInputChanged);
    tenureController.removeListener(_onInputChanged);

    loanController.dispose();
    rateController.dispose();
    tenureController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EMI Calculator")),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedEntry(
                delay: const Duration(milliseconds: 100),
                child: const Text(
                  "EMI Calculator",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Plan your loan repayments with clarity.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              AnimatedEntry(
                delay: const Duration(milliseconds: 200),
                child: AppTextField(
                  controller: loanController,
                  label: "Loan Amount",
                  icon: Icons.account_balance,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),

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

              AnimatedEntry(
                delay: const Duration(milliseconds: 400),
                child: AppTextField(
                  controller: tenureController,
                  label: "Loan Tenure (Years)",
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: canCalculate
                    ? PrimaryButton(
                        key: const ValueKey("Calculate"),
                        text: "Calculate",
                        icon: Icons.calculate,
                        onPressed: calculateEmi,
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

              if (calculated) ...[
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: AnimatedEntry(
                    delay: Duration.zero,
                    duration: const Duration(milliseconds: 850),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Monthly EMI",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              "₹${emi.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            const Text(
                              "Your estimated monthly repayment",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;

                    if (!isWide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: AnimatedEntry(
                              delay: Duration.zero,
                              duration: const Duration(milliseconds: 850),
                              child: _EmiMetricCard(
                                label: "Total Interest",
                                value: totalInterest,
                                icon: Icons.trending_up,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: AnimatedEntry(
                              delay: Duration.zero,
                              duration: const Duration(milliseconds: 850),
                              child: _EmiMetricCard(
                                label: "Total Payment",
                                value: totalPayment,
                                icon: Icons.payments_outlined,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AnimatedEntry(
                            delay: Duration.zero,
                            duration: const Duration(milliseconds: 850),
                            child: _EmiMetricCard(
                              label: "Total Interest",
                              value: totalInterest,
                              icon: Icons.trending_up,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: AnimatedEntry(
                            delay: Duration.zero,
                            duration: const Duration(milliseconds: 850),
                            child: _EmiMetricCard(
                              label: "Total Payment",
                              value: totalPayment,
                              icon: Icons.payments_outlined,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Repayment Composition",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            "See how your total payment is divided.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 18,
                              width: double.infinity,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final principalRatio = totalPayment > 0 ?
                                    loanPrincipal/totalPayment: 0.0;

                                  final interestRatio = totalPayment > 0 ?
                                    totalInterest/totalPayment: 0.0;

                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: constraints.maxWidth * principalRatio,
                                        child: Container(color: Colors.indigo,),
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth * interestRatio,
                                        child: Container(color: Colors.orange,),
                                      )
                                    ],
                                  );
                                }
                              )
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Principal",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "₹${loanPrincipal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Interest",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "₹${totalInterest.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),       
                        ],
                      ),
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

class _EmiMetricCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _EmiMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: Colors.indigo),

              const SizedBox(height: 12),

              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),

              Text(
                "₹${value.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
