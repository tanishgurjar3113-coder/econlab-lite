class CalculatorEducation {
  final String calculator;
  final int sectionNumber;
  final String heading;
  final String content;
  final int sortOrder;

  const CalculatorEducation({
    required this.calculator,
    required this.sectionNumber,
    required this.heading,
    required this.content,
    required this.sortOrder,
  });

  factory CalculatorEducation.fromMap(
    Map<String, dynamic> map,
  ) {
    return CalculatorEducation(
      calculator: map['calculator'] as String,
      sectionNumber: map['section_number'] as int,
      heading: map['heading'] as String,
      content: map['content'] as String,
      sortOrder: map['sort_order'] as int,
    );
  }
}