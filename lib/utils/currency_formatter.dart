class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    String formattedInteger;

    if (integerPart.length <= 3) {
      formattedInteger = integerPart;
    } else {
      final lastThree = integerPart.substring(integerPart.length - 3);
      final remaining = integerPart.substring(0, integerPart.length - 3);

      final groups = <String>[];

      for (int i = remaining.length; i > 0; i -= 2) {
        final start = i - 2 < 0 ? 0 : i - 2;
        groups.insert(0, remaining.substring(start, i));
      }

      formattedInteger = '${groups.join(',')},$lastThree';
    }

    return '₹$formattedInteger.$decimalPart';
  }
}