-- ShramaSiri database tests. Run against a disposable database that has the
-- migrations applied (see supabase/tests/run_tests.sh). Everything runs in one
-- transaction and is rolled back.
\set ON_ERROR_STOP 1
\set QUIET 1
begin;

create schema tests;
grant usage on schema tests to authenticated, anon;

create function tests.check(p_ok boolean, p_msg text) returns void language plpgsql as $$
begin
  if p_ok is distinct from true then
    raise exception 'FAILED: %', p_msg;
  end if;
  raise notice 'ok - %', p_msg;
end $$;

create function tests.op(p_op_id uuid, p_farm uuid, p_type text, p_payload jsonb, p_base integer default 0)
returns jsonb language sql as $$
  select (public.apply_ops(jsonb_build_array(jsonb_build_object(
    'op_id', p_op_id, 'farm_id', p_farm, 'op_type', p_type, 'payload', p_payload,
    'base_revision', p_base, 'device_id', 'test-device', 'entity_id', p_payload->>'id'))))->0;
$$;

create function tests.act_as(p_uid uuid) returns void language sql as $$
  select set_config('request.jwt.claim.sub', p_uid::text, false),
         set_config('request.jwt.claims', jsonb_build_object('sub', p_uid, 'role', 'authenticated')::text, false);
$$;
grant execute on all functions in schema tests to authenticated, anon;

-- Fixed ids keep the script readable.
\set owner   '''a0000000-0000-4000-8000-000000000001'''
\set dad     '''a0000000-0000-4000-8000-000000000002'''
\set other   '''a0000000-0000-4000-8000-000000000003'''
\set farm1   '''f0000000-0000-4000-8000-000000000001'''
\set farm2   '''f0000000-0000-4000-8000-000000000002'''
\set w1      '''b0000000-0000-4000-8000-000000000001'''
\set w2      '''b0000000-0000-4000-8000-000000000002'''
\set w3      '''b0000000-0000-4000-8000-000000000003'''
\set w4      '''b0000000-0000-4000-8000-000000000004'''
\set w5      '''b0000000-0000-4000-8000-000000000005'''
\set leader  '''b0000000-0000-4000-8000-00000000000a'''
\set otherw  '''b0000000-0000-4000-8000-0000000000ff'''

-- Real GoTrue has email_confirmed_at (confirmed_at is generated from it); the
-- bare Postgres image only has confirmed_at.
create function tests.add_user(p_id uuid, p_email text) returns void language plpgsql as $$
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'auth' and table_name = 'users' and column_name = 'email_confirmed_at') then
    execute 'insert into auth.users (id, email, email_confirmed_at) values ($1, $2, now())' using p_id, p_email;
  else
    execute 'insert into auth.users (id, email, confirmed_at) values ($1, $2, now())' using p_id, p_email;
  end if;
end $$;
select tests.add_user(:owner, 'sandesh@example.com');
select tests.add_user(:dad, 'ramesh@example.com');
select tests.add_user(:other, 'stranger@example.com');

-- Onboarding ---------------------------------------------------------------
set role authenticated;
select tests.act_as(:owner);
select tests.check((public.create_farm(:farm1, 'Bhat Farm', 'Sandesh Bhat')->'memberships'->0->>'role') = 'owner',
                   'owner creates farm');
select tests.check((public.create_farm(:farm1, 'Bhat Farm', 'Sandesh Bhat')->'memberships'->0->>'farm_id')::uuid = :farm1,
                   'create_farm is idempotent for the same owner');
select tests.check((select count(*) from public.work_types where farm_id = :farm1) = 6, 'default work types seeded');

select tests.act_as(:other);
select public.create_farm(:farm2, 'Other Farm', 'Other Owner');

select tests.act_as(:owner);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'member_invite',
  jsonb_build_object('id', gen_random_uuid(), 'email', 'Ramesh@Example.com', 'full_name', 'Ramesh Bhat'))->>'status' = 'applied',
  'owner invites a family member');

