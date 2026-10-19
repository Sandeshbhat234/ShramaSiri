# Architecture: offline-first synchronization

## Principles

1. **The phone's SQLite database is the source of truth for the screen.**
   Every screen reads from Drift streams; nothing waits for the network.
2. **Every write is local first and atomic.** A repository validates input,
   then in **one SQLite transaction** writes the row and appends an
   operation to the durable outbox (`outbox_ops`). Either both are saved or
   neither is.
3. **The server is the authority.** Supabase applies operations through a
   single RPC (`apply_ops`) that checks membership, role and business rules,
   writes, audits and returns the authoritative rows. Clients have read-only
   table access (RLS); they cannot write tables directly.
4. **Money is append-only.** Financial entries are never updated or deleted;
   mistakes are fixed with explicit reversal rows (see `docs/DATABASE.md`).
5. **Never lose, never duplicate.** Operations have client-generated UUIDs;
   the server remembers each `op_id` and replays the stored result on retry.

```
 UI ──reads──▶ Drift (SQLite) ◀──applies── ChangeApplier ◀── pull_changes ─┐
  │                ▲                                                        │
  └─writes─▶ Repository ─(1 txn)─▶ rows + outbox_ops ──▶ SyncEngine ──▶ apply_ops
                                                             ▲            (Supabase RPC)
        triggers: start · resume · connectivity · local write · Realtime · every 5 min · "Sync now"
```

## Operations

An outbox row stores: `op_id` (UUID), farm, actor user, device id, op type,
entity table + id, JSON payload, status, attempts, next attempt time, last
error code, conflict data, timestamps.

Op types: `worker_upsert`, `group_upsert`, `attendance_upsert`,
`work_type_upsert`, `work_assignment_upsert`, `ledger_create`,
`ledger_reverse`, `ledger_correct` (reverse + replacement atomically),
`settlement_close`, `settlement_reopen`, `farm_update`, `profile_update`,
`member_invite`, `member_update`.

Unsent edits to the same record are **coalesced** into the pending op (only
while it has never been attempted; an attempted op may already be committed on
the server, so it is never changed).

### Statuses

| Status | Meaning | Shown as |
|---|---|---|
| `pending` | saved on device, waiting | Saved on device (ಸಾಧನದಲ್ಲಿ ಉಳಿಸಲಾಗಿದೆ) |
| `syncing` | upload in flight (reset to pending if the app dies) | Syncing |
| `synced` | server confirmed | Synced (ಸಿಂಕ್ ಆಗಿದೆ) |
| `failed` | transient server error; retried with backoff | Saved on device / retrying |
| `needs_review` | conflict with someone else's change | Needs review |
| `rejected` | server refused (e.g. leader funds already used) | Not accepted |
| `discarded` | user chose the other version / removed the entry | — |

Rows mirror this in `sync_status` (0 synced, 1 pending, 2 needs review,
3 rejected). Rejected rows are excluded from all totals.

## Upload (push)

- One sync cycle runs at a time per device (single-flight); requests during a
  cycle fold into one follow-up cycle. The test suite checks that parallel
  sync calls never produce parallel uploads.
- Each cycle first calls `get_my_context` to **revalidate membership** before
  uploading anything, and records the server clock skew.
- Batches of up to 25 ops are sent **in creation order**. A batch stops (rather
  than skipping ahead) at an op that must wait, so a dependent op (e.g.
  attendance for a newly created worker) never overtakes its prerequisite. Ops
  for a record awaiting a conflict decision are held back.
- At most one op per record per batch; its **base revision** is read at send
  time from the local row (the revision of the server version the edit was
  made on).
- Server answers per op: `applied` (rows returned and applied),
  `conflict` (both versions kept for review), `rejected` (reason code) or a
  retryable error. Lost responses are safe: the next send replays the same
  `op_id` and the server returns the stored result.
- Backoff: network failures put ops back to pending (sent again on the next
  trigger); server errors use per-op exponential backoff with jitter (5 s up to
  15 min); whole-cycle retries back off 10 s up to 10 min.

## Download (pull)

- Every synced row has a per-farm `server_seq`. Taking a number locks the
  farm's `farm_sync_state` row until commit, so numbers become visible in
  order: a client reading up to N will never later discover a row < N. The
  cursor is therefore exact, and a lost Realtime message only delays syncing.
