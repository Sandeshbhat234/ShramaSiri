# Supabase setup

ShramaSiri needs one Supabase project. No credentials are bundled with the
source; you supply the project URL and **publishable (anon) key** at build
time. The service-role / secret key is never used by the app and must never be
put in `.env` or the build.

## 1. Hosted project (production)

1. Create a project at <https://supabase.com/dashboard>. Choose the
   **Mumbai (ap-south-1)** region for the lowest latency from Karnataka.
2. Apply the migrations in `supabase/migrations/`, in file-name order. Either:
   - CLI:
     ```bash
     npx supabase login
     npx supabase link --project-ref <your-project-ref>
     npx supabase db push
     ```
   - or Dashboard → SQL Editor: run `20261018000001_schema.sql`, then
     `20261018000002_logic.sql`, then `20261018000003_security.sql`.
3. Authentication → Providers → **Email**: enabled. Keep **Confirm email ON**.
   Set the minimum password length to **8**.
4. Authentication → Email Templates. The app verifies emails and resets
   passwords with a **6-digit code typed into the app** (no deep links), so
   both templates must contain the code:
   - **Confirm signup**: add a line such as
     `ನಿಮ್ಮ ದೃಢೀಕರಣ ಸಂಖ್ಯೆ / Your code: {{ .Token }}`
   - **Reset password**: add
     `ಪಾಸ್‌ವರ್ಡ್ ಬದಲಿಸುವ ಸಂಖ್ಯೆ / Reset code: {{ .Token }}`
   The default confirmation link also still works: open it, then sign in
   in the app.
5. Authentication → SMTP: configure your own SMTP sender for production.
   Supabase's built-in sender is rate limited and meant for testing.
6. Database → Publications: confirm `supabase_realtime` includes
   `farm_sync_state` (the security migration adds it). Realtime is only a hint
   to sync sooner; the app also works without it.
7. Project Settings → API Keys: copy the **Project URL** and the
   **publishable key** (`sb_publishable_…`; the legacy `anon` key also works).
8. Create `.env` in the project root from `.env.example`:
   ```
   SUPABASE_URL=https://<ref>.supabase.co
   SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
   ```
9. Build the app (see `docs/ANDROID_BUILD.md`).

### First use

1. The owner installs the app, taps **Create account** (ಖಾತೆ ತೆರೆಯಿರಿ), confirms
   the email, then enters their full name and the farm name. They become the
   farm's owner and default work types are created.
2. The owner opens **Settings → Family members → Invite** and enters each
   family member's name and email.
3. Each family member installs the app and creates an account **with the same
   email**. After confirming it they see the invitation and tap **Join**.

New sign-ups must stay enabled for invited family members to create their
accounts. Anyone else who signs up can only create their *own* empty farm; row
level security prevents them from seeing any other farm.

### Owner/admin roles

- **Owner**: everything, including inviting admins and changing roles.
- **Admin**: like the owner except managing other admins.
- **Family member**: records attendance, work and money, closes weeks; cannot
  archive workers, reverse other people's entries, or change closed weeks.
- `leader` is reserved for a future limited group-leader login; such accounts
  currently see nothing.

Members are never deleted. "Remove access" disables them; their past entries
keep their names.

## 2. Local stack (development and tests)

Requires Docker and Node.js.

```bash
npx supabase start     # applies supabase/migrations automatically
npx supabase status    # shows URL and keys again
npx supabase stop      # stop (data kept); add --no-backup to discard data
```

`supabase/config.toml` uses ports **55421** (API), **55422** (Postgres) and
**55424** (Mailpit, for reading test emails) so the stack can run alongside
other local Supabase projects. Email confirmation is disabled locally to make
testing faster; it stays enabled in hosted projects.

The Android emulator reaches your computer at `10.0.2.2`. Use
`.env.local.example` → `.env.local`:

```
SUPABASE_URL=http://10.0.2.2:55421
SUPABASE_PUBLISHABLE_KEY=<publishable key from npx supabase status>
```

Plain HTTP is allowed **only in debug builds** and only for `10.0.2.2`,
`127.0.0.1` and `localhost` (`android/app/src/debug/res/xml/network_security_config.xml`).
Release builds require HTTPS.

## 3. Database tests

```bash
bash supabase/tests/run_tests.sh          # throwaway container, removed afterwards
KEEP=1 bash supabase/tests/run_tests.sh   # keep the container for inspection
```

The suite creates test users directly in `auth.users`, runs everything inside a
transaction and rolls back; the concurrency test starts two real sessions that
race for the same leader money and the same attendance slot.

## 4. Backups

Hosted projects on paid plans have daily backups (Database → Backups). On the
free plan, take regular logical backups:

```bash
npx supabase db dump --linked -f backup-schema.sql
npx supabase db dump --linked --data-only -f backup-data.sql
```

Keep backups private: they contain the farm's financial records.
