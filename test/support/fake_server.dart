import 'package:shramasiri/data/remote/remote_api.dart';

/// In-memory stand-in for the Supabase backend implementing the same
/// contract as public.apply_ops / pull_changes / get_my_context for the
/// operations the tests use. The real SQL is tested separately in
/// supabase/tests.
class FakeServer {
  FakeServer({required this.farmId});

  final String farmId;
  int seq = 0;
  final tables = <String, Map<String, Map<String, dynamic>>>{};
  final opResults = <String, Map<String, dynamic>>{};
  final opActors = <String, String>{};
  final members = <String, Map<String, dynamic>>{}; // by user id
  int applyCalls = 0;
  int concurrentCalls = 0;
  int maxConcurrentCalls = 0;

  Map<String, Map<String, dynamic>> table(String t) => tables.putIfAbsent(t, () => {});

  String now() => DateTime.now().toUtc().toIso8601String();

  Map<String, dynamic> _stamp(String t, Map<String, dynamic> row) {
    row['server_seq'] = ++seq;
    table(t)[_key(t, row)] = row;
    return row;
  }

  String _key(String t, Map<String, dynamic> row) => switch (t) {
    'worker_group_memberships' => '${row['group_id']}|${row['worker_id']}',
    'work_assignment_workers' => '${row['assignment_id']}|${row['worker_id']}',
    'settlement_items' => '${row['settlement_id']}|${row['worker_id']}',
    _ => row['id'] as String,
  };

  void seedFarm({required String ownerId, String name = 'Test Farm'}) {
    _stamp('farms', {
      'id': farmId,
      'name': name,
      'week_start_day': 1,
      'timezone': 'Asia/Kolkata',
      'created_by': ownerId,
      'created_at': now(),
      'updated_at': now(),
      'revision': 1,
    });
  }

  void seedMember({
    required String userId,
    required String fullName,
    String role = 'member',
    String status = 'active',
  }) {
    final row = _stamp('farm_members', {
      'id': 'm-$userId',
      'farm_id': farmId,
      'user_id': userId,
      'email': '$userId@example.com',
      'role': role,
      'status': status,
      'full_name': fullName,
      'display_name_kn': null,
      'linked_worker_id': null,
      'invited_by': null,
      'created_at': now(),
      'updated_at': now(),
      'revision': 1,
    });
    members[userId] = row;
  }

  void setMemberStatus(String userId, String status) {
    final row = Map<String, dynamic>.from(members[userId]!);
    row['status'] = status;
    row['revision'] = (row['revision'] as int) + 1;
    members[userId] = _stamp('farm_members', row);
  }

  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> applyOps(String uid, List<Map<String, dynamic>> ops) {
    applyCalls++;
    return [for (final op in ops) _applyOne(uid, op)];
  }

  Map<String, dynamic> _applyOne(String uid, Map<String, dynamic> op) {
    final opId = op['op_id'] as String;
    if (opResults.containsKey(opId)) {
      if (opActors[opId] != uid) return {'op_id': opId, 'status': 'rejected', 'code': 'op_id_reused'};
      return {...opResults[opId]!, 'replayed': true};
    }
    final m = members[uid];
    if (m == null || m['status'] != 'active') {
      return {'op_id': opId, 'status': 'rejected', 'code': 'not_a_member', 'retryable': true};
    }
    final snapshot = {
      for (final e in tables.entries)
        e.key: {for (final r in e.value.entries) r.key: Map<String, dynamic>.from(r.value)},
    };
    final seqBefore = seq;
    Map<String, dynamic> res;
    try {
      final rows = _dispatch(uid, m, op);
      res = {'op_id': opId, 'status': 'applied', 'rows': rows};
    } on _Outcome catch (o) {
      tables
        ..clear()
        ..addAll(snapshot);
      seq = seqBefore;
      res = {'op_id': opId, 'status': o.status, 'code': o.code, 'data': o.data, 'rows': o.rows};
    }
    opResults[opId] = res;
    opActors[opId] = uid;
    return res;
  }

  List<Map<String, dynamic>> _rows(String t, Map<String, dynamic> row) => [
    {'t': t, 'd': Map<String, dynamic>.from(row)},
  ];