- `pull_changes(farm, after, limit)` returns up to 500 changes in seq order;
  each page is applied and the cursor saved in one transaction (crash safe).
- The first sign-in on a device downloads everything this way.

## Applying server rows (ChangeApplier)

- If the record has **unsent local changes**, the server version is stored in
  `server_shadows` instead of overwriting the user's pending work. It is
  applied once the local changes are confirmed or discarded.
- Older copies (lower `server_seq`) never overwrite newer ones.
- Natural-key collisions (two phones marking the same worker for the same day
  offline, or closing the same week) are detected: if the local row is still
  pending, the server row is held back and the conflict is surfaced; otherwise
  the stale local row is replaced.

## Conflicts

| Data | Rule |
|---|---|
| Money entries | Never conflict: every entry is a new immutable row, so two advances from two phones both count. Reversing an already-reversed entry is reported, not repeated. |
| Leader distributions | Server checks the leader's remaining money under a row lock. An offline distribution is shown as *Pending verification* and, if the money was already given out from another phone, comes back *Not accepted* with the amount still available. |
| Attendance | One row per farm/worker/day. A second phone's offline entry for the same day returns `attendance_exists`; the user compares both and keeps one. Editing a stale version returns `stale_revision`. Nothing is summed and the overwritten version stays in the audit log. |
| Worker, group, work, farm, member edits | Optimistic concurrency on `revision`. A stale edit returns `stale_revision`; the user keeps their version (re-sent on top of the other) or uses the other version. |

Resolution UI: Sync screen → "Needs your attention" shows both versions side
by side with **Keep my version / Use the other version / Remove my entry /
Send again** as appropriate.

## Triggers

Sync runs on app start, on resume, when connectivity returns (debounced 2 s;
connectivity is only a hint, the server reachability is checked by the cycle
itself), 1.5 s after a local write, 1 s after a Realtime change signal on the
farm's `farm_sync_state` row, every 5 minutes while in the foreground, and on
**Sync now**. There is no background sync when Android has suspended the app;
the next launch or resume is the guaranteed recovery path. (A WorkManager
background job was deliberately left out to keep the app light and avoid
OS-specific restrictions.)

## Authentication and offline access

- First sign-in and the first download need internet. After that, the app
  opens from the local database without network.
- The Supabase session (access + refresh token) is stored with
  `flutter_secure_storage` (Android Keystore), never in plain preferences.
  Passwords are never stored.
- **Account binding:** the local database belongs to one user. If a
  different account signs in while unsent records exist, the app refuses and
  asks for the original account first; with nothing unsent, the local data is
  wiped before the new account downloads its farm.
- **Sign out:** if everything is synced, local data is wiped. Otherwise it
  stays (bound to that account) and uploads after the same account signs in
  again.
- **Prolonged offline use:** if membership has not been confirmed by the
  server for **30 days**, the app keeps showing data but blocks new entries
  until it reconnects (`maxOfflineVerificationAge`).
- **Revoked access:** when the server reports the membership disabled, uploads
  stop, nothing is discarded, and the app shows "Access removed" (with
  "Check again" and "Sign out").
- **Expired session:** pending records are kept; the sync indicator asks the
  user to sign in again.
- **Wrong phone clock:** dates default to server-corrected time once the
  phone has synced; a banner warns when the clock is off by > 30 minutes.

## Security summary

- RLS on every table; reads limited to farms where the user is an active
  owner/admin/member. `sync_operations` is not readable at all.
- No INSERT/UPDATE/DELETE grants for API roles; writes only through
  SECURITY DEFINER functions with `search_path = ''`, which derive the actor
  from `auth.uid()` (client-supplied actor ids are ignored).
- Financial and audit rows are immutable at the database level (trigger).
- Release builds are HTTPS-only; Android cloud backup and device transfer of
  app data are disabled.

## Performance notes

- Drift runs on a background isolate; all lists use indexed queries with
  paging ("Show more").
- Balances and weekly statements are SQL aggregates generated from the same
  coefficient table as the Dart reference implementation
  (`lib/domain/ledger.dart`), verified equal by a randomized test.
- Incremental pulls only; no polling besides the 5-minute foreground check.
- Synced outbox entries are trimmed after 30 days; unsynced ones never are.
