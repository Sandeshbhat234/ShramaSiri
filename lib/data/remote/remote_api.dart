import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Why a server call failed. Drives retry and UI decisions.
enum RemoteErrorKind {
  /// No connection, DNS failure, timeout: retry later.
  network,

  /// Session expired or invalid: refresh or sign in again.
  auth,

  /// Authenticated but not allowed (e.g. membership revoked).
  forbidden,

  /// Server-side failure (5xx): retry with backoff.
  server,

  /// Request rejected as invalid: do not retry unchanged.
  invalid,
}

class RemoteError implements Exception {
  RemoteError(this.kind, this.message, {this.code});

  final RemoteErrorKind kind;
  final String message;
  final String? code;

  bool get isRetryable => kind == RemoteErrorKind.network || kind == RemoteErrorKind.server;

  @override
  String toString() => 'RemoteError(${kind.name}, ${code ?? ''} $message)';
}

class PullPage {
  PullPage({required this.changes, required this.lastSeq, required this.hasMore});

  /// Each change: {s: seq, t: table, d: row json}
  final List<Map<String, dynamic>> changes;
  final int lastSeq;
  final bool hasMore;
}

/// Server operations used by the app. Implemented by Supabase in production
/// and by an in-memory fake in tests.
abstract class RemoteApi {
  Future<List<Map<String, dynamic>>> applyOps(List<Map<String, dynamic>> ops);

  Future<PullPage> pullChanges(String farmId, int afterSeq, {int limit = 500});

  Future<Map<String, dynamic>> getMyContext();

  Future<Map<String, dynamic>> createFarm({
    required String farmId,
    required String farmName,
    required String fullName,
    String? displayNameKn,
  });

  Future<Map<String, dynamic>> acceptInvitation({
    required String memberId,
    required String fullName,
    String? displayNameKn,
  });

  /// Reads rows directly (RLS limits them to the user's farm). Used to
  /// restore server copies after discarding a rejected local change.
  Future<List<Map<String, dynamic>>> fetchRows(String table, String column, String value);

  /// Tries to obtain a fresh access token. Returns false when the user must
  /// sign in again.
  Future<bool> refreshSession();
}

class SupabaseRemoteApi implements RemoteApi {
  SupabaseRemoteApi(this.client, {this.timeout = const Duration(seconds: 30)});

  final SupabaseClient client;
  final Duration timeout;

  Future<T> _call<T>(Future<T> Function() body) async {
    try {
      return await body().timeout(timeout);
    } on TimeoutException {
      throw RemoteError(RemoteErrorKind.network, 'timeout');
    } on SocketException catch (e) {
      throw RemoteError(RemoteErrorKind.network, e.message);
    } on HttpException catch (e) {
      throw RemoteError(RemoteErrorKind.network, e.message);
    } on AuthException catch (e) {
      final status = int.tryParse(e.statusCode ?? '');
      if (status == null || e is AuthRetryableFetchException) {
        throw RemoteError(RemoteErrorKind.network, e.message);
      }
      throw RemoteError(RemoteErrorKind.auth, e.message, code: e.code);
    } on PostgrestException catch (e) {
      throw _mapPostgrest(e);
    } on RemoteError {
      rethrow;
    } catch (e) {
      // http's ClientException and similar transport failures.
      final text = e.toString();
      if (text.contains('ClientException') || text.contains('Connection') || text.contains('Failed host lookup')) {
        throw RemoteError(RemoteErrorKind.network, text);
      }
      rethrow;
    }
  }

  RemoteError _mapPostgrest(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message;
    if (code == '28000' || code == 'PGRST301' || code == 'PGRST302' || message.contains('JWT')) {
      return RemoteError(RemoteErrorKind.auth, message, code: code);
    }
    if (code == '42501') return RemoteError(RemoteErrorKind.forbidden, message, code: code);
    if (code.startsWith('22') || code.startsWith('23') || code == 'PGRST202') {
      return RemoteError(RemoteErrorKind.invalid, message, code: code);
    }
    return RemoteError(RemoteErrorKind.server, message, code: code);
  }

  @override
  Future<List<Map<String, dynamic>>> applyOps(List<Map<String, dynamic>> ops) => _call(() async {
    final res = await client.rpc<dynamic>('apply_ops', params: {'p_ops': ops});
    return (res as List).cast<Map<String, dynamic>>();
  });

  @override
  Future<PullPage> pullChanges(String farmId, int afterSeq, {int limit = 500}) => _call(() async {
    final res = await client.rpc<dynamic>(
      'pull_changes',
      params: {'p_farm_id': farmId, 'p_after': afterSeq, 'p_limit': limit},
    ) as Map<String, dynamic>;
    return PullPage(
      changes: (res['changes'] as List).cast<Map<String, dynamic>>(),
      lastSeq: (res['last_seq'] as num).toInt(),
      hasMore: res['has_more'] as bool,
    );
  });

  @override
  Future<Map<String, dynamic>> getMyContext() =>
      _call(() async => await client.rpc<dynamic>('get_my_context') as Map<String, dynamic>);

  @override
  Future<Map<String, dynamic>> createFarm({
    required String farmId,
    required String farmName,
    required String fullName,
    String? displayNameKn,
  }) => _call(
    () async => await client.rpc<dynamic>(
      'create_farm',
      params: {
        'p_farm_id': farmId,
        'p_farm_name': farmName,
        'p_full_name': fullName,
        'p_display_name_kn': displayNameKn,
      },
    ) as Map<String, dynamic>,
  );

  @override
  Future<Map<String, dynamic>> acceptInvitation({
    required String memberId,
    required String fullName,
    String? displayNameKn,
  }) => _call(
    () async => await client.rpc<dynamic>(
      'accept_invitation',
      params: {'p_member_id': memberId, 'p_full_name': fullName, 'p_display_name_kn': displayNameKn},
    ) as Map<String, dynamic>,
  );

  @override
  Future<List<Map<String, dynamic>>> fetchRows(String table, String column, String value) =>
      _call(() async => await client.from(table).select().eq(column, value).limit(1000));

  @override
  Future<bool> refreshSession() async {
    try {
      final res = await client.auth.refreshSession().timeout(timeout);
      return res.session != null;
    } on AuthException catch (e) {
      if (e is AuthRetryableFetchException) {
        throw RemoteError(RemoteErrorKind.network, e.message);
      }
      return false;
    } on TimeoutException {
      throw RemoteError(RemoteErrorKind.network, 'timeout');
    } on SocketException catch (e) {
      throw RemoteError(RemoteErrorKind.network, e.message);
    }
  }
}
