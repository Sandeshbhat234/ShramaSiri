# ShramaSiri (ಶ್ರಮಸಿರಿ)

A small, offline-first Android app for a family farm in Karnataka: daily labour
attendance, farm work diary, wages, advances, loans, group-leader cash, weekly
settlements and simple reports. Kannada first, English optional.

It is a notebook, not payroll software. Every screen works without internet;
records sync safely between family members' phones when a connection is
available.

## What it does

| Area | Highlights |
|---|---|
| Attendance | One tap per worker (full / half / absent / custom days), group quick-mark, add an occasional worker inline, any past date, one record per worker per day |
| Workers & groups | Kannada names, per-worker daily wage (history keeps the old rate), leaders, groups, archive instead of delete |
| Work diary | Tasks with several workers, several tasks per worker; tasks never multiply wages |
| Money | Give Money in four steps (worker → amount → purpose → paid by), advances, wage payments, bonus, loans, reimbursements, adjustments, previous balances; "paid by" and "recorded by" kept separately with actual names |
| Group leaders | Money entrusted vs. confirmed distributed vs. returned vs. unaccounted; distributions never count as new cash; overspending is impossible |
| Weekly settlement | Per-worker statement with carried-forward balances (derived from the ledger), one-tap pay, close/review/reopen a week, share a Kannada statement |
| Reports | Labour cost (earned), cash paid out, balances, leader cash, attendance, approximate cost per work type, CSV export |
| Sync | Durable outbox, idempotent uploads, incremental download, Realtime hints, conflict review, diagnostics |
| Security | Supabase Auth, row-level security per farm, all writes through audited server functions, session in Android encrypted storage, no cloud backup of farm data |

## Repository layout

```
lib/
  app/          app root, theme, boot (sign-in/onboarding gate), providers, sync triggers
  core/         money (integer paise), IST dates, ids, build config
  domain/       ledger.dart - the accounting model (single source of the rules)
  data/
    db/         Drift tables + database (local source of truth)
    remote/     Supabase API wrapper, secure session storage
    repositories/  all local writes (validate -> transaction -> outbox)
    sync/       outbox, sync engine, change applier, conflict resolver
  ui/           screens (home, workers, attendance, work, money, leader, settlement, reports, sync, settings, auth)
  l10n/         app_kn.arb / app_en.arb (+ generated)
supabase/
  migrations/   schema, server logic (RPCs), RLS/security
  tests/        SQL tests (RLS, scenarios) and concurrency race tests
  config.toml   local stack (ports 554xx)
test/           unit, sync scenario, UI smoke and end-to-end tests
docs/           setup, architecture, database, build and operations guides
```

## Quick start (developer)

Prerequisites: Flutter 3.47+ (Dart 3.13), Android SDK 36, JDK 17, Docker (for
the local Supabase stack), Node.js (for `npx supabase`).

```bash
flutter pub get
dart run build_runner build      # Drift code generation (lib/data/db/database.g.dart)
flutter gen-l10n

# Local backend (Docker). Prints the local URL and publishable key.
npx supabase start
cp .env.local.example .env.local  # paste the publishable key printed above

flutter run --dart-define-from-file=.env.local
```

For a real (hosted) Supabase project follow
[docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md) and create `.env` from
`.env.example`.

## Tests

```bash
flutter test                                   # unit, sync scenarios, UI smoke (E2E tests skip)
bash supabase/tests/run_tests.sh               # SQL + concurrency tests in a throwaway Postgres container

# End-to-end against the local stack (npx supabase start):
SHRAMASIRI_E2E_URL=http://127.0.0.1:55421 \
SHRAMASIRI_E2E_KEY=<local publishable key> \
flutter test test/integration/supabase_e2e_test.dart
```

What is covered: the scenarios A–L from the specification (offline payments,
simultaneous advances, lost acknowledgements, leader distribution, concurrent
allocations, attendance conflicts, wage changes, partial settlement, payer vs
recorder, multi-day offline with restarts, cross-farm access, backdated
corrections) at three levels: SQL against Postgres (including real
concurrent sessions), the Dart sync engine against an in-memory server, and the
real app code against a real Supabase stack. A UI smoke test renders every
screen at 360×640 dp in Kannada with 1.3× system font size.

## Build for Android

See [docs/ANDROID_BUILD.md](docs/ANDROID_BUILD.md).

```bash
flutter build apk --release --split-per-abi --dart-define-from-file=.env
flutter build appbundle --release --dart-define-from-file=.env
```

## Documentation

- [docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md) — hosted and local backend setup, auth email templates
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — offline-first sync design, conflicts, security model
- [docs/DATABASE.md](docs/DATABASE.md) — schema, accounting model, RLS, server functions
- [docs/ANDROID_BUILD.md](docs/ANDROID_BUILD.md) — signing, release builds, Windows notes
- [docs/OPERATIONS.md](docs/OPERATIONS.md) — known limitations and recovery procedures
