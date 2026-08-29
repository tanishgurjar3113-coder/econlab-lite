import 'package:econlab_lite/widgets/calculator_info_panel.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../animations/animated_entry.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/animated_currency_value.dart';
import '../../models/calculator_info.dart';
import '../../service/calculator_info_service.dart';

class InflationScreen extends StatefulWidget {
  const InflationScreen({super.key});

  @override
  State<InflationScreen> createState() => _InflationScreenState();
}

class _InflationScreenState extends State<InflationScreen> {
  final TextEditingController priceController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _metricsKey = GlobalKey();
  bool _metricsVisible = false;

  final GlobalKey _impactKey = GlobalKey();
  bool _impactVisible = false;

  final GlobalKey _summaryKey = GlobalKey();
  bool _summaryVisible = false;

  final GlobalKey _contributorKey = GlobalKey();
  bool _contributorVisible = false;

  final CalculatorInfoService _calculatorInfoService = CalculatorInfoService();

  List<CalculatorInfo> _calculatorInfo = [];

  double futurePrice = 0;
  double purchasingPower = 0;
  double inflationCost = 0;

  bool calculated = false;

  final List<InflationBasketItem> basketItems = [];

  double basketCurrentTotal = 0;
  double basketFutureTotal = 0;
  double basketIncrease = 0;

  bool basketCalculated = false;

  bool get canCalculate {
    return priceController.text.trim().isNotEmpty &&
        rateController.text.trim().isNotEmpty &&
        timeController.text.trim().isNotEmpty;
  }

  double _calculateFuturePrice({
    required double currentPrice,
    required double inflationRate,
    required double years,
  }) {
    return currentPrice * pow(1 + inflationRate / 100, years);
  }

  double _calculatePurchasingPower({
    required double currentPrice,
    required double inflationRate,
    required double years,
  }) {
    return currentPrice / pow(1 + inflationRate / 100, years);
  }

  double _calculateBasketFuturePrice(InflationBasketItem item, double years) {
    return item.price * pow(1 + item.inflationRate / 100, years);
  }

  double _itemInflationIncrease(InflationBasketItem item, double years) {
    final futurePrice = _calculateBasketFuturePrice(item, years);
    return futurePrice - item.price;
  }

  InflationBasketItem? _largestContributor() {
    if (basketItems.isEmpty) {
      return null;
    }

    InflationBasketItem largest = basketItems.first;
    double largestIncrease = -1;

    final years = double.tryParse(timeController.text);

    if (years == null || years <= 0) {
      return null;
    }

    for (final item in basketItems) {
      final increase = _itemInflationIncrease(item, years);

      if (increase > largestIncrease) {
        largestIncrease = increase;
        largest = item;
      }
    }
    return largest;
  }

