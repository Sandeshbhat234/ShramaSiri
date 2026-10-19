# Database

Postgres (Supabase) is authoritative; each phone keeps a Drift/SQLite mirror
with identical column names plus a local `sync_status`. Migrations:

| File | Contents |
|---|---|
| `supabase/migrations/20261018000001_schema.sql` | tables, constraints, indexes, sequencing/revision/immutability triggers |
| `supabase/migrations/20261018000002_logic.sql` | helpers, accounting functions, operation handlers, RPC endpoints |
| `supabase/migrations/20261018000003_security.sql` | RLS policies, grants, Realtime publication |

Local schema: `lib/data/db/tables.dart` (`schemaVersion` 1 in
`database.dart`; add stepwise `onUpgrade` migrations when it changes and never
drop `outbox_ops`).

## Conventions

- UUID primary keys generated on the device (so records can be created
  offline), except child link tables keyed by their parent pair.
- Every farm-owned row has `farm_id`; foreign keys are composite
  `(farm_id, id)` so a row can never reference another farm's worker.
- Money: `bigint` **paise** everywhere (₹1 = 100). No floating point.
- Business dates: `date` (`YYYY-MM-DD`) in Asia/Kolkata. Instants:
  `timestamptz` (UTC), shown in IST.
- `server_seq`: per-farm change number for incremental sync.
- `revision`: server-managed version for optimistic concurrency on mutable rows.
- Nothing is hard-deleted: workers/groups are archived, members disabled,
  child links flagged (`active` / `removed`), money reversed.

## Tables

| Table | Purpose |
|---|---|
| `farms` | farm name, wage-week start day (ISO 1–7, default Monday), timezone |
| `farm_sync_state` | per-farm sequence counter (also the Realtime signal) |
| `user_profiles` | one per auth user: full name, Kannada name |
| `farm_members` | membership per farm: role (`owner`/`admin`/`member`/`leader`), status (`invited`/`active`/`disabled`), name snapshot, `linked_worker_id` for future leader logins |
| `workers` | Kannada/English name, phone, default daily wage, leader flag, status |
| `worker_groups`, `worker_group_memberships` | crews, their leader and members (membership toggled, not deleted) |
| `attendance` | one row per farm/worker/day: `units_milli` (1000 = full day), `rate_paise` snapshot, generated `earned_paise` |
| `work_types`, `work_assignments`, `work_assignment_workers` | work diary; independent of wages |
| `financial_transactions` | the single append-only money ledger (below) |
| `settlements`, `settlement_items` | week closed/reviewed markers and per-worker snapshots taken at closing |
| `audit_events` | who did what, before/after JSON, device, operation id |
| `sync_operations` | idempotency record per client `op_id` (not readable by clients) |

### Why fewer tables than the initial list

The brief suggested separate tables for wage adjustments, payment
allocations, leader fund transfers, distributions, returns and a change log.
They are folded into two mechanisms to keep **one coherent accounting
model** and one sync path:

- `wage_adjustments`, `payment_allocations`, `leader_fund_transfers`,
  `leader_distributions`, `leader_fund_returns` → entry types in
  `financial_transactions`. All money shares the same immutability, reversal,
  audit and sync rules, and balances are simple sums over one table.
- `sync_change_log` → a `server_seq` column on every synced table (per-farm,
  ordered). Rows are pulled directly, so updates don't duplicate data in a
  log table.

## Accounting model

Each ledger row has an `entry_type`, a positive `amount_paise` (signed only for
`opening_balance`), a `worker_id` (whose account it affects) and for leader
distributions a `leader_worker_id`. A **reversal** row (`is_reversal`,
`reverses_id`) repeats the original's type and amount and applies the effect
negated; an entry can be reversed only once (unique index).

| Type | Wage balance (farm owes worker) | Loan | Farm cash | Leader money |
|---|---|---|---|---|
| `advance` | − paid (advance) | | out | |
| `wage_payment` | − paid | | out | |
| `bonus` | + earned and − paid | | out | |
| `addition` | + earned | | | |
| `deduction` | − earned | | | |
| `opening_balance` | ± earned (signed) | | | |
| `loan` | | + | out | |
| `loan_repayment` | | − | in | |
| `loan_offset` | − paid (wages applied to loan) | − | | |
| `reimbursement` | (not wages) | | out | repays leader's own-pocket payable when linked |
| `leader_transfer` | (not the leader's wages) | | out | leader pool + |
| `leader_allocation` | recipient − paid (via leader) | | **none** | leader pool − |
| `leader_return` | | | in | leader pool − |
| `leader_self_funded` | recipient − paid (via leader) | | none | farm owes leader + |

Derived figures (never stored as running balances):

- **Wage balance** = Σ attendance earned + Σ earned effects − Σ paid effects,
  up to a date. Positive = wages still owed; negative = paid ahead (advance)
  and carried forward with its sign.
- **Weekly statement** (`private.period_summary`, mirrored in
  `SettlementRepo`): opening = balance before the week; then units, gross,
  additions, advances, direct payments, payments via leader; closing =
  opening + gross + additions − advances − direct − via leader.
- **Leader unreconciled** = transfers − allocations − returns.
- **Labour expense** = attendance + bonus + additions − deductions (opening
  balances and reimbursements are not labour expense).
- **Cash out** = cash types only; distributions from entrusted money are
  reconciliation, not new cash.

The same coefficient table drives the Dart reference (`LedgerMath`) and the
SQLite aggregates (`LedgerSql`); a randomized test checks they agree.

### Server-side guards

- Leader allocations/returns lock the leader's worker row and must not exceed
  the money still held; reversing a transfer whose money was distributed is
  refused.
- Loan repayments/offsets cannot exceed the loan; reimbursements linked to
  own-pocket payments cannot exceed what is owed.
- Payer must be a member of the farm; payer and recorder names are
  snapshotted on the row.
- Members cannot change a **closed week**; owners/admins can, and the
  settlement is flagged `needs_review` (its snapshot is kept until reviewed).
- Rows in `financial_transactions` and `audit_events` cannot be updated or
  deleted by anyone (trigger).

## RPC endpoints

| Function | Use |
|---|---|
| `get_my_context()` | user id/email, memberships, pending invitations, server time |
| `create_farm(id, name, full_name, kannada_name)` | owner onboarding (idempotent) |
| `accept_invitation(member_id, full_name, kannada_name)` | invited member joins (email must match a confirmed account) |
| `apply_ops(ops jsonb)` | upload up to 50 operations; per-op savepoints; idempotent by `op_id` |
| `pull_changes(farm, after_seq, limit)` | incremental download in seq order |

All are `SECURITY DEFINER` with an empty `search_path`, executable only by the
`authenticated` role. Helper functions live in the unexposed `private` schema.

## Row level security

Every table has RLS enabled. Authenticated users may `SELECT` rows of farms
where they are an active owner/admin/member (`private.my_farm_ids()`); profiles
of co-members are visible. There are no insert/update/delete policies or
grants; `sync_operations` has no policies at all. `anon` has no access. The
SQL test suite checks cross-farm reads, direct writes, private helpers,
replayed foreign op ids, anonymous access and disabled members.
