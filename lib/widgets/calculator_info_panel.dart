import 'package:econlab_lite/models/calculator_info.dart';
import 'package:flutter/material.dart';
import '../models/calculator_education.dart';

class CalculatorInfoPanel extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final List<CalculatorInfo> info;
  final int activeIndex;
  final List<CalculatorEducation> education;

  const CalculatorInfoPanel({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.info,
    required this.education,
    this.activeIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F6),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 18),

          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),

          Container(height: 1, color: Colors.black12),
          const SizedBox(height: 20),

          ...info.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == activeIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isActive ? Colors.indigo : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive ? Colors.indigo : Colors.black38,
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive ? Colors.black87 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          
          if (education.isNotEmpty) ...[
            const SizedBox(height: 20),

            Container(height: 1,
              color: Colors.black12,
            ),
            const SizedBox(height: 24),

            const Text('EDUCATIONAL CONTENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: Colors.indigo,
              )
            ),
            const SizedBox(height: 20),

            ...education.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.heading,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(item.content,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ))
          ]
        ],
      ),
    );
  }
}