select tests.act_as(:dad);
select tests.check(jsonb_array_length(public.get_my_context()->'invitations') = 1, 'invitee sees invitation');
select public.accept_invitation(((public.get_my_context()->'invitations'->0)->>'member_id')::uuid, 'Ramesh Bhat');
select tests.check((public.get_my_context()->'memberships'->0->>'status') = 'active', 'invitee joined farm');

-- Workers -------------------------------------------------------------------
select tests.act_as(:owner);
select tests.op(gen_random_uuid(), :farm1, 'worker_upsert', jsonb_build_object('id', :w1, 'name_kn', 'ಮಂಜುನಾಥ', 'default_wage_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'worker_upsert', jsonb_build_object('id', :w2, 'name_kn', 'ರಮೇಶ', 'default_wage_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'worker_upsert', jsonb_build_object('id', :w3, 'name_kn', 'ಗಣೇಶ', 'default_wage_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'worker_upsert', jsonb_build_object('id', :w4, 'name_kn', 'ಸುರೇಶ', 'default_wage_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'worker_upsert', jsonb_build_object('id', :w5, 'name_kn', 'ಮಹೇಶ', 'default_wage_paise', 50000));
select tests.check(tests.op(gen_random_uuid(), :farm1, 'worker_upsert',
  jsonb_build_object('id', :leader, 'name_kn', 'ನಾಯಕ', 'default_wage_paise', 60000, 'is_leader', true))->>'status' = 'applied',
  'leader worker created');
select tests.check((select count(*) from public.workers where farm_id = :farm1) = 6, 'six workers exist');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'worker_upsert',
  jsonb_build_object('id', :w1, 'name_kn', 'x', 'default_wage_paise', 50000))->>'code' = 'already_exists',
  'creating an existing worker id is a conflict');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'worker_upsert',
  jsonb_build_object('id', gen_random_uuid(), 'name_kn', 'x', 'default_wage_paise', -5))->>'code' = 'invalid_amount',
  'negative wage rejected');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'worker_upsert',
  jsonb_build_object('id', 'not-a-uuid', 'name_kn', 'x', 'default_wage_paise', 5))->>'code' = 'invalid_data',
  'malformed uuid rejected as invalid_data');

-- Stale worker edit from another device is a conflict, not an overwrite.
select tests.act_as(:dad);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'worker_upsert',
  jsonb_build_object('id', :w3, 'name_kn', 'ಗಣೇಶ ಕೆ', 'default_wage_paise', 50000), 1)->>'status' = 'applied',
  'member edits worker at revision 1');
select tests.act_as(:owner);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'worker_upsert',
  jsonb_build_object('id', :w3, 'name_kn', 'ಗಣಪತಿ', 'default_wage_paise', 50000), 1)->>'code' = 'stale_revision',
  'second edit at stale revision is a conflict');
select tests.check((select name_kn from public.workers where id = :w3) = 'ಗಣೇಶ ಕೆ', 'first edit preserved');

-- Members cannot archive workers.
select tests.act_as(:dad);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'worker_upsert',
  jsonb_build_object('id', :w3, 'name_kn', 'ಗಣೇಶ ಕೆ', 'default_wage_paise', 50000, 'status', 'archived'), 2)->>'code' = 'forbidden',
  'member cannot archive a worker');

-- Scenario C: duplicate upload / lost acknowledgement -----------------------
select tests.act_as(:owner);
create temp table c_op as select gen_random_uuid() as op_id, gen_random_uuid() as entry_id;
grant select on c_op to authenticated;
select tests.check(tests.op((select op_id from c_op), :farm1, 'ledger_create', jsonb_build_object(
  'id', (select entry_id from c_op), 'entry_type', 'wage_payment', 'worker_id', :w1, 'amount_paise', 100000,
  'business_date', '2026-10-12'))->>'status' = 'applied', 'scenario C: first upload applied');