  List<Map<String, dynamic>> _dispatch(String uid, Map<String, dynamic> m, Map<String, dynamic> op) {
    final p = Map<String, dynamic>.from(op['payload'] as Map);
    final base = op['base_revision'] as int? ?? 0;
    switch (op['op_type']) {
      case 'worker_upsert':
        final id = p['id'] as String;
        final old = table('workers')[id];
        if (base == 0) {
          if (old != null) throw _Outcome.conflict('already_exists', _rows('workers', old));
          return _rows(
            'workers',
            _stamp('workers', {
              ...p,
              'farm_id': farmId,
              'created_by': uid,
              'updated_by': uid,
              'created_at': now(),
              'updated_at': now(),
              'revision': 1,
            }),
          );
        }
        if (old == null) throw _Outcome.rejected('not_found');
        if (old['revision'] != base) throw _Outcome.conflict('stale_revision', _rows('workers', old));
        return _rows(
          'workers',
          _stamp('workers', {
            ...old,
            ...p,
            'updated_by': uid,
            'updated_at': now(),
            'revision': (old['revision'] as int) + 1,
          }),
        );
      case 'attendance_upsert':
        final id = p['id'] as String;
        final units = p['units_milli'] as int;
        final rate = p['rate_paise'] as int;
        final earned = (rate * units + 500) ~/ 1000;
        if (base == 0) {
          final existing = table('attendance').values
              .where((a) => a['worker_id'] == p['worker_id'] && a['work_date'] == p['work_date'])
              .firstOrNull;
          if (existing != null) throw _Outcome.conflict('attendance_exists', _rows('attendance', existing));
          return _rows(
            'attendance',
            _stamp('attendance', {
              'id': id,
              'farm_id': farmId,
              'worker_id': p['worker_id'],
              'work_date': p['work_date'],
              'units_milli': units,
              'rate_paise': rate,
              'earned_paise': earned,
              'notes': p['notes'],
              'recorded_by': uid,
              'updated_by': uid,
              'source_device_id': op['device_id'],
              'created_at': now(),
              'updated_at': now(),
              'revision': 1,
            }),
          );
        }
        final old = table('attendance')[id];
        if (old == null) throw _Outcome.rejected('not_found');
        if (old['revision'] != base) throw _Outcome.conflict('stale_revision', _rows('attendance', old));
        return _rows(
          'attendance',
          _stamp('attendance', {
            ...old,
            'units_milli': units,
            'rate_paise': rate,
            'earned_paise': earned,
            'notes': p['notes'],
            'updated_by': uid,
            'updated_at': now(),
            'revision': (old['revision'] as int) + 1,
          }),
        );
      case 'ledger_create':
        return _rows('financial_transactions', _ledgerInsert(uid, m, op, p));
      case 'ledger_reverse':
        final orig = table('financial_transactions')[p['reverses_id']];
        if (orig == null) throw _Outcome.rejected('not_found');
        final dup = table('financial_transactions').values.where((r) => r['reverses_id'] == orig['id']).firstOrNull;
        if (dup != null) throw _Outcome.conflict('already_reversed', _rows('financial_transactions', dup));
        return _rows(
          'financial_transactions',
          _stamp('financial_transactions', {
            ...orig,
            'id': p['id'],
            'is_reversal': true,
            'reverses_id': orig['id'],
            'notes': p['reason'],
            'recorded_by': uid,
            'recorded_by_name': m['full_name'],
            'occurred_at': now(),
            'created_at': now(),
            'op_id': op['op_id'],
          }),
        );
      case 'settlement_close':
        final existing = table('settlements').values.where((s) => s['week_start'] == p['week_start']).firstOrNull;
        final weekEnd = DateTime.parse(p['week_start'] as String)
            .add(const Duration(days: 6))
            .toIso8601String()
            .substring(0, 10);
        return _rows(
          'settlements',
          _stamp('settlements', {
            'id': existing?['id'] ?? p['id'],
            'farm_id': farmId,
            'week_start': p['week_start'],
            'week_end': weekEnd,
            'status': 'closed',
            'needs_review': false,
            'closed_by': uid,
            'closed_by_name': m['full_name'],
            'closed_at': now(),
            'notes': p['notes'],
            'created_at': existing?['created_at'] ?? now(),
            'updated_at': now(),
            'revision': ((existing?['revision'] as int?) ?? 0) + 1,
          }),
        );
      default:
        throw _Outcome.rejected('unknown_op_type');
    }
  }

  int leaderPool(String leaderId) {
    var total = 0;
    for (final r in table('financial_transactions').values) {
      final amt = (r['is_reversal'] == true) ? -(r['amount_paise'] as int) : r['amount_paise'] as int;
      if (r['entry_type'] == 'leader_transfer' && r['worker_id'] == leaderId) total += amt;
      if (r['entry_type'] == 'leader_return' && r['worker_id'] == leaderId) total -= amt;
      if (r['entry_type'] == 'leader_allocation' && r['leader_worker_id'] == leaderId) total -= amt;
    }
    return total;
  }

