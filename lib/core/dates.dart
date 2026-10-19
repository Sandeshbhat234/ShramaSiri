import 'package:intl/intl.dart';

/// A calendar date without time or timezone, stored as 'YYYY-MM-DD'.
/// Farm business dates are always interpreted in Asia/Kolkata.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  factory LocalDate.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) throw FormatException('Invalid date', iso);
    return LocalDate(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  factory LocalDate.fromDateTime(DateTime d) => LocalDate(d.year, d.month, d.day);

  /// Calendar date in India for an absolute instant.
  factory LocalDate.inIst(DateTime instant) => LocalDate.fromDateTime(Ist.fromUtc(instant));

  DateTime get _utc => DateTime.utc(year, month, day);

  /// ISO weekday: 1 = Monday ... 7 = Sunday.
  int get weekday => _utc.weekday;

  LocalDate addDays(int days) => LocalDate.fromDateTime(_utc.add(Duration(days: days)));

  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  /// Start of the wage week containing this date. [weekStartDay] is ISO 1..7.
  LocalDate weekStart(int weekStartDay) {
    final back = (weekday - weekStartDay) % 7;
    return addDays(-back);
  }

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// Midnight of this date as a local (wall-clock) DateTime, for pickers.
  DateTime toDateTime() => DateTime(year, month, day);

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  int compareTo(LocalDate other) => toIso().compareTo(other.toIso());

  @override
  bool operator ==(Object other) => other is LocalDate && other.toIso() == toIso();

  @override
  int get hashCode => toIso().hashCode;

  @override
  String toString() => toIso();
}

/// India Standard Time helpers. IST is UTC+05:30 all year (no DST).
abstract final class Ist {
  static const offset = Duration(hours: 5, minutes: 30);

  /// Wall-clock IST time for an instant, returned as a UTC-flagged DateTime
  /// whose fields read as IST.
  static DateTime fromUtc(DateTime instant) => instant.toUtc().add(offset);

  /// Absolute instant for an IST wall-clock date/time.
  static DateTime toUtc(LocalDate date, {int hour = 0, int minute = 0}) =>
      DateTime.utc(date.year, date.month, date.day, hour, minute).subtract(offset);
}

/// Current time corrected by the last measured server clock skew, so a phone
/// with a wrong date still defaults to the right farm date once it has synced.
abstract final class AppClock {
  static Duration skew = Duration.zero;

  /// Warn when the phone clock differs from the server by more than this.
  static const warnSkew = Duration(minutes: 30);

  static DateTime nowUtc() => DateTime.now().toUtc().add(skew);

  static LocalDate today() => LocalDate.inIst(nowUtc());

  static bool get deviceClockLooksWrong => skew.abs() > warnSkew;
}

/// Locale-aware display formats (Indian conventions: day before month).
class DateFormats {
  DateFormats(this.locale);

  final String locale;

  /// 18 Oct 2026
  String date(LocalDate d) => DateFormat('d MMM yyyy', locale).format(d.toDateTime());

  /// Sun, 18 Oct
  String shortDay(LocalDate d) => DateFormat('EEE, d MMM', locale).format(d.toDateTime());

  /// Sunday, 18 October 2026
  String longDate(LocalDate d) => DateFormat('EEEE, d MMMM yyyy', locale).format(d.toDateTime());

  /// 18 Oct – 24 Oct
  String range(LocalDate start, LocalDate end) =>
      '${DateFormat('d MMM', locale).format(start.toDateTime())} – ${DateFormat('d MMM', locale).format(end.toDateTime())}';

  /// 18 Oct, 4:05 pm (IST)
  String instant(DateTime utc) => DateFormat('d MMM, h:mm a', locale).format(Ist.fromUtc(utc));

  /// 4:05 pm (IST)
  String time(DateTime utc) => DateFormat('h:mm a', locale).format(Ist.fromUtc(utc));
}
