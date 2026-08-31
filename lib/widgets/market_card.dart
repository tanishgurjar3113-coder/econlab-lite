import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/market_data.dart';

class MarketCard extends StatelessWidget {
  final MarketData data;
  final List<double> chartPoints;

  const MarketCard({
    super.key,
    required this.data,
    this.chartPoints = const [],
  });

  String _currencySymbol(String? currency) {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final changePercent = data.changePercent ?? 0;
    final isPositive = changePercent >= 0;
    final currencySymbol = _currencySymbol(data.currency);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 750;

          if (isWide) {
            return SizedBox(
              height: 265,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 270,
                    child: _buildInformation(
                      currencySymbol: currencySymbol,
                      changePercent: changePercent,
                      isPositive: isPositive,
                    ),
                  ),

                  const SizedBox(width: 36),

                  Expanded(
                    child: _buildChart(),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInformation(
                currencySymbol: currencySymbol,
                changePercent: changePercent,
                isPositive: isPositive,
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 190,
                width: double.infinity,
                child: _buildChart(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInformation({
    required String currencySymbol,
    required double changePercent,
    required bool isPositive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          data.category.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: Colors.indigo,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          data.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '${data.symbol} · ${data.exchange}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black45,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          data.price == null
              ? '--'
              : '$currencySymbol'
                  '${data.price!.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 9),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withValues(alpha: 0.08)
                : Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 13,
                color: isPositive
                    ? Colors.green
                    : Colors.red,
              ),

              const SizedBox(width: 4),

              Text(
                '${changePercent >= 0 ? '+' : ''}'
                '${changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPositive
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _RangeValue(
                label: 'LOW',
                value: data.dayLow,
                currencySymbol: currencySymbol,
              ),
            ),

            Expanded(
              child: _RangeValue(
                label: 'HIGH',
                value: data.dayHigh,
                currencySymbol: currencySymbol,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          data.freshness ?? '',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (chartPoints.length < 2) {
      return const Center(
        child: Text(
          'No chart data',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black38,
          ),
        ),
      );
    }

    final minValue = chartPoints.reduce(
      (a, b) => a < b ? a : b,
    );

    final maxValue = chartPoints.reduce(
      (a, b) => a > b ? a : b,
    );

    final range = maxValue - minValue;

    final padding = range == 0
        ? 1.0
        : range * 0.12;

    final spots = List.generate(
      chartPoints.length,
      (index) => FlSpot(
        index.toDouble(),
        chartPoints[index],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (chartPoints.length - 1).toDouble(),
          minY: minValue - padding,
          maxY: maxValue + padding,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval:
                range == 0 ? 1 : range / 3,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.black.withValues(
                  alpha: 0.08,
                ),
                strokeWidth: 1,
              );
            },
          ),

          titlesData: const FlTitlesData(
            show: false,
          ),

          borderData: FlBorderData(
            show: false,
          ),

          lineTouchData: const LineTouchData(
            enabled: false,
          ),

          clipData: const FlClipData.all(),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.18,
              barWidth: 3,
              isStrokeCapRound: true,
              isStrokeJoinRound: true,

              color: Colors.indigo,

              dotData: const FlDotData(
                show: false,
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigo.withValues(
                      alpha: 0.18,
                    ),
                    Colors.indigo.withValues(
                      alpha: 0.01,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeValue extends StatelessWidget {
  final String label;
  final double? value;
  final String currencySymbol;

  const _RangeValue({
    required this.label,
    required this.value,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 1.1,
            color: Colors.black45,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value == null
              ? '--'
              : '$currencySymbol'
                  '${value!.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}