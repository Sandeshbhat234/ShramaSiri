import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/money.dart';
import '../../data/db/database.dart';
import '../common/labels.dart';
import '../common/widgets.dart';
import '../leader/leader_screens.dart';
import '../money/give_money_screen.dart';
import '../money/payment_history_screen.dart';
import '../reports/reports_screen.dart';
import '../settlement/weekly_screen.dart';
import '../shell.dart';
import '../workers/worker_detail_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    void push(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    final balances = ref.watch(balancesProvider).value ?? const {};
    final workers = ref.watch(workerIndexProvider).value ?? const <String, Worker>{};
    final nonZero = balances.values.where((b) => b.wagePaise != 0 || b.loanPaise != 0).toList()
      ..sort((a, b) => b.wagePaise.compareTo(a.wagePaise));

    return Scaffold(
      appBar: AppBar(title: Text(l.accountsTitle), actions: appBarActions(context)),
      body: ListView(
        padding: pagePadding,
        children: [
          const StatusBanners(),
          ActionGrid(
            children: [
              BigActionButton(icon: Icons.payments, label: l.giveMoney, onTap: () => push(const GiveMoneyScreen())),
              BigActionButton(
                icon: Icons.calendar_view_week,
                label: l.weeklyAccounts,
                onTap: () => push(const WeeklyScreen()),
              ),
              BigActionButton(
                icon: Icons.receipt_long,
                label: l.paymentHistory,
                onTap: () => push(const PaymentHistoryScreen()),
              ),
              BigActionButton(icon: Icons.groups, label: l.leaderFunds, onTap: () => push(const LeaderFundsScreen())),
            ],
          ),
          gap12,
          OutlinedButton.icon(
            onPressed: () => push(const ReportsScreen()),
            icon: const Icon(Icons.bar_chart),
            label: Text(l.reports),
          ),
          SectionHeader(l.balancesTitle),
          if (nonZero.isEmpty) Card(child: ListTile(title: Text(l.settledUp))),
          if (nonZero.isNotEmpty)
            Card(
              child: Column(
                children: [
                  for (final b in nonZero)
                    ListTile(
                      title: Text(workerName(workers[b.workerId])),
                      subtitle: Text(
                        [
                          if (b.wagePaise > 0) l.wageDue,
                          if (b.wagePaise < 0) l.advanceAhead,
                          if (b.loanPaise != 0) '${l.loanDue} ${Money.format(b.loanPaise)}',
                        ].join(' · '),
                      ),
                      trailing: AmountText(
                        b.wagePaise.abs(),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: b.wagePaise < 0 ? AppColors.amber : null),
                      ),
                      onTap: () => push(WorkerDetailScreen(workerId: b.workerId)),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
