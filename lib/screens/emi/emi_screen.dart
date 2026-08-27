import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../animations/animated_entry.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/animated_currency_value.dart';

class EmiScreen extends StatefulWidget {
  const EmiScreen({super.key});

  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen> {
  final TextEditingController loanController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _compositionKey = GlobalKey();
  final GlobalKey _balanceChartKey = GlobalKey();
  final GlobalKey _metricsKey = GlobalKey();

  bool _compositionVisible = false;
  bool _balanceChartVisible = false;
  bool _metricsVisible = false;

  double emi = 0.0;
  double totalInterest = 0.0;
  double totalPayment = 0.0;
  double loanPrincipal = 0.0;
  double _repaymentProgress = 1.0;
  List<double> repaymentData = [];

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

  void _onScroll() {
    if (!_scrollController.hasClients || !calculated) {
      return;
    }

    final screenHeight = MediaQuery.sizeOf(context).height;

    void checkVisibility(GlobalKey key,
      void Function() onVisible,
    ) {
      final currentContext = key.currentContext;

      if (currentContext == null) {
        return;
      }

      final renderObject = currentContext.findRenderObject();

      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return;
      }

      final position = renderObject.localToGlobal(Offset.zero);
      final cardHeight = renderObject.size.height;
      final visibleHeight = (screenHeight - position.dy).clamp(
        0.0, cardHeight,
      );
      final visiblePercentage = visibleHeight/cardHeight;

      if (visiblePercentage >= 0.5) {
        onVisible();
      }
    }

    if (!_compositionVisible) {
      checkVisibility(
        _compositionKey, () {
          setState(() {
            _compositionVisible = true;
          });
        }
      );
    }

    if (!_balanceChartVisible) {
      checkVisibility(
        _balanceChartKey, () {
          setState(() {
            _balanceChartVisible = true;
          });
        }
      );
    }

    if (!_metricsVisible) {
      checkVisibility(
        _metricsKey, () {
          setState(() {
            _metricsVisible = true;
          });
        }
      );
    }
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
    final schedule = _calculateRepaymentSchedule(
      principal: principal,
      annualRate: annualRate,
      years: years,
      monthlyEmi: monthlyEmi,
    );

    setState(() {
      emi = monthlyEmi;
      totalPayment = payment;
      totalInterest = interest;
      loanPrincipal = principal;
      repaymentData = schedule;
      calculated = true;
      _metricsVisible = false;
      _compositionVisible = false;
      _balanceChartVisible = false;
      _repaymentProgress = 0.0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });

    Future.delayed(
      const Duration(milliseconds: 50), () {
        if (!mounted) return;

        setState(() {
          _repaymentProgress = 1.0;
        });
      }
    );
  }

  List<double> _calculateRepaymentSchedule({
    required double principal,
    required double annualRate,
    required double years,
    required double monthlyEmi,
  }) {
    final monthlyRate = annualRate / 100 / 12;
    final totalMonths = (years * 12).round();
    final balances = <double>[principal];

    double balance = principal;

    for (int month = 1; month <= totalMonths; month++) {
      final interestForMonth = balance * monthlyRate;
      final principalForMonth = monthlyEmi - interestForMonth;

      balance -= principalForMonth;

      if (balance < 0) {
        balance = 0;
      }

      balances.add(balance);
    }
    return balances;
  }

  int _repaymentChartInterval() {
    final totalMonths = repaymentData.length -1;

    if (totalMonths <= 12) {
      return 2;
    }
    if (totalMonths <= 24) {
      return 4;
    }
    if (totalMonths <= 60) {
      return 12;
    }
    if (totalMonths <= 120) {
      return 24;
    }
    return 36;
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
      _compositionVisible = false;
      _balanceChartVisible = false;
      _metricsVisible = false;
      _repaymentProgress = 1.0;
      repaymentData = [];
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
    _scrollController.addListener(_onScroll);
  }

  void _onInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    loanController.removeListener(_onInputChanged);
    rateController.removeListener(_onInputChanged);
    tenureController.removeListener(_onInputChanged);
    _scrollController.removeListener(_onScroll);