select tests.check((tests.op((select op_id from c_op), :farm1, 'ledger_create', jsonb_build_object(
  'id', (select entry_id from c_op), 'entry_type', 'wage_payment', 'worker_id', :w1, 'amount_paise', 100000,
  'business_date', '2026-10-12'))->>'replayed')::boolean, 'scenario C: retry returns stored result');
select tests.check((select count(*) from public.financial_transactions where id = (select entry_id from c_op)) = 1,
  'scenario C: exactly one payment exists');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', (select entry_id from c_op), 'entry_type', 'wage_payment', 'worker_id', :w1, 'amount_paise', 100000,
  'business_date', '2026-10-12'))->>'code' = 'already_exists', 'same entry id under a new op id is not duplicated');

-- Scenario B: simultaneous advances from two people -------------------------
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'advance', 'worker_id', :w2, 'amount_paise', 50000, 'business_date', '2026-10-13'));
select tests.act_as(:dad);
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'advance', 'worker_id', :w2, 'amount_paise', 30000, 'business_date', '2026-10-13'));
select tests.check((select sum(amount_paise) from public.financial_transactions
                    where worker_id = :w2 and entry_type = 'advance') = 80000,
  'scenario B: both advances count (800 rupees)');

-- Scenario I: mixed payer / recorder ----------------------------------------
select tests.act_as(:owner);
create temp table i_entry as select gen_random_uuid() as id;
grant select on i_entry to authenticated;
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', (select id from i_entry), 'entry_type', 'advance', 'worker_id', :w3, 'amount_paise', 50000,
  'business_date', '2026-10-14', 'paid_by', :dad));
select tests.check((select paid_by = :dad and paid_by_name = 'Ramesh Bhat' and recorded_by = :owner
                           and recorded_by_name = 'Sandesh Bhat'
                    from public.financial_transactions where id = (select id from i_entry)),
  'scenario I: paid by and recorded by are both preserved with names');
select tests.check((select actor_id = :owner and after_data->>'paid_by' = :dad
                    from public.audit_events where entity_id = (select id from i_entry)),
  'scenario I: audit keeps both ids');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'advance', 'worker_id', :w3, 'amount_paise', 500,
  'business_date', '2026-10-14', 'paid_by', :other))->>'code' = 'invalid_payer',
  'payer must be a member of the farm');

-- Scenario D: leader distribution -------------------------------------------
create temp table d_transfer as select gen_random_uuid() as id;
grant select on d_transfer to authenticated;
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', (select id from d_transfer), 'entry_type', 'leader_transfer', 'worker_id', :leader, 'amount_paise', 400000,
  'business_date', '2026-10-15'))->>'status' = 'applied', 'scenario D: 4000 entrusted to leader');
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_allocation', 'worker_id', :w1, 'leader_worker_id', :leader,
  'amount_paise', 100000, 'business_date', '2026-10-16'));
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_allocation', 'worker_id', :w2, 'leader_worker_id', :leader,
  'amount_paise', 150000, 'business_date', '2026-10-16'));
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_allocation', 'worker_id', :w3, 'leader_worker_id', :leader,
  'amount_paise', 100000, 'business_date', '2026-10-16'));
reset role;
select tests.check(private.leader_pool(:farm1, :leader) = 50000, 'scenario D: 500 unreconciled');
select tests.check((select sum(amount_paise) from public.financial_transactions
                    where farm_id = :farm1 and entry_type = 'leader_allocation') = 350000,
  'scenario D: 3500 confirmed distributed');
select tests.check((select count(*) from public.financial_transactions
                    where farm_id = :farm1 and entry_type = 'leader_allocation' and method <> 'none') = 0,
  'scenario D: allocations are not cash outflows');
select tests.check((select sum(amount_paise) from public.financial_transactions
                    where farm_id = :farm1 and entry_type = 'leader_transfer') = 400000,
  'scenario D: farm cash outflow to leader is 4000');

-- Scenario E: two allocations of the same remaining 500 ----------------------
set role authenticated;
select tests.act_as(:owner);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_allocation', 'worker_id', :w4, 'leader_worker_id', :leader,
  'amount_paise', 50000, 'business_date', '2026-10-17'))->>'status' = 'applied', 'scenario E: first 500 allocated');