  Map<String, dynamic> _ledgerInsert(
    String uid,
    Map<String, dynamic> m,
    Map<String, dynamic> op,
    Map<String, dynamic> p,
  ) {
    if (table('financial_transactions').containsKey(p['id'])) throw _Outcome.conflict('already_exists', const []);
    final type = p['entry_type'] as String;
    final amount = p['amount_paise'] as int;
    if (type == 'leader_allocation') {
      final avail = leaderPool(p['leader_worker_id'] as String);
      if (amount > avail) throw _Outcome.rejected('insufficient_leader_funds', {'available_paise': avail});
    }
    final cash = p['method'] != 'none';
    String? paidByName;
    if (cash) {
      final payer = members[p['paid_by'] ?? uid];
      if (payer == null) throw _Outcome.rejected('invalid_payer');
      paidByName = payer['full_name'] as String;
    }
    return _stamp('financial_transactions', {
      'id': p['id'],
      'farm_id': farmId,
      'entry_type': type,
      'worker_id': p['worker_id'],
      'leader_worker_id': p['leader_worker_id'],
      'amount_paise': amount,
      'is_reversal': false,
      'reverses_id': null,
      'related_entry_id': p['related_entry_id'],
      'business_date': p['business_date'],
      'occurred_at': p['occurred_at'] ?? now(),
      'method': cash ? p['method'] : 'none',
      'reference': p['reference'],
      'notes': p['notes'],
      'paid_by': cash ? (p['paid_by'] ?? uid) : null,
      'paid_by_name': paidByName,
      'recorded_by': uid,
      'recorded_by_name': m['full_name'],
      'source_device_id': op['device_id'],
      'op_id': op['op_id'],
      'created_at': now(),
    });
  }

  PullPage pull(String uid, int after, int limit) {
    if (members[uid]?['status'] != 'active') {
      throw RemoteError(RemoteErrorKind.forbidden, 'not_a_member', code: '42501');
    }
    final all = <Map<String, dynamic>>[];
    tables.forEach((t, rows) {
      for (final r in rows.values) {
        if ((r['server_seq'] as int) > after) {
          all.add({'s': r['server_seq'], 't': t, 'd': Map<String, dynamic>.from(r)});
        }
      }
    });
    all.sort((a, b) => (a['s'] as int).compareTo(b['s'] as int));
    final page = all.take(limit).toList();
    return PullPage(
      changes: page,
      lastSeq: page.isEmpty ? after : page.last['s'] as int,
      hasMore: page.length == limit,
    );
  }

  int count(String t, bool Function(Map<String, dynamic>) where) => table(t).values.where(where).length;
}

class _Outcome implements Exception {
  _Outcome(this.status, this.code, [this.data = const {}, this.rows = const []]);

  factory _Outcome.conflict(String code, List<Map<String, dynamic>> rows) => _Outcome('conflict', code, const {}, rows);
  factory _Outcome.rejected(String code, [Map<String, dynamic> data = const {}]) => _Outcome('rejected', code, data);

  final String status;
  final String code;
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> rows;
}

/// One device's connection to the fake server.
class FakeRemote implements RemoteApi {
  FakeRemote(this.server, this.userId);

  final FakeServer server;
  final String userId;

  bool online = true;

  /// Commit the next upload on the server but lose the response.
  bool dropNextAck = false;

  void _check() {
    if (!online) throw RemoteError(RemoteErrorKind.network, 'offline');
  }

  @override
  Future<List<Map<String, dynamic>>> applyOps(List<Map<String, dynamic>> ops) async {
    _check();
    server.concurrentCalls++;
    if (server.concurrentCalls > server.maxConcurrentCalls) server.maxConcurrentCalls = server.concurrentCalls;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final results = server.applyOps(userId, ops);
      if (dropNextAck) {
        dropNextAck = false;
        throw RemoteError(RemoteErrorKind.network, 'connection reset after commit');
      }
      return results;
    } finally {
      server.concurrentCalls--;
    }
  }

  @override
  Future<PullPage> pullChanges(String farmId, int afterSeq, {int limit = 500}) async {
    _check();
    return server.pull(userId, afterSeq, limit);
  }

  @override
  Future<Map<String, dynamic>> getMyContext() async {
    _check();
    final m = server.members[userId];
    return {
      'user_id': userId,
      'server_time': DateTime.now().toUtc().toIso8601String(),
      'memberships': [
        if (m != null) {'farm_id': server.farmId, 'role': m['role'], 'status': m['status'], 'member_id': m['id']},
      ],
      'invitations': const [],
    };
  }

  @override
  Future<Map<String, dynamic>> createFarm({
    required String farmId,
    required String farmName,
    required String fullName,
    String? displayNameKn,
  }) => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> acceptInvitation({
    required String memberId,
    required String fullName,
    String? displayNameKn,
  }) => throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> fetchRows(String table, String column, String value) async {
    _check();
    return server
        .table(table)
        .values
        .where((r) => r[column] == value)
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
  }

  @override
  Future<bool> refreshSession() async => online;
}
