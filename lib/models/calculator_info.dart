class CalculatorInfo {
  final String calculator;
  final int sectionNumber;
  final String title;
  final String description;

  const CalculatorInfo({
    required this.calculator,
    required this.sectionNumber,
    required this.title,
    required this.description,
  });

  factory CalculatorInfo.fromMap(
    Map<String, dynamic> map,
  ) {
    return CalculatorInfo(
      calculator: map['calculator'] as String,
      sectionNumber: map['section_number'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }
}