select tests.act_as(:dad);
select tests.check((select r->>'code' = 'insufficient_leader_funds' and (r->'data'->>'available_paise')::bigint = 0
                    from tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_allocation', 'worker_id', :w5, 'leader_worker_id', :leader,
  'amount_paise', 50000, 'business_date', '2026-10-17')) r), 'scenario E: second 500 rejected with available amount');
reset role;
select tests.check(private.leader_pool(:farm1, :leader) = 0, 'scenario E: no overspending');
set role authenticated;

-- Leader return and reversal guards.
select tests.act_as(:owner);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_reverse', jsonb_build_object(
  'id', gen_random_uuid(), 'reverses_id', (select id from d_transfer), 'reason', 'typo'))->>'code' = 'leader_funds_already_used',
  'cannot reverse a transfer whose money was already distributed');
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_transfer', 'worker_id', :leader, 'amount_paise', 20000, 'business_date', '2026-10-17'));
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_return', 'worker_id', :leader, 'amount_paise', 20000, 'business_date', '2026-10-17'))->>'status' = 'applied',
  'leader returns unused cash');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_return', 'worker_id', :leader, 'amount_paise', 1, 'business_date', '2026-10-17'))->>'code' = 'insufficient_leader_funds',
  'cannot return more than held');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'leader_transfer', 'worker_id', :w1, 'amount_paise', 100, 'business_date', '2026-10-17'))->>'code' = 'not_a_leader',
  'funds can only be entrusted to a leader');

-- Reversals ---------------------------------------------------------------
select tests.act_as(:dad);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_reverse', jsonb_build_object(
  'id', gen_random_uuid(), 'reverses_id', (select entry_id from c_op), 'reason', 'wrong'))->>'code' = 'forbidden',
  'member cannot reverse an entry someone else recorded');
select tests.act_as(:owner);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_reverse', jsonb_build_object(
  'id', gen_random_uuid(), 'reverses_id', (select entry_id from c_op), 'reason', 'entered twice'))->>'status' = 'applied',
  'owner reverses a payment');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_reverse', jsonb_build_object(
  'id', gen_random_uuid(), 'reverses_id', (select entry_id from c_op), 'reason', 'again'))->>'code' = 'already_reversed',
  'an entry cannot be reversed twice');
select tests.check((select count(*) from public.financial_transactions where id = (select entry_id from c_op)) = 1,
  'original payment row still exists after reversal');

-- Loans are separate from wages.
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'loan', 'worker_id', :w4, 'amount_paise', 200000, 'business_date', '2026-10-01'));
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'loan_offset', 'worker_id', :w4, 'amount_paise', 300000, 'business_date', '2026-10-02'))->>'code' = 'exceeds_loan_balance',
  'loan offset cannot exceed loan balance');

-- Scenario F: attendance conflict -------------------------------------------
create temp table f_att as select gen_random_uuid() as a1, gen_random_uuid() as a2;
grant select on f_att to authenticated;
select tests.check(tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', (select a1 from f_att), 'worker_id', :w1, 'work_date', '2026-10-15', 'units_milli', 1000, 'rate_paise', 50000))->>'status' = 'applied',
  'scenario F: device A marks full day');
select tests.act_as(:dad);
select tests.check((select r->>'code' = 'attendance_exists' and r->'rows'->0->'d'->>'id' = (select a1 from f_att)::text
                    from tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', (select a2 from f_att), 'worker_id', :w1, 'work_date', '2026-10-15', 'units_milli', 500, 'rate_paise', 50000)) r),
  'scenario F: device B gets a conflict with the existing record');
select tests.check((select count(*) from public.attendance where worker_id = :w1 and work_date = '2026-10-15') = 1,
  'scenario F: no duplicate attendance');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', (select a1 from f_att), 'worker_id', :w1, 'work_date', '2026-10-15', 'units_milli', 500, 'rate_paise', 50000), 1)->>'status' = 'applied',
  'scenario F: resolution updates the existing record at its revision');