  List<Widget> _buildImpactRows() {
    final years = double.tryParse(timeController.text);

    if (years == null || years <= 0) {
      return [];
    }

    final increases = basketItems.map((item) {
      return {"item": item, "increase": _itemInflationIncrease(item, years)};
    }).toList();

    increases.sort(
      (a, b) => (b["increase"] as double).compareTo(a["increase"] as double),
    );

    final totalIncrease = basketIncrease;

    return increases.map((entry) {
      final item = entry["item"] as InflationBasketItem;
      final increase = entry["increase"] as double;
      final ratio = totalIncrease > 0 ? increase / totalIncrease : 0;

      return AnimatedEntry(
        delay: Duration(milliseconds: 200 + (increases.indexOf(entry) * 120)),
        duration: const Duration(milliseconds: 650),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  Text(
                    "₹${increase.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              TweenAnimationBuilder<double>(
                key: ValueKey('${item.name}_${increase.toStringAsFixed(2)}'),
                tween: Tween<double>(
                  begin: 0.0,
                  end: ratio.clamp(0.0, 1.0).toDouble(),
                ),
                duration: const Duration(milliseconds: 1600),
                curve: Curves.easeOutCubic,
                builder: (context, animatedRatio, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: animatedRatio,
                      minHeight: 10,
                      backgroundColor: Colors.black12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.indigo,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _calculateBasket() {
    if (basketItems.isEmpty) {
      _showError("Add at least one expense to your basket.");
      return;
    }

    final years = double.tryParse(timeController.text);

    if (years == null || years <= 0) {
      _showError("Enter a valid time period first.");
      return;
    }

    double currentTotal = 0;
    double futureTotal = 0;

    for (final item in basketItems) {
      currentTotal += item.price;

      futureTotal += _calculateBasketFuturePrice(item, years);
    }

    setState(() {
      basketCurrentTotal = currentTotal;
      basketFutureTotal = futureTotal;
      basketIncrease = futureTotal - currentTotal;
      basketCalculated = true;
    });
  }

  void _addBasketItem() {
    setState(() {
      basketItems.add(
        InflationBasketItem(name: "New Expense", price: 0, inflationRate: 0),
      );

      basketCalculated = false;
    });
  }

  void _removeBasketItem(int index) {
    setState(() {
      basketItems.removeAt(index);
      basketCalculated = false;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !calculated) {
      return;
    }
    final screenHeight = MediaQuery.sizeOf(context).height;

    void checkVisibility(GlobalKey key, void Function() onVisible) {
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
      final visibleHeight = (screenHeight - position.dy).clamp(0.0, cardHeight);
      final visiblePercentage = visibleHeight / cardHeight;

      if (visiblePercentage >= 0.5) {
        onVisible();
      }
    }

    if (!_metricsVisible) {
      checkVisibility(_metricsKey, () {
        setState(() {
          _metricsVisible = true;
        });
      });
    }

    if (!_impactVisible) {
      checkVisibility(_impactKey, () {
        setState(() {
          _impactVisible = true;
        });
      });
    }

    if (!_summaryVisible) {
      checkVisibility(_summaryKey, () {
        setState(() {
          _summaryVisible = true;
        });
      });
    }

    if (!_contributorVisible) {
      checkVisibility(_contributorKey, () {
        setState(() {
          _contributorVisible = true;
        });
      });
    }
  }

  void calculateInflation() {
    final priceInput = double.tryParse(priceController.text);
    final rateInput = double.tryParse(rateController.text);
    final timeInput = double.tryParse(timeController.text);

    if (priceInput == null || priceInput <= 0) {
      _showError("Please enter a valid current price.");
      return;
    }

    if (rateInput == null || rateInput <= 0) {
      _showError("Please enter a valid inflation rate.");
      return;
    }

    if (timeInput == null || timeInput <= 0) {
      _showError("Please enter a valid time period.");
      return;
    }

    final double currentPrice = priceInput;
    final double inflationRate = rateInput;
    final double years = timeInput;

    final calculatedFuturePrice = _calculateFuturePrice(
      currentPrice: currentPrice,
      inflationRate: inflationRate,
      years: years,
    );

    final calculatedPurchasingPower = _calculatePurchasingPower(
      currentPrice: currentPrice,
      inflationRate: inflationRate,
      years: years,
    );

    final calculatedInflationCost = calculatedFuturePrice - currentPrice;

    setState(() {
      futurePrice = calculatedFuturePrice;
      purchasingPower = calculatedPurchasingPower;
      inflationCost = calculatedInflationCost;
      calculated = true;
      _metricsVisible = false;
      _impactVisible = false;
      _summaryVisible = false;
      _contributorVisible = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
  }

  Future<void> _loadCalculatorInfo() async {
    try {
      debugPrint('--- CPI INFO LOAD START ---');

      final data = await _calculatorInfoService.getInfo('inflation');

      debugPrint('SUCCESS: received ${data.length} rows');

      for (final item in data) {
        debugPrint('${item.sectionNumber}: ${item.title}',);
      }

      if (!mounted) return;

      setState(() {
        _calculatorInfo = data;
      });
    } catch (error, stackTrace) {
      debugPrint('!!! CALCULATOR INFO ERROR !!!');

      debugPrint('Error: $error');

      debugPrint('Stack trace: $stackTrace');
    }
  }

  void resetCalculator() {
    priceController.clear();
    rateController.clear();
    timeController.clear();

    setState(() {
      futurePrice = 0;
      inflationCost = 0;
      purchasingPower = 0;
      calculated = false;
      _metricsVisible = false;
      _impactVisible = false;
      _summaryVisible = false;
      _contributorVisible = false;
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

    priceController.addListener(_onInputChanged);
    rateController.addListener(_onInputChanged);
    timeController.addListener(_onInputChanged);
    _scrollController.addListener(_onScroll);
    _loadCalculatorInfo();
  }

  void _onInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    priceController.removeListener(_onInputChanged);
    rateController.removeListener(_onInputChanged);
    timeController.removeListener(_onInputChanged);
    _scrollController.removeListener(_onScroll);

    priceController.dispose();
    rateController.dispose();
    timeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCalculatorContent() {
    final largestContributor = _largestContributor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedEntry(
          delay: const Duration(milliseconds: 100),
          child: const Text(
            "Inflation Calculator",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          "Understand how inflation changes ypur money's value over time.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 30),

        AnimatedEntry(
          delay: const Duration(milliseconds: 200),
          child: AppTextField(
            controller: priceController,
            label: "Current Price",
            icon: Icons.currency_rupee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(height: 20),

        AnimatedEntry(
          delay: const Duration(milliseconds: 300),
          child: AppTextField(
            controller: rateController,
            label: "Annual Inflation Rate (%)",
            icon: Icons.percent,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(height: 20),

        AnimatedEntry(
          delay: const Duration(milliseconds: 400),
          child: AppTextField(
            controller: timeController,
            label: "Time Period (Years)",
            icon: Icons.calendar_today,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),

        const SizedBox(height: 24),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: canCalculate
              ? PrimaryButton(
                  key: const ValueKey("calculate"),
                  text: "Calculate",
                  icon: Icons.calculate,
                  onPressed: calculateInflation,
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
                        "Future Price",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),

                      AnimatedCurrencyValue(value: futurePrice, fontSize: 34),
                      const SizedBox(height: 8),

                      const Text(
                        "What the same amount may cost after inflation",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
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
            child: _metricsVisible
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 700;

                      if (!isWide) {
                        final inflationCostCard = AnimatedEntry(
                          delay: const Duration(milliseconds: 150),
                          duration: const Duration(milliseconds: 850),
                          child: _InflationMetricCard(
                            label: "Inflation Cost",
                            value: inflationCost,
                            icon: Icons.trending_up,
                          ),
                        );

                        final purchasingPowerCard = AnimatedEntry(
                          delay: const Duration(milliseconds: 850),
                          duration: const Duration(milliseconds: 850),
                          child: _InflationMetricCard(
                            label: "Purchasing Power",
                            value: purchasingPower,
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            inflationCostCard,
                            const SizedBox(height: 12),
                            purchasingPowerCard,
                          ],
                        );
                      }

                      final inflationCostCard = AnimatedEntry(
                        delay: Duration.zero,
                        duration: const Duration(milliseconds: 850),
                        child: _InflationMetricCard(
                          label: "Inflation Cost",
                          value: inflationCost,
                          icon: Icons.trending_up,
                        ),
                      );

                      final purchasingPowerCard = AnimatedEntry(
                        delay: Duration.zero,
                        duration: const Duration(milliseconds: 850),
                        child: _InflationMetricCard(
                          label: "Purchasing Power",
                          value: purchasingPower,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      );

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: inflationCostCard),

                          const SizedBox(width: 12),

                          Expanded(child: purchasingPowerCard),
                        ],
                      );
                    },
                  )
                : const SizedBox(height: 150),
          ),
          const SizedBox(height: 24),

          AnimatedEntry(
            delay: const Duration(milliseconds: 450),
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
                        "Inflation Basket",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Build a personal spending basket and see how inflation could change its cost.",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      if (basketItems.isEmpty)
                        const Text(
                          "No expenses added yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ...List.generate(basketItems.length, (index) {
                        final item = basketItems[index];

                        return AnimatedEntry(
                          key: ValueKey(item),
                          delay: Duration.zero,
                          duration: const Duration(milliseconds: 500),
                          child: _BasketItemRow(
                            item: item,
                            onRemove: () => _removeBasketItem(index),
                            onChanged: () {
                              setState(() {
                                basketCalculated = false;
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: _addBasketItem,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Expense"),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: "Calculate Basket",
                          icon: Icons.calculate,
                          onPressed: _calculateBasket,
                        ),
                      ),

                      if (basketCalculated) ...[
                        const SizedBox(height: 24),

                        Container(
                          key: _summaryKey,
                          child: _summaryVisible
                              ? AnimatedEntry(
                                  delay: Duration.zero,
                                  duration: const Duration(milliseconds: 750),
                                  child: _BasketSummary(
                                    currentTotal: basketCurrentTotal,
                                    futureTotal: basketFutureTotal,
                                    increase: basketIncrease,
                                  ),
                                )
                              : const SizedBox(height: 220),
                        ),

                        if (largestContributor != null) ...[
                          const SizedBox(height: 16),

                          Container(
                            key: _contributorKey,
                            child: _contributorVisible
                                ? AnimatedEntry(
                                    delay: const Duration(milliseconds: 200),
                                    duration: const Duration(milliseconds: 750),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.orange.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.trending_up,
                                            color: Colors.orange,
                                          ),

                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Largest Inflation Contributor",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  largestContributor.name,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(height: 100),
                          ),
                        ],

                        const SizedBox(height: 20),

                        Container(
                          key: _impactKey,
                          child: _impactVisible
                              ? AnimatedEntry(
                                  delay: const Duration(milliseconds: 350),
                                  duration: const Duration(milliseconds: 750),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AnimatedEntry(
                                              delay: Duration.zero,
                                              duration: const Duration(
                                                milliseconds: 550,
                                              ),
                                              child: const Text(
                                                "Inflation Impact by Expense",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            AnimatedEntry(
                                              delay: const Duration(
                                                milliseconds: 120,
                                              ),
                                              duration: const Duration(
                                                milliseconds: 550,
                                              ),
                                              child: const Text(
                                                "See which expenses contribute most to the increase.",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),

                                            ..._buildImpactRows(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 400),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inflation Calculator")),
      body: SizedBox.expand(
        child: GradientBackground(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 310,
                      child: _calculatorInfo.isEmpty ?
                        const SizedBox.shrink()
                        : CalculatorInfoPanel(
                          eyebrow: "Inflation",
                          title: "Inflation Calculator",
                          description: "Understand how rising prices affect your future costs and purchasing power.",
                          info: _calculatorInfo,
                        )
                    ),
                    const SizedBox(width: 28),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: _buildCalculatorContent(),
                      ),
                    ),
                  ],
                );
              }
              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _calculatorInfo.isEmpty ?
                        const SizedBox.shrink()
                        : CalculatorInfoPanel(
                          eyebrow: "Inflation",
                          title: "Inflation Calculator",
                          description: "Understand how rising prices affect your future costs and purchasing power.",
                          info: _calculatorInfo,
                        ),
                    const SizedBox(height: 24),

                    _buildCalculatorContent(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InflationMetricCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _InflationMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedEntry(
      delay: const Duration(milliseconds: 350),
      duration: const Duration(milliseconds: 750),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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

                AnimatedCurrencyValue(value: value, fontSize: 19),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InflationBasketItem {
  String name;
  double price;
  double inflationRate;

  InflationBasketItem({
    required this.name,
    required this.price,
    required this.inflationRate,
  });
}

class _BasketItemRow extends StatelessWidget {
  final InflationBasketItem item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _BasketItemRow({
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withValues(alpha: 0.025),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.name,
                  decoration: const InputDecoration(labelText: "Expense"),
                  onChanged: (value) {
                    item.name = value;
                    onChanged();
                  },
                ),
              ),

              const SizedBox(width: 12),

              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.price == 0 ? "" : item.price.toString(),
                  decoration: const InputDecoration(labelText: "Current Price"),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    item.price = double.tryParse(value) ?? 0;
                    onChanged();
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextFormField(
                  initialValue: item.inflationRate == 0
                      ? ""
                      : item.inflationRate.toString(),
                  decoration: const InputDecoration(
                    labelText: "Annual Inflation Rate (%),",
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    item.inflationRate = double.tryParse(value) ?? 0;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BasketSummary extends StatelessWidget {
  final double currentTotal;
  final double futureTotal;
  final double increase;

  const _BasketSummary({
    required this.currentTotal,
    required this.futureTotal,
    required this.increase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Current Basket", style: TextStyle(color: Colors.grey)),
            AnimatedCurrencyValue(value: currentTotal, fontSize: 15),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Future Basket", style: TextStyle(color: Colors.grey)),
            AnimatedCurrencyValue(value: futureTotal, fontSize: 15),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total Increase", style: TextStyle(color: Colors.grey)),
            AnimatedCurrencyValue(value: increase, fontSize: 15),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.indigo.withValues(alpha: 0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Income needed to maintain lifestyle",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),

              Text(
                "₹${futureTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Approximate future spending required to maintain the same basket.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
