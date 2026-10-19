# Operations: known limitations and recovery

## Known limitations

- **No background sync while the app is closed.** Android may suspend or kill
  the app; records stay safely on the phone and upload on the next launch or
  resume. Ask family members to open the app once after coming back into
  coverage.
- **First sign-in needs internet** (to authenticate and download the farm).
- **30-day offline limit for new entries.** If a phone has not confirmed its
  membership with the server for 30 days it stays readable but stops accepting
  new entries until it connects once.
- **Invitations are matched by email.** The family member must create their
  account with exactly the invited email address. Email delivery depends on
  the project's SMTP settings (see `docs/SUPABASE_SETUP.md`).
- **One farm per account in the app.** The database supports several farms per
  user; the app uses the first active one.
- **Hourly and piece-rate wages are not implemented.** Attendance supports
  fractional days (e.g. 0.75) and per-day rate overrides; bonuses/additions
  and deductions cover task-based extras.
- **Cost per work type is approximate:** a worker's day wage is split evenly
  across the tasks recorded for them that day; days without a task are
  reported separately.
- **Group-leader logins are not yet available** (`leader` role and
  `farm_members.linked_worker_id` are reserved for it).
- **Settlement payments made after a week ends** are dated to the week's last
  day (the actual time is kept) so the week they settle shows as paid.
- Local data on the phone is protected by Android app sandboxing, not by
  database encryption. App data is excluded from Android cloud backup.
- Weekly statements always use Kannada text (they are meant for workers).

## Recovery procedures

### "Needs your attention" items (Sync screen)

- *Attendance already marked on another phone*: compare both versions; **Keep
  my version** replaces the other (it remains in the audit history), **Use the
  other version** drops yours.
- *Someone else changed this record*: same choice for worker/group/work edits.
- *Leader has only ₹X left*: the money was already distributed from another
  phone. Remove your entry, or record a new distribution with the correct
  amount (or first record more money given to the leader, then **Send again**).
- *Week closed*: ask the owner/admin; they can correct closed weeks (the week
  is then flagged for review) or reopen it.
- Items showing "could not send yet — retrying" are transient server errors and
  retry automatically; **Send again** forces an immediate retry.

### A phone shows "This phone has unsent records" for another account

Someone else's entries on that phone have not reached the cloud. Sign in with
the account shown, connect to the internet and wait for the indicator to turn
green ("All changes synced"), then sign out and sign in with the new account.

### A family member lost access / left the family

Owner: Settings → Family members → ⋮ → **Remove access**. Their past records
stay with their name. Their phone stops syncing at the next attempt; unsent
records stay on that phone and upload automatically if access is restored.

### Phone lost or replaced

Install the app on the new phone and sign in; synced data downloads again.
Records that were never synced on the lost phone cannot be recovered — this is
why the sync indicator shows the number of records still on the device.

### "Could not open saved data" at startup

The local database file is damaged or from an incompatible version. Choose
**Back up and start fresh**: the damaged file is renamed
(`shramasiri-damaged-<time>.sqlite` in the app's documents folder), not
deleted, and synced data downloads again after sign-in. Unsynced records in the
damaged file can be recovered by a developer with `adb` and the SQLite CLI
(table `outbox_ops`, status not in `synced`/`discarded`).

### Wrong date/time on the phone

After one successful sync the app uses server-corrected time for default
dates and shows a warning. Fix the phone's date/time setting (automatic time
recommended).

### Server-side checks (SQL editor, owner/developer)

```sql
-- Recent operations and their outcomes for a farm
select received_at, op_type, status, result->>'code' as code
from sync_operations where farm_id = '<farm-id>' order by received_at desc limit 50;

-- Money currently with each leader
select w.name_kn, private.leader_pool(w.farm_id, w.id)
from workers w where w.farm_id = '<farm-id>' and w.is_leader;

-- Weekly statement exactly as the app shows it
select * from private.period_summary('<farm-id>', '2026-10-12', '2026-10-18');
```

Never edit `financial_transactions` directly (it is blocked anyway): record a
reversal or correction from the app so every phone and the audit trail stay
consistent.

### Rotating keys

If the publishable key is rotated in the Supabase dashboard, rebuild the app
with the new key in `.env`. The service-role key is never in the app, so
rotating it needs no app change.