select tests.act_as(:owner);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', (select a1 from f_att), 'worker_id', :w1, 'work_date', '2026-10-15', 'units_milli', 1000, 'rate_paise', 50000), 1)->>'code' = 'stale_revision',
  'scenario F: concurrent edit at the old revision is a conflict');
select tests.check((select earned_paise = 25000 and revision = 2 from public.attendance where id = (select a1 from f_att)),
  'scenario F: wage is consistent with the surviving version');
reset role;
select tests.check((select count(*) from public.audit_events where entity_id = (select a1 from f_att)) = 2,
  'scenario F: both versions are in the audit trail');
set role authenticated;

-- Scenario G: wage rate change ----------------------------------------------
select tests.act_as(:owner);
select tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', gen_random_uuid(), 'worker_id', :w4, 'work_date', '2026-10-13', 'units_milli', 1000, 'rate_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'worker_upsert', jsonb_build_object('id', :w4, 'name_kn', 'ಸುರೇಶ', 'default_wage_paise', 60000), 1);
select tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', gen_random_uuid(), 'worker_id', :w4, 'work_date', '2026-10-14', 'units_milli', 1000, 'rate_paise', 60000));
select tests.check((select earned_paise from public.attendance where worker_id = :w4 and work_date = '2026-10-13') = 50000,
  'scenario G: old attendance keeps 500');
select tests.check((select earned_paise from public.attendance where worker_id = :w4 and work_date = '2026-10-14') = 60000,
  'scenario G: new attendance uses 600');

-- Scenario H + L: weekly settlement and backdated correction ----------------
-- Week of Mon 2026-10-05 .. Sun 2026-10-11 for worker 5.
create temp table h_att as select gen_random_uuid() as d1;
grant select on h_att to authenticated;
select tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', (select d1 from h_att), 'worker_id', :w5, 'work_date', '2026-10-05', 'units_milli', 1000, 'rate_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', gen_random_uuid(), 'worker_id', :w5, 'work_date', '2026-10-06', 'units_milli', 1000, 'rate_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', gen_random_uuid(), 'worker_id', :w5, 'work_date', '2026-10-07', 'units_milli', 1000, 'rate_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', gen_random_uuid(), 'worker_id', :w5, 'work_date', '2026-10-08', 'units_milli', 1000, 'rate_paise', 50000));
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'advance', 'worker_id', :w5, 'amount_paise', 50000, 'business_date', '2026-10-06'));
select tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'wage_payment', 'worker_id', :w5, 'amount_paise', 100000, 'business_date', '2026-10-11'));
reset role;
select tests.check((select gross_paise = 200000 and advances_paise = 50000 and direct_paid_paise = 100000
                           and closing_paise = 50000 and units_milli = 4000
                    from private.period_summary(:farm1, '2026-10-05', '2026-10-11') where worker_id = :w5),
  'scenario H: earned 2000 - advance 500 - paid 1000 leaves 500');
select tests.check((select opening_paise = 50000 and closing_paise = 50000
                    from private.period_summary(:farm1, '2026-10-12', '2026-10-18') where worker_id = :w5),
  'scenario H: unpaid 500 carries into the next week once, without double-deducting the advance');
set role authenticated;

select tests.check(tests.op(gen_random_uuid(), :farm1, 'settlement_close', jsonb_build_object(
  'id', gen_random_uuid(), 'week_start', '2026-10-05'))->>'status' = 'applied', 'week closed');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'settlement_close', jsonb_build_object(
  'id', gen_random_uuid(), 'week_start', '2026-10-06'))->>'code' = 'invalid_week', 'weeks must start on the farm week day');
select tests.check((select closing_paise from public.settlement_items si join public.settlements s on s.id = si.settlement_id
                    where s.week_start = '2026-10-05' and si.worker_id = :w5) = 50000, 'settlement snapshot taken');

