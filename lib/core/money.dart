/// Money is always handled as integer paise (1 rupee = 100 paise).
abstract final class Money {
  /// Largest single amount accepted in forms: ₹1,00,00,000.
  static const maxEntryPaise = 1000000000;

  /// Formats paise as rupees with Indian digit grouping, e.g. 275000 -> ₹2,750
  /// and 275050 -> ₹2,750.50. Negative values get a leading minus sign.
  static String format(int paise, {bool symbol = true}) {
    final negative = paise < 0;
    final abs = paise.abs();
    final rupees = abs ~/ 100;
    final rest = abs % 100;
    final grouped = groupIndian(rupees.toString());
    final fraction = rest == 0 ? '' : '.${rest.toString().padLeft(2, '0')}';
    return '${negative ? '-' : ''}${symbol ? '₹' : ''}$grouped$fraction';
  }

  /// 1234567 -> 12,34,567
  static String groupIndian(String digits) {
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    var head = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    return '${parts.join(',')},$last3';
  }

  /// Parses a rupee amount typed by the user ("500", "1,250.50", "₹ 300")
  /// into paise without using floating point. Returns null when invalid,
  /// negative, or more than two decimal places.
  static int? parseRupees(String input) {
    final cleaned = input.replaceAll(RegExp(r'[₹,\s]'), '');
    final match = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(cleaned);
    if (match == null) return null;
    final rupees = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(2, '0');
    return rupees * 100 + int.parse(fraction);
  }

  /// Text suitable for pre-filling an amount field: 50000 -> "500", 50050 -> "500.50".
  static String toInput(int paise) {
    final rupees = paise ~/ 100;
    final rest = paise % 100;
    return rest == 0 ? '$rupees' : '$rupees.${rest.toString().padLeft(2, '0')}';
  }
}

/// Attendance units are stored as thousandths of a day: 1000 = full day.
abstract final class Units {
  static const fullDay = 1000;
  static const halfDay = 500;
  static const max = 3000;

  /// Earned paise for [units] at a daily [ratePaise], rounded half up.
  /// Must match the generated column in the attendance table.
  static int earned(int ratePaise, int units) => (ratePaise * units + 500) ~/ 1000;

  /// 1000 -> "1", 500 -> "0.5", 1250 -> "1.25"
  static String format(int units) {
    final whole = units ~/ 1000;
    final rest = units % 1000;
    if (rest == 0) return '$whole';
    var frac = rest.toString().padLeft(3, '0');
    while (frac.endsWith('0')) {
      frac = frac.substring(0, frac.length - 1);
    }
    return '$whole.$frac';
  }

  /// Parses "1", "0.5", "1.25" into thousandths. Null when invalid.
  static int? parse(String input) {
    final match = RegExp(r'^(\d{1})(?:\.(\d{1,3}))?$').firstMatch(input.trim());
    if (match == null) return null;
    final value = int.parse(match.group(1)!) * 1000 + int.parse((match.group(2) ?? '').padRight(3, '0'));
    if (value > max) return null;
    return value;
  }
}
