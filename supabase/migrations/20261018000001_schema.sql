-- ShramaSiri: core schema
-- All farm-owned rows carry farm_id, a server-managed server_seq (per-farm,
-- strictly increasing, assigned under a per-farm row lock) and, for mutable
-- rows, a server-managed revision used for optimistic concurrency.
-- Money is always bigint paise. Business dates are plain `date` values in the
-- farm's timezone (Asia/Kolkata); absolute instants are timestamptz (UTC).

create schema if not exists private;

-- ---------------------------------------------------------------------------
-- Sync sequencing
-- ---------------------------------------------------------------------------

-- One row per farm. Taking a sequence number locks this row until commit, so
-- per-farm writers are serialized and server_seq values become visible in
-- order. Pulling clients therefore never skip a row that commits late.
create table public.farm_sync_state (
  farm_id uuid primary key,
  last_seq bigint not null default 0,
  updated_at timestamptz not null default now()
);

create or replace function private.next_seq(p_farm uuid)
returns bigint
language sql
security definer
set search_path = ''
as $$
  insert into public.farm_sync_state as s (farm_id, last_seq, updated_at)
  values (p_farm, 1, now())
  on conflict (farm_id) do update
    set last_seq = s.last_seq + 1, updated_at = now()
  returning last_seq;
$$;

-- Assigns server_seq on every insert/update of a synced table.
create or replace function private.tg_stamp_seq()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_table_name = 'farms' then
    new.server_seq := private.next_seq(new.id);
  else
    new.server_seq := private.next_seq(new.farm_id);
  end if;
  return new;
end;
$$;

-- Bumps revision/updated_at on update of mutable rows and protects created_*.
create or replace function private.tg_bump_revision()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.revision := old.revision + 1;
  new.updated_at := now();
  new.created_at := old.created_at;
  new.id := old.id;
  new.farm_id := old.farm_id;
  return new;
end;
$$;

create or replace function private.tg_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create or replace function private.tg_immutable()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception '% rows are immutable; record a reversal instead', tg_table_name
    using errcode = '42501';
end;
$$;

-- ---------------------------------------------------------------------------
-- Farms, profiles, membership
-- ---------------------------------------------------------------------------

create table public.farms (
  id uuid primary key,
  name text not null check (length(btrim(name)) between 1 and 120),
  -- ISO day of week the wage week starts on: 1 = Monday ... 7 = Sunday.
  week_start_day smallint not null default 1 check (week_start_day between 1 and 7),
  timezone text not null default 'Asia/Kolkata',
  created_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  revision integer not null default 1,
  server_seq bigint not null default 0
);