select tests.act_as(:dad);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', (select d1 from h_att), 'worker_id', :w5, 'work_date', '2026-10-05', 'units_milli', 500, 'rate_paise', 50000), 1)->>'code' = 'week_closed',
  'scenario L: member cannot change a closed week');
select tests.act_as(:owner);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'attendance_upsert', jsonb_build_object(
  'id', (select d1 from h_att), 'worker_id', :w5, 'work_date', '2026-10-05', 'units_milli', 500, 'rate_paise', 50000), 1)->>'status' = 'applied',
  'scenario L: owner corrects attendance in a closed week');
select tests.check((select needs_review from public.settlements where farm_id = :farm1 and week_start = '2026-10-05'),
  'scenario L: settlement flagged for review');
select tests.check((select closing_paise from public.settlement_items si join public.settlements s on s.id = si.settlement_id
                    where s.week_start = '2026-10-05' and si.worker_id = :w5) = 50000, 'scenario L: snapshot not silently rewritten');
select tests.check((select count(*) from public.financial_transactions where worker_id = :w5 and entry_type = 'wage_payment') = 1,
  'scenario L: cash payment record untouched');
select tests.op(gen_random_uuid(), :farm1, 'settlement_close', jsonb_build_object('id', gen_random_uuid(), 'week_start', '2026-10-05'));
select tests.check((select not needs_review from public.settlements where farm_id = :farm1 and week_start = '2026-10-05'),
  'scenario L: review clears the flag');
select tests.check((select closing_paise from public.settlement_items si join public.settlements s on s.id = si.settlement_id
                    where s.week_start = '2026-10-05' and si.worker_id = :w5) = 25000, 'scenario L: reviewed snapshot reflects the correction');

-- Pull --------------------------------------------------------------------
select tests.check((select (r->>'has_more')::boolean = false and jsonb_array_length(r->'changes') > 50
                    from public.pull_changes(:farm1, 0, 1000) r), 'pull returns all farm changes');
select tests.check((select bool_and((c->>'s')::bigint > prev) from (
                      select c, coalesce(lag((c->>'s')::bigint) over (order by ord), 0) as prev
                      from jsonb_array_elements((public.pull_changes(:farm1, 0, 1000))->'changes') with ordinality as x(c, ord)) q),
  'pull is in strictly increasing seq order');
do $$
declare
  v_after bigint := 0;
  v_total integer := 0;
  v_page jsonb;
begin
  loop
    v_page := public.pull_changes('f0000000-0000-4000-8000-000000000001', v_after, 7);
    v_total := v_total + jsonb_array_length(v_page->'changes');
    v_after := (v_page->>'last_seq')::bigint;
    exit when not (v_page->>'has_more')::boolean;
  end loop;
  perform tests.check(v_total = jsonb_array_length((public.pull_changes('f0000000-0000-4000-8000-000000000001', 0, 1000))->'changes'),
                      'paginated pull sees every change exactly once');
end $$;

-- Scenario K: unauthorized access -------------------------------------------
select tests.act_as(:other);
select tests.check((select count(*) from public.financial_transactions where farm_id = :farm1) = 0, 'scenario K: other farm ledger hidden');
select tests.check((select count(*) from public.workers where farm_id = :farm1) = 0, 'scenario K: other farm workers hidden');
select tests.check((select count(*) from public.farm_members where farm_id = :farm1) = 0, 'scenario K: other farm members hidden');
select tests.check((select count(*) from public.audit_events where farm_id = :farm1) = 0, 'scenario K: other farm audit hidden');
select tests.check((select count(*) from public.farms where id = :farm1) = 0, 'scenario K: other farm row hidden');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'advance', 'worker_id', :w1, 'amount_paise', 100, 'business_date', '2026-10-17'))->>'code' = 'not_a_member',
  'scenario K: writes to another farm rejected');
do $$ begin
  perform public.pull_changes('f0000000-0000-4000-8000-000000000001', 0, 10);
  raise exception 'FAILED: pull from another farm should fail';
exception when insufficient_privilege then
  raise notice 'ok - scenario K: pull from another farm denied';
