import 'package:flutter/widgets.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../domain/ledger.dart';
import '../../l10n/app_localizations.dart';

/// Statements shared with workers are always in Kannada.
AppLocalizations get kannada => lookupAppLocalizations(const Locale('kn'));

/// Plain-text weekly statement for one worker, suitable for WhatsApp/SMS.
String buildWorkerStatement({
  required AppLocalizations l,
  required String farmName,
  required String workerName,
  required LocalDate start,
  required LocalDate end,
  required PeriodSummary s,
  required String preparedBy,
}) {
  final dates = DateFormats(l.localeName);
  String line(String label, int paise, {bool minus = false}) =>
      l.stmtLine(label, minus && paise != 0 ? '-${Money.format(paise)}' : Money.format(paise));
  final b = StringBuffer()
    ..writeln(l.stmtHeader)
    ..writeln(l.stmtFarm(farmName))
    ..writeln('${l.worker}: $workerName')
    ..writeln(l.stmtWeek(dates.range(start, end)))
    ..writeln()
    ..writeln(l.stmtDays(Units.format(s.unitsMilli)));
  if (s.openingPaise != 0) b.writeln(line(l.openingBalance, s.openingPaise));
  b.writeln(line(l.earned, s.grossPaise));
  if (s.additionsPaise != 0) b.writeln(line(l.additions, s.additionsPaise));
  if (s.advancesPaise != 0) b.writeln(line(l.advanceGiven, s.advancesPaise, minus: true));
  if (s.directPaidPaise != 0) b.writeln(line(l.paidDirect, s.directPaidPaise, minus: true));
  if (s.leaderPaidPaise != 0) b.writeln(line(l.paidViaLeader, s.leaderPaidPaise, minus: true));
  b.writeln('----------');
  if (s.closingPaise >= 0) {
    b.writeln(line(l.remaining, s.closingPaise));
  } else {
    b.writeln(line(l.overpaid, -s.closingPaise));
  }
  b
    ..writeln()
    ..writeln(l.stmtFooter(preparedBy));
  return b.toString();
}

/// Whole-week summary for the family.
String buildWeekSummary({
  required AppLocalizations l,
  required String farmName,
  required LocalDate start,
  required LocalDate end,
  required List<(String name, PeriodSummary s)> rows,
}) {
  final dates = DateFormats(l.localeName);
  final b = StringBuffer()
    ..writeln(l.stmtHeader)
    ..writeln(l.stmtFarm(farmName))
    ..writeln(l.stmtWeek(dates.range(start, end)))
    ..writeln();
  var earned = 0, due = 0;
  for (final (name, s) in rows) {
    earned += s.earnedPaise;
    if (s.closingPaise > 0) due += s.closingPaise;
    b.writeln(
      '$name — ${l.stmtDays(Units.format(s.unitsMilli))}, ${l.earned} ${Money.format(s.earnedPaise)}, '
      '${s.closingPaise >= 0 ? l.remaining : l.overpaid} ${Money.format(s.closingPaise.abs())}',
    );
  }
  b
    ..writeln()
    ..writeln(l.stmtLine(l.weekTotalEarned, Money.format(earned)))
    ..writeln(l.stmtLine(l.weekTotalDue, Money.format(due)));
  return b.toString();
}