create table public.user_profiles (
  id uuid primary key references auth.users (id),
  full_name text not null check (length(btrim(full_name)) between 1 and 100),
  display_name_kn text check (display_name_kn is null or length(display_name_kn) <= 100),
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- A row exists per invited or joined family member. Names are mirrored here
-- from user_profiles so a farm's devices can show actual names offline.
create table public.farm_members (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  user_id uuid references auth.users (id),
  email text not null check (email = lower(btrim(email)) and position('@' in email) > 1),
  -- 'leader' is reserved for future limited group-leader logins.
  role text not null check (role in ('owner', 'admin', 'member', 'leader')),
  status text not null check (status in ('invited', 'active', 'disabled')),
  full_name text not null check (length(btrim(full_name)) between 1 and 100),
  display_name_kn text check (display_name_kn is null or length(display_name_kn) <= 100),
  linked_worker_id uuid,
  invited_by uuid references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  revision integer not null default 1,
  server_seq bigint not null default 0,
  check (status = 'invited' or user_id is not null)
);
create unique index farm_members_farm_user_uq on public.farm_members (farm_id, user_id) where user_id is not null;
create unique index farm_members_farm_email_uq on public.farm_members (farm_id, email);
create index farm_members_user_idx on public.farm_members (user_id, status);
create index farm_members_seq_idx on public.farm_members (farm_id, server_seq);

-- ---------------------------------------------------------------------------
-- Workers and groups
-- ---------------------------------------------------------------------------

create table public.workers (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  name_kn text not null check (length(btrim(name_kn)) between 1 and 100),
  name_en text check (name_en is null or length(name_en) <= 100),
  phone text check (phone is null or phone ~ '^[0-9+ -]{5,20}$'),
  default_wage_paise bigint not null check (default_wage_paise between 0 and 10000000),
  notes text check (notes is null or length(notes) <= 500),
  is_leader boolean not null default false,
  status text not null default 'active' check (status in ('active', 'archived')),
  created_by uuid not null references auth.users (id),
  updated_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  revision integer not null default 1,
  server_seq bigint not null default 0,
  unique (farm_id, id)
);
create index workers_seq_idx on public.workers (farm_id, server_seq);

alter table public.farm_members
  add constraint farm_members_linked_worker_fk
  foreign key (farm_id, linked_worker_id) references public.workers (farm_id, id);

create table public.worker_groups (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  name text not null check (length(btrim(name)) between 1 and 100),
  leader_worker_id uuid,
  status text not null default 'active' check (status in ('active', 'archived')),
  created_by uuid not null references auth.users (id),
  updated_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  revision integer not null default 1,
  server_seq bigint not null default 0,
  unique (farm_id, id),
  foreign key (farm_id, leader_worker_id) references public.workers (farm_id, id)
);
create index worker_groups_seq_idx on public.worker_groups (farm_id, server_seq);

-- Membership rows are never deleted; `active` toggles so removals sync.
create table public.worker_group_memberships (
  farm_id uuid not null,
  group_id uuid not null,
  worker_id uuid not null,
  active boolean not null default true,
  updated_by uuid not null references auth.users (id),
  updated_at timestamptz not null default now(),
  server_seq bigint not null default 0,
  primary key (group_id, worker_id),
  foreign key (farm_id, group_id) references public.worker_groups (farm_id, id),
  foreign key (farm_id, worker_id) references public.workers (farm_id, id)
);
create index wgm_seq_idx on public.worker_group_memberships (farm_id, server_seq);
create index wgm_worker_idx on public.worker_group_memberships (worker_id);

-- ---------------------------------------------------------------------------
-- Attendance
-- ---------------------------------------------------------------------------

-- One base attendance row per farm/worker/date. units_milli: 1000 = full day,
-- 500 = half day, 0 = cleared/absent. rate_paise is the snapshot of the daily
-- rate applied, so later default-wage changes never alter history.
create table public.attendance (
  id uuid primary key,
  farm_id uuid not null,
  worker_id uuid not null,
  work_date date not null,
  units_milli integer not null check (units_milli between 0 and 3000),
  rate_paise bigint not null check (rate_paise between 0 and 10000000),
  earned_paise bigint generated always as ((rate_paise * units_milli + 500) / 1000) stored,
  notes text check (notes is null or length(notes) <= 300),
  recorded_by uuid not null references auth.users (id),
  updated_by uuid not null references auth.users (id),
  source_device_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  revision integer not null default 1,
  server_seq bigint not null default 0,
  unique (farm_id, worker_id, work_date),
  foreign key (farm_id, worker_id) references public.workers (farm_id, id)
);
create index attendance_seq_idx on public.attendance (farm_id, server_seq);
create index attendance_date_idx on public.attendance (farm_id, work_date);

-- ---------------------------------------------------------------------------
-- Work diary
-- ---------------------------------------------------------------------------

create table public.work_types (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  code text not null check (code ~ '^[a-z0-9_]{1,40}$'),
  name_kn text not null check (length(btrim(name_kn)) between 1 and 80),
  name_en text not null check (length(btrim(name_en)) between 1 and 80),
  active boolean not null default true,
  sort_order integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  revision integer not null default 1,
  server_seq bigint not null default 0,
  unique (farm_id, id),
  unique (farm_id, code)
);
create index work_types_seq_idx on public.work_types (farm_id, server_seq);

create table public.work_assignments (
  id uuid primary key,
  farm_id uuid not null,
  work_date date not null,
  work_type_id uuid not null,
  field_name text check (field_name is null or length(field_name) <= 100),
  description text check (description is null or length(description) <= 500),
  status text not null check (status in ('planned', 'in_progress', 'completed', 'cancelled')),
  notes text check (notes is null or length(notes) <= 500),
  assigned_by uuid not null references auth.users (id),
  updated_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  revision integer not null default 1,
  server_seq bigint not null default 0,
  unique (farm_id, id),
  foreign key (farm_id, work_type_id) references public.work_types (farm_id, id)
);
create index work_assignments_seq_idx on public.work_assignments (farm_id, server_seq);
create index work_assignments_date_idx on public.work_assignments (farm_id, work_date);

create table public.work_assignment_workers (
  farm_id uuid not null,
  assignment_id uuid not null,
  worker_id uuid not null,
  removed boolean not null default false,
  updated_at timestamptz not null default now(),
  server_seq bigint not null default 0,
  primary key (assignment_id, worker_id),
  foreign key (farm_id, assignment_id) references public.work_assignments (farm_id, id),
  foreign key (farm_id, worker_id) references public.workers (farm_id, id)
);
create index waw_seq_idx on public.work_assignment_workers (farm_id, server_seq);
create index waw_worker_idx on public.work_assignment_workers (worker_id);

-- ---------------------------------------------------------------------------
-- Financial ledger (single, append-only)
-- ---------------------------------------------------------------------------

-- Every money event is one immutable row. Effects per entry_type:
--   advance            worker wage paid +amt          farm cash out +amt
--   wage_payment       worker wage paid +amt          farm cash out +amt
--   bonus              worker earned +amt, paid +amt  farm cash out +amt
--   addition           worker earned +amt             (no cash)
--   deduction          worker earned -amt             (no cash)
--   opening_balance    worker earned +signed amt      (no cash)
--   loan               worker loan +amt               farm cash out +amt
--   loan_repayment     worker loan -amt               farm cash out -amt (cash in)
--   loan_offset        worker loan -amt, paid +amt    (no cash; wages applied to loan)
--   reimbursement      not a wage expense             farm cash out +amt
--                      (with related_entry_id -> leader_self_funded: leader payable -amt)
--   leader_transfer    leader pool +amt               farm cash out +amt
--   leader_allocation  recipient wage paid +amt, pool(leader) -amt   (no cash)
--   leader_return      leader pool -amt               farm cash out -amt (cash in)
--   leader_self_funded recipient wage paid +amt, leader payable +amt (no cash)
-- A reversal row (is_reversal) copies the original's type and amount and
-- applies the same effects negated. Originals are never modified.
create table public.financial_transactions (
  id uuid primary key,
  farm_id uuid not null,
  entry_type text not null check (entry_type in (
    'advance', 'wage_payment', 'bonus', 'addition', 'deduction', 'opening_balance',
    'loan', 'loan_repayment', 'loan_offset', 'reimbursement',
    'leader_transfer', 'leader_allocation', 'leader_return', 'leader_self_funded')),
  worker_id uuid not null,
  leader_worker_id uuid,
  amount_paise bigint not null,
  is_reversal boolean not null default false,
  reverses_id uuid references public.financial_transactions (id),
  related_entry_id uuid references public.financial_transactions (id),
  business_date date not null,
  occurred_at timestamptz not null,
  method text not null check (method in ('cash', 'upi', 'bank', 'other', 'none')),
  reference text check (reference is null or length(reference) <= 100),
  notes text check (notes is null or length(notes) <= 500),
  paid_by uuid references auth.users (id),
  paid_by_name text,
  recorded_by uuid not null references auth.users (id),
  recorded_by_name text not null,
  source_device_id text,
  op_id uuid,
  created_at timestamptz not null default now(),
  server_seq bigint not null default 0,
  foreign key (farm_id, worker_id) references public.workers (farm_id, id),
  foreign key (farm_id, leader_worker_id) references public.workers (farm_id, id),
  check (is_reversal = (reverses_id is not null)),
  check (
    (entry_type = 'opening_balance' and amount_paise <> 0 and abs(amount_paise) <= 100000000000)
    or (entry_type <> 'opening_balance' and amount_paise > 0 and amount_paise <= 100000000000)
  ),
  check ((entry_type in ('leader_allocation', 'leader_self_funded')) = (leader_worker_id is not null))
);
-- An entry can be reversed at most once.
create unique index ft_single_reversal_uq on public.financial_transactions (reverses_id) where reverses_id is not null;
create index ft_seq_idx on public.financial_transactions (farm_id, server_seq);
create index ft_worker_date_idx on public.financial_transactions (farm_id, worker_id, business_date);
create index ft_leader_idx on public.financial_transactions (farm_id, leader_worker_id) where leader_worker_id is not null;
create index ft_date_idx on public.financial_transactions (farm_id, business_date);

-- ---------------------------------------------------------------------------
-- Weekly settlements
-- ---------------------------------------------------------------------------

-- Balances are always derived from the ledger. A settlement row records that
-- a week was reviewed/closed, plus a per-worker snapshot (settlement_items)
-- taken at close time so later backdated changes can be detected and shown.
create table public.settlements (
  id uuid primary key,
  farm_id uuid not null references public.farms (id),
  week_start date not null,
  week_end date not null,
  status text not null check (status in ('open', 'closed')),
  needs_review boolean not null default false,
  closed_by uuid references auth.users (id),
  closed_by_name text,
  closed_at timestamptz,
  notes text check (notes is null or length(notes) <= 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  revision integer not null default 1,
  server_seq bigint not null default 0,
  unique (farm_id, id),
  unique (farm_id, week_start),
  check (week_end = week_start + 6)
);
create index settlements_seq_idx on public.settlements (farm_id, server_seq);

create table public.settlement_items (
  farm_id uuid not null,
  settlement_id uuid not null,
  worker_id uuid not null,
  units_milli bigint not null default 0,
  opening_paise bigint not null default 0,
  gross_paise bigint not null default 0,
  additions_paise bigint not null default 0,
  advances_paise bigint not null default 0,
  direct_paid_paise bigint not null default 0,
  leader_paid_paise bigint not null default 0,
  closing_paise bigint not null default 0,
  updated_at timestamptz not null default now(),
  server_seq bigint not null default 0,
  primary key (settlement_id, worker_id),
  foreign key (farm_id, settlement_id) references public.settlements (farm_id, id),
  foreign key (farm_id, worker_id) references public.workers (farm_id, id)
);
create index settlement_items_seq_idx on public.settlement_items (farm_id, server_seq);

-- ---------------------------------------------------------------------------
-- Audit and sync bookkeeping
-- ---------------------------------------------------------------------------

create table public.audit_events (
  id uuid primary key default gen_random_uuid(),
  farm_id uuid not null references public.farms (id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  actor_id uuid not null,
  actor_name text,
  before_data jsonb,
  after_data jsonb,
  source_device_id text,
  op_id uuid,
  created_at timestamptz not null default now(),
  server_seq bigint not null default 0
);
create index audit_seq_idx on public.audit_events (farm_id, server_seq);
create index audit_entity_idx on public.audit_events (farm_id, entity_id);

-- Idempotency record: one row per client operation id. Replays return the
-- stored result instead of re-applying.
create table public.sync_operations (
  op_id uuid primary key,
  farm_id uuid not null,
  actor_id uuid not null,
  device_id text,
  op_type text not null,
  entity_id uuid,
  status text not null check (status in ('applied', 'conflict', 'rejected')),
  result jsonb not null,
  received_at timestamptz not null default now()
);
create index sync_operations_farm_idx on public.sync_operations (farm_id, received_at);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

do $$
declare
  t text;
begin
  foreach t in array array[
    'farms', 'farm_members', 'workers', 'worker_groups', 'worker_group_memberships',
    'attendance', 'work_types', 'work_assignments', 'work_assignment_workers',
    'financial_transactions', 'settlements', 'settlement_items', 'audit_events'
  ] loop
    execute format(
      'create trigger stamp_seq before insert or update on public.%I
         for each row execute function private.tg_stamp_seq()', t);
  end loop;

  foreach t in array array[
    'farms', 'farm_members', 'workers', 'worker_groups', 'attendance',
    'work_types', 'work_assignments', 'settlements'
  ] loop
    execute format(
      'create trigger bump_revision before update on public.%I
         for each row execute function private.tg_bump_revision()', t);
  end loop;

  foreach t in array array[
    'worker_group_memberships', 'work_assignment_workers', 'settlement_items', 'user_profiles'
  ] loop
    execute format(
      'create trigger touch before update on public.%I
         for each row execute function private.tg_touch()', t);
  end loop;

  foreach t in array array['financial_transactions', 'audit_events'] loop
    execute format(
      'create trigger immutable before update or delete on public.%I
         for each row execute function private.tg_immutable()', t);
  end loop;
end;
$$;