end $$;
do $$ begin
  insert into public.financial_transactions (id, farm_id, entry_type, worker_id, amount_paise, business_date,
    occurred_at, method, recorded_by, recorded_by_name)
  values (gen_random_uuid(), 'f0000000-0000-4000-8000-000000000002', 'advance', 'b0000000-0000-4000-8000-000000000001',
          100, current_date, now(), 'cash', 'a0000000-0000-4000-8000-000000000003', 'x');
  raise exception 'FAILED: direct insert should be denied';
exception when insufficient_privilege then
  raise notice 'ok - scenario K: direct ledger insert denied';
end $$;
do $$ begin
  update public.workers set default_wage_paise = 1;
  raise exception 'FAILED: direct update should be denied';
exception when insufficient_privilege then
  raise notice 'ok - scenario K: direct worker update denied';
end $$;
do $$ begin
  perform 1 from public.sync_operations;
  raise exception 'FAILED: sync_operations should be unreadable';
exception when insufficient_privilege then
  raise notice 'ok - scenario K: sync_operations not readable';
end $$;
do $$ begin
  perform private.leader_pool('f0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-00000000000a');
  raise exception 'FAILED: private helpers should not be callable';
exception when insufficient_privilege then
  raise notice 'ok - scenario K: private helpers not callable';
end $$;
-- Replaying someone else's op id must not leak its stored result.
select tests.check(tests.op((select op_id from c_op), :farm1, 'ledger_create', '{}'::jsonb)->>'code' = 'op_id_reused',
  'scenario K: replaying another user''s op id leaks nothing');

reset role;
set role anon;
select set_config('request.jwt.claim.sub', '', false);
do $$ begin
  perform 1 from public.workers;
  raise exception 'FAILED: anon read should be denied';
exception when insufficient_privilege then
  raise notice 'ok - scenario K: anonymous access denied';
end $$;
do $$ begin
  perform public.apply_ops('[]'::jsonb);
  raise exception 'FAILED: anon rpc should be denied';
exception when insufficient_privilege then
  raise notice 'ok - scenario K: anonymous RPC denied';
end $$;
reset role;

-- Ledger immutability even for the table owner.
do $$ begin
  update public.financial_transactions set amount_paise = 1;
  raise exception 'FAILED: ledger update should be blocked';
exception when insufficient_privilege then
  raise notice 'ok - ledger rows are immutable';
end $$;
do $$ begin
  delete from public.financial_transactions;
  raise exception 'FAILED: ledger delete should be blocked';
exception when insufficient_privilege then
  raise notice 'ok - ledger rows cannot be deleted';
end $$;

-- Revoked membership ------------------------------------------------------
set role authenticated;
select tests.act_as(:owner);
select tests.check(tests.op(gen_random_uuid(), :farm1, 'member_update', jsonb_build_object(
  'id', (select id from public.farm_members where farm_id = :farm1 and user_id = :dad), 'status', 'disabled'),
  (select revision from public.farm_members where farm_id = :farm1 and user_id = :dad))->>'status' = 'applied',
  'owner disables a member');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'member_update', jsonb_build_object(
  'id', (select id from public.farm_members where farm_id = :farm1 and user_id = :owner), 'status', 'disabled'),
  (select revision from public.farm_members where farm_id = :farm1 and user_id = :owner))->>'code' = 'cannot_change_owner_or_self',
  'owner cannot disable themselves');
select tests.act_as(:dad);
select tests.check((select count(*) from public.workers where farm_id = :farm1) = 0, 'disabled member sees no data');
select tests.check(tests.op(gen_random_uuid(), :farm1, 'ledger_create', jsonb_build_object(
  'id', gen_random_uuid(), 'entry_type', 'advance', 'worker_id', :w1, 'amount_paise', 100, 'business_date', '2026-10-17'))->>'code' = 'not_a_member',
  'disabled member cannot write');
reset role;

\echo 'ALL DATABASE TESTS PASSED'
rollback;