    loanController.dispose();
    rateController.dispose();
    tenureController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EMI Calculator")),
      body: SizedBox.expand(
        child: GradientBackground(
          child: SingleChildScrollView(
            controller: _scrollController,
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
                            horizontal: 24,
                            vertical: 20,
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

                              AnimatedCurrencyValue(
                                value: emi,
                                fontSize: 34,
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

                  Container(
                    key: _metricsKey,
                    child: _metricsVisible ? 
                      LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 700;
                        final interestCard = AnimatedEntry(
                          delay: const Duration(milliseconds: 150),
                          duration: const Duration(milliseconds: 850),
                          child: _EmiMetricCard(
                            label: "Total Interest",
                            value: totalInterest,
                            icon: Icons.trending_up,
                          ),
                        );
                        final paymentCard = AnimatedEntry(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 850),
                          child: _EmiMetricCard(
                            label: "Total Payment",
                            value: totalPayment,
                            icon: Icons.payments_outlined,
                          ),
                        );

                        if (!isWide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: interestCard,
                              ),

                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: paymentCard,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: interestCard,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: paymentCard,
                            ),
                          ],
                        );
                      },
                    ): const SizedBox(height: 150,),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    key: _compositionKey,
                    child: _compositionVisible
                        ? AnimatedEntry(
                          delay: Duration.zero,
                          duration: const Duration(milliseconds: 850),
                          child: SizedBox(
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
                                    const Text(
                                      "Repayment Composition",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    const Text(
                                      "See how your total payment is divided.",
                                      style: TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 20),

                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        height: 18,
                                        width: double.infinity,
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final principalRatio = totalPayment > 0
                                                ? loanPrincipal / totalPayment
                                                : 0.0;

                                            final interestRatio = totalPayment > 0
                                                ? totalInterest / totalPayment
                                                : 0.0;

                                            return Row(
                                              children: [
                                                SizedBox(
                                                  width:
                                                      constraints.maxWidth * principalRatio,
                                                  height: 18,
                                                  child: const DecoratedBox(
                                                    decoration: BoxDecoration(color: Colors.indigo),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      constraints.maxWidth * interestRatio,
                                                  height: 18,
                                                  child: const DecoratedBox(
                                                    decoration: BoxDecoration(color: Colors.orange),
                                                  )
                                                ),
                                              ],
                                            );
                                          },
                                        ),
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
                        ): const SizedBox(height: 220,)
                  ),
                  const SizedBox(height: 20),

                  Container(
                    key: _balanceChartKey,
                    child: _balanceChartVisible 
                        ? AnimatedEntry(
                          delay: Duration.zero,
                          duration: const Duration(milliseconds: 850),
                          child: SizedBox(
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
                                    const Text(
                                      "Loan Balance Over Time",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    const Text(
                                      "See how your outstanding balance falls with each payment",
                                      style: TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 20),
                
                                    SizedBox(
                                      height: 240,
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0.0,
                                          end: _repaymentProgress,
                                        ),
                                        duration: const Duration(milliseconds: 1400),
                                        curve: Curves.easeInOutCubic,
                                        builder: (context, progress, child) {
                                          final visibleCount = (repaymentData.length * progress)
                                              .ceil().clamp(1, repaymentData.length);

                                          final visibleData = repaymentData.take(visibleCount).toList();

                                          final spots = List.generate(visibleData.length,
                                            (index) => FlSpot(
                                              index.toDouble(), visibleData[index],
                                            )
                                          ); 

                                          return LineChart(
                                            LineChartData(
                                              minX: 0,
                                              maxX: (repaymentData.length - 1).toDouble(),
                                              minY: 0,
                                              maxY: loanPrincipal,
                                              gridData: const FlGridData(show: false),
                                              borderData: FlBorderData(show: true,
                                                border: Border(
                                                  left: BorderSide(color: Colors.black12),
                                                  bottom: BorderSide(color: Colors.black12)
                                                )
                                              ),
                                              lineTouchData: LineTouchData(enabled: true,
                                                handleBuiltInTouches: true,
                                                touchTooltipData: LineTouchTooltipData(
                                                  getTooltipItems: (touchedSpots) {
                                                    return touchedSpots.map((spot) {
                                                      return LineTooltipItem(
                                                        "Month ${spot.x.toInt()}\n"
                                                        "Balance ₹${spot.y.toStringAsFixed(2)}",
                                                        const TextStyle(fontWeight: FontWeight.w600),
                                                      );
                                                    }).toList();
                                                  }
                                                )
                                              ),
                                              titlesData: FlTitlesData(
                                                topTitles: const AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                                rightTitles: const AxisTitles(
                                                  sideTitles: SideTitles(showTitles: false),
                                                ),
                                                leftTitles: AxisTitles(
                                                  sideTitles: SideTitles(showTitles: true,
                                                    reservedSize: 55,
                                                    getTitlesWidget: (value, meta) {
                                                      if (value == 0) {
                                                        return const Text("₹0",
                                                          style: TextStyle(fontSize: 10),
                                                        );
                                                      }

                                                      if ((value - loanPrincipal).abs() < 0.01) {
                                                        return Text(
                                                          "₹${loanPrincipal.toStringAsFixed(0)}",
                                                          style: const TextStyle(fontSize: 10),
                                                        );
                                                      }
                                                      return const SizedBox.shrink();
                                                    }
                                                  )
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(showTitles: true,
                                                    interval: _repaymentChartInterval().toDouble(),
                                                    reservedSize: 30,
                                                    getTitlesWidget: (value, meta) {
                                                      final month = value.toInt();

                                                      if (month < 0 || month >= repaymentData.length) {
                                                        return const SizedBox.shrink();
                                                      }

                                                      return Text("M$month",
                                                        style: const TextStyle(fontSize: 10)
                                                      );
                                                    }
                                                  )
                                                )
                                              ),
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: spots,
                                                  isCurved: true,
                                                  color: Colors.indigo,
                                                  barWidth: 4,
                                                  dotData: const FlDotData(show: false),
                                                  belowBarData: BarAreaData(
                                                    show: true,
                                                    color: Colors.indigo.withValues(
                                                      alpha: 0.1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ): const SizedBox(height: 330,),         
                  )
                ],
              ],
            ),
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

              AnimatedCurrencyValue(
                value: value,
                fontSize: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


