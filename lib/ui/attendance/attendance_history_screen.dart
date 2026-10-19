import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/repositories/attendance_repo.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import 'attendance_screen.dart';

final recentDaysProvider = StreamProvider.autoDispose.family<List<DaySummary>, int>(
  (ref, limit) => ref.watch(attendanceRepoProvider).watchRecentDays(limit: limit),
);

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends ConsumerState<AttendanceHistoryScreen> {
  int _limit = 30;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final days = ref.watch(recentDaysProvider(_limit));
    return Scaffold(
      appBar: AppBar(title: Text(l.attendanceHistory)),
      body: AsyncView(
        days,
        builder: (list) {
          if (list.isEmpty) return EmptyState(icon: Icons.event_note, text: l.noEntries);
          return ListView.separated(
            itemCount: list.length + (list.length >= _limit ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i == list.length) {
                return TextButton(onPressed: () => setState(() => _limit += 30), child: Text(l.loadMore));
              }
              final d = list[i];
              final date = LocalDate.parse(d.date);
              return ListTile(
                title: Text(context.dates.longDate(date)),
                subtitle: Text('${l.peopleCount(d.workers)} · ${l.daysShort(Units.format(d.unitsMilli))}'),
                trailing: AmountText(d.earnedPaise),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AttendanceScreen(initialDate: date, standalone: true)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
