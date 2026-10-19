-- ShramaSiri: server logic
-- Clients never write tables directly. Every change arrives as an operation
-- through public.apply_ops, which is idempotent per op_id, derives the actor
-- from auth.uid(), checks membership/role, validates, writes, audits and
-- returns the authoritative rows. Expected rejections/conflicts are raised as
-- custom SQLSTATEs (SR001 / SC001) so the per-op savepoint rolls back cleanly.

create type private.op_ctx as (
  farm_id uuid,
  actor_id uuid,
  actor_name text,
  role text,
  device_id text,
  op_id uuid,
  base_revision integer
);

-- ---------------------------------------------------------------------------
-- Small helpers
-- ---------------------------------------------------------------------------

create or replace function private.reject(p_code text, p_data jsonb default '{}'::jsonb)
returns void language plpgsql set search_path = '' as $$
begin
  raise exception using errcode = 'SR001', message = p_code, detail = coalesce(p_data, '{}'::jsonb)::text;
end;
$$;

create or replace function private.conflict(p_code text, p_data jsonb default '{}'::jsonb)
returns void language plpgsql set search_path = '' as $$
begin
  raise exception using errcode = 'SC001', message = p_code, detail = coalesce(p_data, '{}'::jsonb)::text;
end;
$$;

create or replace function private.try_uuid(p_value text)
returns uuid language plpgsql immutable set search_path = '' as $$
begin
  return p_value::uuid;
exception when invalid_text_representation then
  return null;
end;
$$;

create or replace function private.rows(p_table text, p_row jsonb)
returns jsonb language sql immutable set search_path = '' as $$
  select case when p_row is null then '[]'::jsonb
              else jsonb_build_array(jsonb_build_object('t', p_table, 'd', p_row)) end;
$$;

-- Trimmed text, null when blank, rejected when longer than p_max.
create or replace function private.opt_text(p_value text, p_max integer)
returns text language plpgsql immutable set search_path = '' as $$
declare
  v text := nullif(btrim(coalesce(p_value, '')), '');
begin
  if v is not null and length(v) > p_max then
    perform private.reject('text_too_long', jsonb_build_object('max', p_max));
  end if;
  return v;
end;
$$;

create or replace function private.req_text(p_value text, p_max integer, p_code text)
returns text language plpgsql immutable set search_path = '' as $$
declare
  v text := private.opt_text(p_value, p_max);
begin
  if v is null then
    perform private.reject(p_code);
  end if;
  return v;
end;
$$;

create or replace function private.farm_today(p_farm uuid)
returns date language sql stable set search_path = '' as $$
  select (now() at time zone coalesce((select timezone from public.farms where id = p_farm), 'Asia/Kolkata'))::date;
$$;

create or replace function private.check_business_date(p_farm uuid, p_date date)
returns void language plpgsql stable set search_path = '' as $$
begin
  if p_date is null or p_date < date '2000-01-01' or p_date > private.farm_today(p_farm) + 1 then
    perform private.reject('invalid_date');
  end if;
end;
$$;

-- Farms the current user may read: active owner/admin/member memberships.
-- ('leader' logins are reserved for a future limited view.)
create or replace function private.my_farm_ids()
returns setof uuid language sql stable security definer set search_path = '' as $$
  select farm_id from public.farm_members
  where user_id = auth.uid() and status = 'active' and role in ('owner', 'admin', 'member');
$$;

create or replace function private.week_closed(p_farm uuid, p_date date)
returns boolean language sql stable set search_path = '' as $$
  select exists (
    select 1 from public.settlements
    where farm_id = p_farm and status = 'closed' and p_date between week_start and week_end);
$$;

-- Members may not change closed weeks; owners/admins may, and the affected
-- settlement is flagged for review.
create or replace function private.guard_period(c private.op_ctx, p_date date)
returns void language plpgsql set search_path = '' as $$
begin
  if private.week_closed(c.farm_id, p_date) then
    if c.role not in ('owner', 'admin') then
      perform private.reject('week_closed', jsonb_build_object('date', p_date));
    end if;
    update public.settlements
      set needs_review = true
      where farm_id = c.farm_id and status = 'closed' and not needs_review
        and p_date between week_start and week_end;
  end if;
end;
$$;

create or replace function private.require_admin(c private.op_ctx)
returns void language plpgsql set search_path = '' as $$
begin
  if c.role not in ('owner', 'admin') then
    perform private.reject('forbidden');
  end if;
end;
$$;

create or replace function private.audit(
  c private.op_ctx, p_action text, p_entity text, p_entity_id uuid, p_before jsonb, p_after jsonb)
returns void language sql set search_path = '' as $$
  insert into public.audit_events (farm_id, action, entity_type, entity_id, actor_id, actor_name,
                                   before_data, after_data, source_device_id, op_id)
  values (c.farm_id, p_action, p_entity, p_entity_id, c.actor_id, c.actor_name,
          p_before - 'server_seq', p_after - 'server_seq', c.device_id, c.op_id);
$$;

-- ---------------------------------------------------------------------------
-- Ledger arithmetic (mirrors lib/domain/ledger.dart)
-- ---------------------------------------------------------------------------

create or replace function private.sgn(p_reversal boolean)
returns integer language sql immutable set search_path = '' as $$
  select case when p_reversal then -1 else 1 end;
$$;

-- Money currently held by a leader for distribution.
create or replace function private.leader_pool(p_farm uuid, p_leader uuid)
returns bigint language sql stable set search_path = '' as $$
  select coalesce(sum(private.sgn(is_reversal) * case entry_type
           when 'leader_transfer' then amount_paise
           else -amount_paise end), 0)::bigint
  from public.financial_transactions
  where farm_id = p_farm
    and ((entry_type in ('leader_transfer', 'leader_return') and worker_id = p_leader)
         or (entry_type = 'leader_allocation' and leader_worker_id = p_leader));
$$;

-- Personal loan the worker still owes the farm.
create or replace function private.loan_balance(p_farm uuid, p_worker uuid)
returns bigint language sql stable set search_path = '' as $$
  select coalesce(sum(private.sgn(is_reversal) * case entry_type
           when 'loan' then amount_paise
           else -amount_paise end), 0)::bigint
  from public.financial_transactions
  where farm_id = p_farm and worker_id = p_worker
    and entry_type in ('loan', 'loan_repayment', 'loan_offset');
$$;

-- What the farm owes a leader for wages they paid from their own pocket.
create or replace function private.leader_payable(p_farm uuid, p_leader uuid)
returns bigint language sql stable set search_path = '' as $$
  select coalesce(sum(private.sgn(is_reversal) * case entry_type
           when 'leader_self_funded' then amount_paise
           else -amount_paise end), 0)::bigint
  from public.financial_transactions
  where farm_id = p_farm
    and ((entry_type = 'leader_self_funded' and leader_worker_id = p_leader)
         or (entry_type = 'reimbursement' and worker_id = p_leader and related_entry_id is not null));
$$;

-- Per-worker wage summary for [p_start, p_end]; opening is everything before
-- p_start. closing = opening + gross + additions - advances - direct - leader.
create or replace function private.period_summary(p_farm uuid, p_start date, p_end date)
returns table (
  worker_id uuid, units_milli bigint, opening_paise bigint, gross_paise bigint,
  additions_paise bigint, advances_paise bigint, direct_paid_paise bigint,
  leader_paid_paise bigint, closing_paise bigint)
language sql stable set search_path = '' as $$
  with att as (
    select a.worker_id,
           sum(case when a.work_date < p_start then a.earned_paise else 0 end) as before_earned,
           sum(case when a.work_date between p_start and p_end then a.units_milli else 0 end) as units,
           sum(case when a.work_date between p_start and p_end then a.earned_paise else 0 end) as gross
    from public.attendance a
    where a.farm_id = p_farm and a.work_date <= p_end
    group by a.worker_id
  ),
  led as (
    select f.worker_id,
           f.business_date < p_start as before,
           private.sgn(f.is_reversal) * case f.entry_type
             when 'bonus' then f.amount_paise
             when 'addition' then f.amount_paise
             when 'deduction' then -f.amount_paise
             when 'opening_balance' then f.amount_paise
             else 0 end as earned_delta,
           private.sgn(f.is_reversal) * case when f.entry_type = 'advance' then f.amount_paise else 0 end as adv,
           private.sgn(f.is_reversal) * case when f.entry_type in ('wage_payment', 'bonus', 'loan_offset')
             then f.amount_paise else 0 end as direct,
           private.sgn(f.is_reversal) * case when f.entry_type in ('leader_allocation', 'leader_self_funded')
             then f.amount_paise else 0 end as via_leader
    from public.financial_transactions f
    where f.farm_id = p_farm and f.business_date <= p_end
      and f.entry_type in ('bonus', 'addition', 'deduction', 'opening_balance', 'advance',
                           'wage_payment', 'loan_offset', 'leader_allocation', 'leader_self_funded')
  ),
  led_sum as (
    select l.worker_id,
           sum(case when l.before then l.earned_delta - l.adv - l.direct - l.via_leader else 0 end) as before_net,
           sum(case when not l.before then l.earned_delta else 0 end) as additions,
           sum(case when not l.before then l.adv else 0 end) as advances,
           sum(case when not l.before then l.direct else 0 end) as direct,
           sum(case when not l.before then l.via_leader else 0 end) as via_leader
    from led l
    group by l.worker_id
  ),
  j as (
    select coalesce(att.worker_id, led_sum.worker_id) as worker_id,
           coalesce(att.units, 0)::bigint as units,
           (coalesce(att.before_earned, 0) + coalesce(led_sum.before_net, 0))::bigint as opening,
           coalesce(att.gross, 0)::bigint as gross,
           coalesce(led_sum.additions, 0)::bigint as additions,
           coalesce(led_sum.advances, 0)::bigint as advances,
           coalesce(led_sum.direct, 0)::bigint as direct,
           coalesce(led_sum.via_leader, 0)::bigint as via_leader
    from att full join led_sum on led_sum.worker_id = att.worker_id
  )
  select worker_id, units, opening, gross, additions, advances, direct, via_leader,
         opening + gross + additions - advances - direct - via_leader
  from j
  where units <> 0 or opening <> 0 or gross <> 0 or additions <> 0
     or advances <> 0 or direct <> 0 or via_leader <> 0;
$$;

-- ---------------------------------------------------------------------------
-- Operation handlers. Each returns a jsonb array of {t, d} rows.
-- ---------------------------------------------------------------------------

create or replace function private.op_farm_update(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_old public.farms;
  v_new public.farms;
begin
  perform private.require_admin(c);
  select * into v_old from public.farms where id = c.farm_id for update;
  if v_old.revision <> c.base_revision then
    perform private.conflict('stale_revision', jsonb_build_object('rows', private.rows('farms', to_jsonb(v_old))));
  end if;
  update public.farms set
    name = private.req_text(p->>'name', 120, 'invalid_name'),
    week_start_day = coalesce((p->>'week_start_day')::smallint, v_old.week_start_day)
  where id = c.farm_id
  returning * into v_new;
  perform private.audit(c, 'farm.updated', 'farm', c.farm_id, to_jsonb(v_old), to_jsonb(v_new));
  return private.rows('farms', to_jsonb(v_new));
end;
$$;

create or replace function private.op_profile_update(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_name text := private.req_text(p->>'full_name', 100, 'invalid_name');
  v_kn text := private.opt_text(p->>'display_name_kn', 100);
  v_before jsonb;
  v_row public.farm_members;
begin
  select to_jsonb(m) into v_before from public.farm_members m
    where m.farm_id = c.farm_id and m.user_id = c.actor_id;
  update public.user_profiles set full_name = v_name, display_name_kn = v_kn where id = c.actor_id;
  update public.farm_members set full_name = v_name, display_name_kn = v_kn
    where user_id = c.actor_id and (full_name is distinct from v_name or display_name_kn is distinct from v_kn);
  select * into v_row from public.farm_members where farm_id = c.farm_id and user_id = c.actor_id;
  perform private.audit(c, 'profile.updated', 'member', v_row.id, v_before, to_jsonb(v_row));
  return private.rows('farm_members', to_jsonb(v_row));
end;
$$;

create or replace function private.op_member_invite(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_email text := lower(private.req_text(p->>'email', 200, 'invalid_email'));
  v_role text := coalesce(p->>'role', 'member');
  v_existing public.farm_members;
  v_new public.farm_members;
begin
  perform private.require_admin(c);
  if v_role not in ('admin', 'member') then
    perform private.reject('invalid_role');
  end if;
  if v_role = 'admin' and c.role <> 'owner' then
    perform private.reject('forbidden');
  end if;
  if position('@' in v_email) < 2 then
    perform private.reject('invalid_email');
  end if;
  select * into v_existing from public.farm_members where farm_id = c.farm_id and email = v_email;
  if found then
    perform private.conflict('already_invited', jsonb_build_object('rows', private.rows('farm_members', to_jsonb(v_existing))));
  end if;
  insert into public.farm_members (id, farm_id, email, role, status, full_name, invited_by)
  values ((p->>'id')::uuid, c.farm_id, v_email, v_role, 'invited',
          private.req_text(p->>'full_name', 100, 'invalid_name'), c.actor_id)
  returning * into v_new;
  perform private.audit(c, 'member.invited', 'member', v_new.id, null, to_jsonb(v_new));
  return private.rows('farm_members', to_jsonb(v_new));
end;
$$;

create or replace function private.op_member_update(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_old public.farm_members;
  v_new public.farm_members;
  v_role text;
  v_status text;
begin
  perform private.require_admin(c);
  select * into v_old from public.farm_members where id = (p->>'id')::uuid and farm_id = c.farm_id for update;
  if not found then
    perform private.reject('not_found');
  end if;
  if v_old.revision <> c.base_revision then
    perform private.conflict('stale_revision', jsonb_build_object('rows', private.rows('farm_members', to_jsonb(v_old))));
  end if;
  v_role := coalesce(p->>'role', v_old.role);
  v_status := coalesce(p->>'status', v_old.status);
  if v_old.user_id = c.actor_id or v_old.role = 'owner' then
    perform private.reject('cannot_change_owner_or_self');
  end if;
  if v_role not in ('admin', 'member') or v_status not in ('invited', 'active', 'disabled') then
    perform private.reject('invalid_role');
  end if;
  if (v_role = 'admin' or v_old.role = 'admin') and c.role <> 'owner' then
    perform private.reject('forbidden');
  end if;
  if v_status = 'active' and v_old.user_id is null then
    v_status := 'invited';
  end if;
  update public.farm_members set role = v_role, status = v_status where id = v_old.id returning * into v_new;
  perform private.audit(c, 'member.updated', 'member', v_new.id, to_jsonb(v_old), to_jsonb(v_new));
  return private.rows('farm_members', to_jsonb(v_new));
end;
$$;

create or replace function private.op_worker_upsert(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_id uuid := (p->>'id')::uuid;
  v_old public.workers;
  v_new public.workers;
  v_exists boolean;
  v_status text := coalesce(p->>'status', 'active');
  v_name text := private.req_text(p->>'name_kn', 100, 'invalid_name');
  v_wage bigint := (p->>'default_wage_paise')::bigint;
begin
  if v_wage is null or v_wage < 0 or v_wage > 10000000 then
    perform private.reject('invalid_amount');
  end if;
  if v_status not in ('active', 'archived') then
    perform private.reject('invalid_status');
  end if;
  select * into v_old from public.workers where id = v_id for update;
  v_exists := found;
  if v_exists and v_old.farm_id <> c.farm_id then
    perform private.reject('not_found');
  end if;

  if c.base_revision = 0 then
    if v_exists then
      perform private.conflict('already_exists', jsonb_build_object('rows', private.rows('workers', to_jsonb(v_old))));
    end if;
    insert into public.workers (id, farm_id, name_kn, name_en, phone, default_wage_paise, notes,
                                is_leader, status, created_by, updated_by)
    values (v_id, c.farm_id, v_name, private.opt_text(p->>'name_en', 100), private.opt_text(p->>'phone', 20),
            v_wage, private.opt_text(p->>'notes', 500), coalesce((p->>'is_leader')::boolean, false),
            v_status, c.actor_id, c.actor_id)
    returning * into v_new;
    perform private.audit(c, 'worker.created', 'worker', v_id, null, to_jsonb(v_new));
  else
    if not v_exists then
      perform private.reject('not_found');
    end if;
    if v_old.revision <> c.base_revision then
      perform private.conflict('stale_revision', jsonb_build_object('rows', private.rows('workers', to_jsonb(v_old))));
    end if;
    if v_status <> v_old.status and c.role not in ('owner', 'admin') then
      perform private.reject('forbidden');
    end if;
    update public.workers set
      name_kn = v_name,
      name_en = private.opt_text(p->>'name_en', 100),
      phone = private.opt_text(p->>'phone', 20),
      default_wage_paise = v_wage,
      notes = private.opt_text(p->>'notes', 500),
      is_leader = coalesce((p->>'is_leader')::boolean, v_old.is_leader),
      status = v_status,
      updated_by = c.actor_id
    where id = v_id
    returning * into v_new;
    perform private.audit(c,
      case when v_new.status <> v_old.status then 'worker.' || v_new.status else 'worker.updated' end,
      'worker', v_id, to_jsonb(v_old), to_jsonb(v_new));
  end if;
  return private.rows('workers', to_jsonb(v_new));
end;
$$;

create or replace function private.op_group_upsert(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_id uuid := (p->>'id')::uuid;
  v_old public.worker_groups;
  v_new public.worker_groups;
  v_exists boolean;
  v_members uuid[] := coalesce(
    (select array_agg(distinct x::uuid) from jsonb_array_elements_text(coalesce(p->'member_ids', '[]'::jsonb)) x),
    '{}'::uuid[]);
  v_rows jsonb;
begin
  select * into v_old from public.worker_groups where id = v_id for update;
  v_exists := found;
  if v_exists and v_old.farm_id <> c.farm_id then
    perform private.reject('not_found');
  end if;
  if c.base_revision = 0 then
    if v_exists then
      perform private.conflict('already_exists', jsonb_build_object('rows', private.rows('worker_groups', to_jsonb(v_old))));
    end if;
    insert into public.worker_groups (id, farm_id, name, leader_worker_id, status, created_by, updated_by)
    values (v_id, c.farm_id, private.req_text(p->>'name', 100, 'invalid_name'),
            (p->>'leader_worker_id')::uuid, coalesce(p->>'status', 'active'), c.actor_id, c.actor_id)
    returning * into v_new;
  else
    if not v_exists then
      perform private.reject('not_found');
    end if;
    if v_old.revision <> c.base_revision then
      perform private.conflict('stale_revision', jsonb_build_object('rows', private.rows('worker_groups', to_jsonb(v_old))));
    end if;
    update public.worker_groups set
      name = private.req_text(p->>'name', 100, 'invalid_name'),
      leader_worker_id = (p->>'leader_worker_id')::uuid,
      status = coalesce(p->>'status', v_old.status),
      updated_by = c.actor_id
    where id = v_id
    returning * into v_new;
  end if;

  insert into public.worker_group_memberships (farm_id, group_id, worker_id, active, updated_by)
  select c.farm_id, v_id, m, true, c.actor_id from unnest(v_members) m
  on conflict (group_id, worker_id) do update
    set active = true, updated_by = excluded.updated_by
    where public.worker_group_memberships.active = false;
  update public.worker_group_memberships
    set active = false, updated_by = c.actor_id
    where group_id = v_id and active and not (worker_id = any (v_members));

  perform private.audit(c, case when v_exists then 'group.updated' else 'group.created' end,
    'group', v_id, to_jsonb(v_old), to_jsonb(v_new) || jsonb_build_object('member_ids', to_jsonb(v_members)));

  select coalesce(jsonb_agg(jsonb_build_object('t', 'worker_group_memberships', 'd', to_jsonb(m))), '[]'::jsonb)
    into v_rows from public.worker_group_memberships m where m.group_id = v_id;
  return private.rows('worker_groups', to_jsonb(v_new)) || v_rows;
end;
$$;

create or replace function private.op_attendance_upsert(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_id uuid := (p->>'id')::uuid;
  v_worker uuid := (p->>'worker_id')::uuid;
  v_date date := (p->>'work_date')::date;
  v_units integer := (p->>'units_milli')::integer;
  v_rate bigint := (p->>'rate_paise')::bigint;
  v_old public.attendance;
  v_new public.attendance;
begin
  perform private.check_business_date(c.farm_id, v_date);
  if v_units is null or v_units < 0 or v_units > 3000 then
    perform private.reject('invalid_units');
  end if;
  if v_rate is null or v_rate < 0 or v_rate > 10000000 then
    perform private.reject('invalid_amount');
  end if;

  if c.base_revision = 0 then
    select * into v_old from public.attendance
      where farm_id = c.farm_id and worker_id = v_worker and work_date = v_date for update;
    if found then
      -- Someone else already marked this worker for this date. Never sum or
      -- overwrite: hand both versions back for the user to resolve.
      perform private.conflict('attendance_exists', jsonb_build_object('rows', private.rows('attendance', to_jsonb(v_old))));
    end if;
    perform private.guard_period(c, v_date);
    insert into public.attendance (id, farm_id, worker_id, work_date, units_milli, rate_paise, notes,
                                   recorded_by, updated_by, source_device_id)
    values (v_id, c.farm_id, v_worker, v_date, v_units, v_rate, private.opt_text(p->>'notes', 300),
            c.actor_id, c.actor_id, c.device_id)
    returning * into v_new;
    perform private.audit(c, 'attendance.marked', 'attendance', v_id, null, to_jsonb(v_new));
  else
    select * into v_old from public.attendance where id = v_id and farm_id = c.farm_id for update;
    if not found then
      perform private.reject('not_found');
    end if;
    if v_old.worker_id <> v_worker or v_old.work_date <> v_date then
      perform private.reject('immutable_key');
    end if;
    if v_old.revision <> c.base_revision then
      perform private.conflict('stale_revision', jsonb_build_object('rows', private.rows('attendance', to_jsonb(v_old))));
    end if;
    perform private.guard_period(c, v_date);
    update public.attendance set
      units_milli = v_units,
      rate_paise = v_rate,
      notes = private.opt_text(p->>'notes', 300),
      updated_by = c.actor_id,
      source_device_id = c.device_id
    where id = v_id
    returning * into v_new;
    perform private.audit(c, 'attendance.corrected', 'attendance', v_id, to_jsonb(v_old), to_jsonb(v_new));
  end if;
  return private.rows('attendance', to_jsonb(v_new));
end;
$$;

create or replace function private.op_work_type_upsert(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_id uuid := (p->>'id')::uuid;
  v_old public.work_types;
  v_new public.work_types;
  v_exists boolean;
begin
  select * into v_old from public.work_types where id = v_id for update;
  v_exists := found;
  if v_exists and v_old.farm_id <> c.farm_id then
    perform private.reject('not_found');
  end if;
  if c.base_revision = 0 then
    if v_exists then
      perform private.conflict('already_exists', jsonb_build_object('rows', private.rows('work_types', to_jsonb(v_old))));
    end if;
    insert into public.work_types (id, farm_id, code, name_kn, name_en, active, sort_order)
    values (v_id, c.farm_id, coalesce(p->>'code', 'custom_' || replace(left(v_id::text, 8), '-', '')),
            private.req_text(p->>'name_kn', 80, 'invalid_name'),
            coalesce(private.opt_text(p->>'name_en', 80), private.req_text(p->>'name_kn', 80, 'invalid_name')),
            coalesce((p->>'active')::boolean, true), coalesce((p->>'sort_order')::integer, 100))
    returning * into v_new;
  else
    if not v_exists then
      perform private.reject('not_found');
    end if;
    if v_old.revision <> c.base_revision then
      perform private.conflict('stale_revision', jsonb_build_object('rows', private.rows('work_types', to_jsonb(v_old))));
    end if;
    update public.work_types set
      name_kn = private.req_text(p->>'name_kn', 80, 'invalid_name'),
      name_en = coalesce(private.opt_text(p->>'name_en', 80), v_old.name_en),
      active = coalesce((p->>'active')::boolean, v_old.active),
      sort_order = coalesce((p->>'sort_order')::integer, v_old.sort_order)
    where id = v_id
    returning * into v_new;
  end if;
  perform private.audit(c, case when v_exists then 'work_type.updated' else 'work_type.created' end,
    'work_type', v_id, to_jsonb(v_old), to_jsonb(v_new));
  return private.rows('work_types', to_jsonb(v_new));
end;
$$;

create or replace function private.op_work_assignment_upsert(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_id uuid := (p->>'id')::uuid;
  v_date date := (p->>'work_date')::date;
  v_old public.work_assignments;
  v_new public.work_assignments;
  v_exists boolean;
  v_workers uuid[] := coalesce(
    (select array_agg(distinct x::uuid) from jsonb_array_elements_text(coalesce(p->'worker_ids', '[]'::jsonb)) x),
    '{}'::uuid[]);
  v_rows jsonb;
begin
  if v_date is null or v_date < date '2000-01-01' or v_date > private.farm_today(c.farm_id) + 366 then
    perform private.reject('invalid_date');
  end if;
  if coalesce(p->>'status', '') not in ('planned', 'in_progress', 'completed', 'cancelled') then
    perform private.reject('invalid_status');
  end if;
  select * into v_old from public.work_assignments where id = v_id for update;
  v_exists := found;
  if v_exists and v_old.farm_id <> c.farm_id then
    perform private.reject('not_found');
  end if;
  if c.base_revision = 0 then
    if v_exists then
      perform private.conflict('already_exists', jsonb_build_object('rows', private.rows('work_assignments', to_jsonb(v_old))));
    end if;
    insert into public.work_assignments (id, farm_id, work_date, work_type_id, field_name, description,
                                         status, notes, assigned_by, updated_by)
    values (v_id, c.farm_id, v_date, (p->>'work_type_id')::uuid, private.opt_text(p->>'field_name', 100),
            private.opt_text(p->>'description', 500), p->>'status', private.opt_text(p->>'notes', 500),
            c.actor_id, c.actor_id)
    returning * into v_new;
  else
    if not v_exists then
      perform private.reject('not_found');
    end if;
    if v_old.revision <> c.base_revision then
      perform private.conflict('stale_revision', jsonb_build_object('rows', private.rows('work_assignments', to_jsonb(v_old))));
    end if;
    update public.work_assignments set
      work_date = v_date,
      work_type_id = (p->>'work_type_id')::uuid,
      field_name = private.opt_text(p->>'field_name', 100),
      description = private.opt_text(p->>'description', 500),
      status = p->>'status',
      notes = private.opt_text(p->>'notes', 500),
      updated_by = c.actor_id
    where id = v_id
    returning * into v_new;
  end if;

  insert into public.work_assignment_workers (farm_id, assignment_id, worker_id, removed)
  select c.farm_id, v_id, w, false from unnest(v_workers) w
  on conflict (assignment_id, worker_id) do update set removed = false
    where public.work_assignment_workers.removed;
  update public.work_assignment_workers set removed = true
    where assignment_id = v_id and not removed and not (worker_id = any (v_workers));

  perform private.audit(c, case when v_exists then 'work.updated' else 'work.assigned' end,
    'work_assignment', v_id, to_jsonb(v_old), to_jsonb(v_new) || jsonb_build_object('worker_ids', to_jsonb(v_workers)));

  select coalesce(jsonb_agg(jsonb_build_object('t', 'work_assignment_workers', 'd', to_jsonb(w))), '[]'::jsonb)
    into v_rows from public.work_assignment_workers w where w.assignment_id = v_id;
  return private.rows('work_assignments', to_jsonb(v_new)) || v_rows;
end;
$$;

-- Validates and inserts one new ledger entry. Shared by ledger_create and
-- ledger_correct.
create or replace function private.ledger_insert(c private.op_ctx, p jsonb)
returns public.financial_transactions language plpgsql set search_path = '' as $$
declare
  v_type text := p->>'entry_type';
  v_amount bigint := (p->>'amount_paise')::bigint;
  v_worker uuid := (p->>'worker_id')::uuid;
  v_leader uuid := (p->>'leader_worker_id')::uuid;
  v_date date := (p->>'business_date')::date;
  v_method text := coalesce(p->>'method', 'cash');
  v_paid_by uuid := (p->>'paid_by')::uuid;
  v_paid_by_name text;
  v_related uuid := (p->>'related_entry_id')::uuid;
  v_related_row public.financial_transactions;
  v_cash boolean;
  v_avail bigint;
  v_new public.financial_transactions;
  v_wage_affecting boolean;
begin
  if v_type is null or v_type not in (
    'advance', 'wage_payment', 'bonus', 'addition', 'deduction', 'opening_balance',
    'loan', 'loan_repayment', 'loan_offset', 'reimbursement',
    'leader_transfer', 'leader_allocation', 'leader_return', 'leader_self_funded') then
    perform private.reject('invalid_entry_type');
  end if;
  if v_amount is null or v_amount = 0 or abs(v_amount) > 100000000000
     or (v_type <> 'opening_balance' and v_amount < 0) then
    perform private.reject('invalid_amount');
  end if;
  perform private.check_business_date(c.farm_id, v_date);
  if not exists (select 1 from public.workers where id = v_worker and farm_id = c.farm_id) then
    perform private.reject('invalid_worker');
  end if;

  v_cash := v_type in ('advance', 'wage_payment', 'bonus', 'loan', 'loan_repayment',
                       'reimbursement', 'leader_transfer', 'leader_return');
  if v_cash then
    if v_method not in ('cash', 'upi', 'bank', 'other') then
      perform private.reject('invalid_method');
    end if;
    if v_paid_by is null then
      v_paid_by := c.actor_id;
    end if;
    select full_name into v_paid_by_name from public.farm_members
      where farm_id = c.farm_id and user_id = v_paid_by;
    if v_paid_by_name is null then
      perform private.reject('invalid_payer');
    end if;
  else
    v_method := 'none';
    v_paid_by := null;
  end if;

  if v_type in ('leader_allocation', 'leader_self_funded') then
    if v_leader is null then
      perform private.reject('leader_required');
    end if;
  else
    v_leader := null;
  end if;

  -- Leader pool checks run under a lock on the leader's worker row so two
  -- concurrent allocations cannot both spend the same money.
  if v_type in ('leader_transfer', 'leader_return') then
    perform 1 from public.workers where id = v_worker and farm_id = c.farm_id and is_leader for update;
    if not found then
      perform private.reject('not_a_leader');
    end if;
  end if;
  if v_type in ('leader_allocation', 'leader_self_funded') then
    perform 1 from public.workers where id = v_leader and farm_id = c.farm_id and is_leader for update;
    if not found then
      perform private.reject('not_a_leader');
    end if;
  end if;
  if v_type = 'leader_allocation' then
    v_avail := private.leader_pool(c.farm_id, v_leader);
    if v_amount > v_avail then
      perform private.reject('insufficient_leader_funds', jsonb_build_object('available_paise', v_avail));
    end if;
  elsif v_type = 'leader_return' then
    v_avail := private.leader_pool(c.farm_id, v_worker);
    if v_amount > v_avail then
      perform private.reject('insufficient_leader_funds', jsonb_build_object('available_paise', v_avail));
    end if;
  elsif v_type in ('loan_repayment', 'loan_offset') then
    perform 1 from public.workers where id = v_worker for update;
    v_avail := private.loan_balance(c.farm_id, v_worker);
    if v_amount > v_avail then
      perform private.reject('exceeds_loan_balance', jsonb_build_object('available_paise', v_avail));
    end if;
  end if;

  if v_related is not null then
    select * into v_related_row from public.financial_transactions
      where id = v_related and farm_id = c.farm_id;
    if not found then
      perform private.reject('invalid_related_entry');
    end if;
    if v_type = 'reimbursement' then
      if v_related_row.entry_type <> 'leader_self_funded' or v_related_row.leader_worker_id <> v_worker
         or v_related_row.is_reversal then
        perform private.reject('invalid_related_entry');
      end if;
      perform 1 from public.workers where id = v_worker for update;
      v_avail := private.leader_payable(c.farm_id, v_worker);
      if v_amount > v_avail then
        perform private.reject('exceeds_leader_payable', jsonb_build_object('available_paise', v_avail));
      end if;
    end if;
  end if;

  v_wage_affecting := v_type not in ('loan', 'loan_repayment', 'reimbursement', 'leader_transfer', 'leader_return');
  if v_wage_affecting then
    perform private.guard_period(c, v_date);
  end if;

  insert into public.financial_transactions (
    id, farm_id, entry_type, worker_id, leader_worker_id, amount_paise, is_reversal, reverses_id,
    related_entry_id, business_date, occurred_at, method, reference, notes, paid_by, paid_by_name,
    recorded_by, recorded_by_name, source_device_id, op_id)
  values (
    (p->>'id')::uuid, c.farm_id, v_type, v_worker, v_leader, v_amount, false, null,
    v_related, v_date, coalesce((p->>'occurred_at')::timestamptz, now()), v_method,
    private.opt_text(p->>'reference', 100), private.opt_text(p->>'notes', 500), v_paid_by, v_paid_by_name,
    c.actor_id, c.actor_name, c.device_id, c.op_id)
  returning * into v_new;
  perform private.audit(c, 'ledger.' || v_type, 'financial_transaction', v_new.id, null, to_jsonb(v_new));
  return v_new;
end;
$$;

create or replace function private.ledger_reverse_row(c private.op_ctx, p jsonb)
returns public.financial_transactions language plpgsql set search_path = '' as $$
declare
  v_orig public.financial_transactions;
  v_existing public.financial_transactions;
  v_new public.financial_transactions;
  v_reason text := private.req_text(p->>'reason', 500, 'reason_required');
begin
  select * into v_orig from public.financial_transactions
    where id = (p->>'reverses_id')::uuid and farm_id = c.farm_id;
  if not found then
    perform private.reject('not_found');
  end if;
  if v_orig.is_reversal then
    perform private.reject('cannot_reverse_reversal');
  end if;
  select * into v_existing from public.financial_transactions where reverses_id = v_orig.id;
  if found then
    perform private.conflict('already_reversed', jsonb_build_object('rows', private.rows('financial_transactions', to_jsonb(v_existing))));
  end if;
  if c.role not in ('owner', 'admin') and v_orig.recorded_by <> c.actor_id then
    perform private.reject('forbidden');
  end if;

  -- Reversals must not leave a leader pool, loan or payable negative.
  if v_orig.entry_type = 'leader_transfer' then
    perform 1 from public.workers where id = v_orig.worker_id for update;
    if private.leader_pool(c.farm_id, v_orig.worker_id) < v_orig.amount_paise then
      perform private.reject('leader_funds_already_used',
        jsonb_build_object('available_paise', private.leader_pool(c.farm_id, v_orig.worker_id)));
    end if;
  elsif v_orig.entry_type = 'loan' then
    perform 1 from public.workers where id = v_orig.worker_id for update;
    if private.loan_balance(c.farm_id, v_orig.worker_id) < v_orig.amount_paise then
      perform private.reject('loan_already_repaid');
    end if;
  elsif v_orig.entry_type = 'leader_self_funded' then
    perform 1 from public.workers where id = v_orig.leader_worker_id for update;
    if private.leader_payable(c.farm_id, v_orig.leader_worker_id) < v_orig.amount_paise then
      perform private.reject('leader_payable_already_settled');
    end if;
  end if;

  if v_orig.entry_type not in ('loan', 'loan_repayment', 'reimbursement', 'leader_transfer', 'leader_return') then
    perform private.guard_period(c, v_orig.business_date);
  end if;

  insert into public.financial_transactions (
    id, farm_id, entry_type, worker_id, leader_worker_id, amount_paise, is_reversal, reverses_id,
    related_entry_id, business_date, occurred_at, method, reference, notes, paid_by, paid_by_name,
    recorded_by, recorded_by_name, source_device_id, op_id)
  values (
    (p->>'id')::uuid, c.farm_id, v_orig.entry_type, v_orig.worker_id, v_orig.leader_worker_id,
    v_orig.amount_paise, true, v_orig.id, v_orig.related_entry_id, v_orig.business_date, now(),
    v_orig.method, v_orig.reference, v_reason, v_orig.paid_by, v_orig.paid_by_name,
    c.actor_id, c.actor_name, c.device_id, c.op_id)
  returning * into v_new;
  perform private.audit(c, 'ledger.reversed', 'financial_transaction', v_orig.id, to_jsonb(v_orig), to_jsonb(v_new));
  return v_new;
end;
$$;

create or replace function private.op_ledger_create(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
begin
  if exists (select 1 from public.financial_transactions where id = (p->>'id')::uuid) then
    perform private.conflict('already_exists');
  end if;
  return private.rows('financial_transactions', to_jsonb(private.ledger_insert(c, p)));
end;
$$;

create or replace function private.op_ledger_reverse(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
begin
  return private.rows('financial_transactions', to_jsonb(private.ledger_reverse_row(c, p)));
end;
$$;

-- Atomic correction: reverse the original and record the replacement.
create or replace function private.op_ledger_correct(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_rev public.financial_transactions;
  v_new public.financial_transactions;
begin
  v_rev := private.ledger_reverse_row(c, p->'reverse');
  v_new := private.ledger_insert(c, p->'create');
  return private.rows('financial_transactions', to_jsonb(v_rev))
      || private.rows('financial_transactions', to_jsonb(v_new));
end;
$$;

create or replace function private.snapshot_settlement(c private.op_ctx, p_settlement public.settlements)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_rows jsonb;
begin
  insert into public.settlement_items as si (farm_id, settlement_id, worker_id, units_milli, opening_paise,
    gross_paise, additions_paise, advances_paise, direct_paid_paise, leader_paid_paise, closing_paise)
  select c.farm_id, p_settlement.id, s.worker_id, s.units_milli, s.opening_paise, s.gross_paise,
         s.additions_paise, s.advances_paise, s.direct_paid_paise, s.leader_paid_paise, s.closing_paise
  from private.period_summary(c.farm_id, p_settlement.week_start, p_settlement.week_end) s
  on conflict (settlement_id, worker_id) do update set
    units_milli = excluded.units_milli, opening_paise = excluded.opening_paise,
    gross_paise = excluded.gross_paise, additions_paise = excluded.additions_paise,
    advances_paise = excluded.advances_paise, direct_paid_paise = excluded.direct_paid_paise,
    leader_paid_paise = excluded.leader_paid_paise, closing_paise = excluded.closing_paise
  where (si.units_milli, si.opening_paise, si.gross_paise, si.additions_paise, si.advances_paise,
         si.direct_paid_paise, si.leader_paid_paise, si.closing_paise)
    is distinct from
        (excluded.units_milli, excluded.opening_paise, excluded.gross_paise, excluded.additions_paise,
         excluded.advances_paise, excluded.direct_paid_paise, excluded.leader_paid_paise, excluded.closing_paise);

  -- Workers whose activity disappeared (e.g. reversed) are zeroed, not deleted,
  -- so the change syncs.
  update public.settlement_items si set
    units_milli = 0, opening_paise = 0, gross_paise = 0, additions_paise = 0, advances_paise = 0,
    direct_paid_paise = 0, leader_paid_paise = 0, closing_paise = 0
  where si.settlement_id = p_settlement.id
    and not exists (select 1 from private.period_summary(c.farm_id, p_settlement.week_start, p_settlement.week_end) s
                    where s.worker_id = si.worker_id)
    and (si.units_milli, si.opening_paise, si.gross_paise, si.additions_paise, si.advances_paise,
         si.direct_paid_paise, si.leader_paid_paise, si.closing_paise) <> (0, 0, 0, 0, 0, 0, 0, 0);

  select coalesce(jsonb_agg(jsonb_build_object('t', 'settlement_items', 'd', to_jsonb(si))), '[]'::jsonb)
    into v_rows from public.settlement_items si where si.settlement_id = p_settlement.id;
  return v_rows;
end;
$$;

-- Closing a week (or re-closing a flagged one = marking it reviewed).
create or replace function private.op_settlement_close(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_start date := (p->>'week_start')::date;
  v_old public.settlements;
  v_new public.settlements;
  v_exists boolean;
  v_week_day smallint;
begin
  select week_start_day into v_week_day from public.farms where id = c.farm_id;
  if v_start is null or extract(isodow from v_start)::smallint <> v_week_day then
    perform private.reject('invalid_week');
  end if;
  if v_start > private.farm_today(c.farm_id) then
    perform private.reject('week_in_future');
  end if;
  select * into v_old from public.settlements where farm_id = c.farm_id and week_start = v_start for update;
  v_exists := found;
  if v_exists then
    update public.settlements set
      status = 'closed', needs_review = false, closed_by = c.actor_id, closed_by_name = c.actor_name,
      closed_at = now(), notes = coalesce(private.opt_text(p->>'notes', 500), v_old.notes)
    where id = v_old.id
    returning * into v_new;
  else
    insert into public.settlements (id, farm_id, week_start, week_end, status, needs_review,
                                    closed_by, closed_by_name, closed_at, notes)
    values ((p->>'id')::uuid, c.farm_id, v_start, v_start + 6, 'closed', false,
            c.actor_id, c.actor_name, now(), private.opt_text(p->>'notes', 500))
    returning * into v_new;
  end if;
  perform private.audit(c,
    case when v_exists and v_old.status = 'closed' then 'settlement.reviewed' else 'settlement.closed' end,
    'settlement', v_new.id, to_jsonb(v_old), to_jsonb(v_new));
  return private.rows('settlements', to_jsonb(v_new)) || private.snapshot_settlement(c, v_new);
end;
$$;

create or replace function private.op_settlement_reopen(c private.op_ctx, p jsonb)
returns jsonb language plpgsql set search_path = '' as $$
declare
  v_old public.settlements;
  v_new public.settlements;
begin
  perform private.require_admin(c);
  select * into v_old from public.settlements
    where farm_id = c.farm_id and week_start = (p->>'week_start')::date for update;
  if not found then
    perform private.reject('not_found');
  end if;
  update public.settlements set status = 'open', needs_review = false where id = v_old.id returning * into v_new;
  perform private.audit(c, 'settlement.reopened', 'settlement', v_new.id, to_jsonb(v_old), to_jsonb(v_new));
  return private.rows('settlements', to_jsonb(v_new));
end;
$$;

-- ---------------------------------------------------------------------------
-- Dispatcher
-- ---------------------------------------------------------------------------

create or replace function private.apply_one(p_uid uuid, p_op jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_op_id uuid := private.try_uuid(p_op->>'op_id');
  v_farm uuid := private.try_uuid(p_op->>'farm_id');
  v_type text := p_op->>'op_type';
  v_prev public.sync_operations;
  v_member public.farm_members;
  c private.op_ctx;
  v_rows jsonb;
  v_res jsonb;
  v_state text;
  v_msg text;
  v_detail text;
  v_data jsonb;
begin
  if v_op_id is null or v_farm is null or v_type is null then
    return jsonb_build_object('op_id', p_op->>'op_id', 'status', 'rejected', 'code', 'invalid_operation');
  end if;

  -- Idempotent replay: return the stored outcome.
  select * into v_prev from public.sync_operations where op_id = v_op_id;
  if found then
    if v_prev.actor_id <> p_uid or v_prev.farm_id <> v_farm then
      return jsonb_build_object('op_id', v_op_id, 'status', 'rejected', 'code', 'op_id_reused');
    end if;
    return v_prev.result || jsonb_build_object('replayed', true);
  end if;

  select * into v_member from public.farm_members
    where farm_id = v_farm and user_id = p_uid and status = 'active' and role in ('owner', 'admin', 'member');
  if not found then
    -- Not stored: the op may succeed if access is restored.
    return jsonb_build_object('op_id', v_op_id, 'status', 'rejected', 'code', 'not_a_member', 'retryable', true);
  end if;

  -- Serialize all writers of this farm for the rest of the transaction.
  perform private.next_seq(v_farm);

  c := row(v_farm, p_uid, v_member.full_name, v_member.role, left(p_op->>'device_id', 64), v_op_id,
           coalesce(case when p_op->>'base_revision' ~ '^[0-9]{1,9}$' then (p_op->>'base_revision')::integer end, 0)
          )::private.op_ctx;

  begin
    v_rows := case v_type
      when 'farm_update' then private.op_farm_update(c, p_op->'payload')
      when 'profile_update' then private.op_profile_update(c, p_op->'payload')
      when 'member_invite' then private.op_member_invite(c, p_op->'payload')
      when 'member_update' then private.op_member_update(c, p_op->'payload')
      when 'worker_upsert' then private.op_worker_upsert(c, p_op->'payload')
      when 'group_upsert' then private.op_group_upsert(c, p_op->'payload')
      when 'attendance_upsert' then private.op_attendance_upsert(c, p_op->'payload')
      when 'work_type_upsert' then private.op_work_type_upsert(c, p_op->'payload')
      when 'work_assignment_upsert' then private.op_work_assignment_upsert(c, p_op->'payload')
      when 'ledger_create' then private.op_ledger_create(c, p_op->'payload')
      when 'ledger_reverse' then private.op_ledger_reverse(c, p_op->'payload')
      when 'ledger_correct' then private.op_ledger_correct(c, p_op->'payload')
      when 'settlement_close' then private.op_settlement_close(c, p_op->'payload')
      when 'settlement_reopen' then private.op_settlement_reopen(c, p_op->'payload')
      else null
    end;
    if v_rows is null then
      perform private.reject('unknown_op_type');
    end if;
    v_res := jsonb_build_object('op_id', v_op_id, 'status', 'applied', 'rows', v_rows);
  exception
    when sqlstate 'SR001' or sqlstate 'SC001' then
      get stacked diagnostics v_state = returned_sqlstate, v_msg = message_text, v_detail = pg_exception_detail;
      v_data := coalesce(nullif(v_detail, '')::jsonb, '{}'::jsonb);
      v_res := jsonb_build_object(
        'op_id', v_op_id,
        'status', case when v_state = 'SC001' then 'conflict' else 'rejected' end,
        'code', v_msg,
        'data', v_data - 'rows',
        'rows', coalesce(v_data->'rows', '[]'::jsonb));
    -- Malformed or invalid data is deterministic: reject and remember it.
    when invalid_text_representation or numeric_value_out_of_range or invalid_datetime_format
         or datetime_field_overflow or not_null_violation or check_violation
         or foreign_key_violation or unique_violation or string_data_right_truncation then
      get stacked diagnostics v_state = returned_sqlstate, v_msg = message_text;
      v_res := jsonb_build_object('op_id', v_op_id, 'status', 'rejected', 'code', 'invalid_data',
                                  'data', jsonb_build_object('sqlstate', v_state));
  end;

  insert into public.sync_operations (op_id, farm_id, actor_id, device_id, op_type, entity_id, status, result)
  values (v_op_id, v_farm, p_uid, c.device_id, v_type, private.try_uuid(p_op->>'entity_id'), v_res->>'status', v_res);
  return v_res;
end;
$$;

-- ---------------------------------------------------------------------------
-- Public RPC endpoints
-- ---------------------------------------------------------------------------

-- Upload a batch of operations (max 50). Each op is applied in its own
-- savepoint; unexpected failures are reported as retryable and not stored.
create or replace function public.apply_ops(p_ops jsonb)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_op jsonb;
  v_res jsonb;
  v_results jsonb := '[]'::jsonb;
  v_state text;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if jsonb_typeof(p_ops) <> 'array' or jsonb_array_length(p_ops) > 50 then
    raise exception 'invalid_batch' using errcode = '22023';
  end if;
  for v_op in select value from jsonb_array_elements(p_ops) loop
    begin
      v_res := private.apply_one(v_uid, v_op);
    exception when others then
      get stacked diagnostics v_state = returned_sqlstate;
      v_res := jsonb_build_object('op_id', v_op->>'op_id', 'status', 'error', 'code', 'server_error',
                                  'retryable', true, 'data', jsonb_build_object('sqlstate', v_state));
    end;
    v_results := v_results || jsonb_build_array(v_res);
  end loop;
  return v_results;
end;
$$;

-- Incremental download. Returns rows with server_seq > p_after in seq order.
create or replace function public.pull_changes(p_farm_id uuid, p_after bigint, p_limit integer default 500)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_limit integer := least(greatest(coalesce(p_limit, 500), 1), 1000);
  v_changes jsonb;
  v_last bigint;
  v_count integer;
begin
  if not exists (select 1 from private.my_farm_ids() f where f = p_farm_id) then
    raise exception 'not_a_member' using errcode = '42501';
  end if;
  with c as (
    select f.server_seq as s, 'farms' as t, to_jsonb(f) as d from public.farms f
      where f.id = p_farm_id and f.server_seq > p_after
    union all select x.server_seq, 'farm_members', to_jsonb(x) from public.farm_members x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'workers', to_jsonb(x) from public.workers x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'worker_groups', to_jsonb(x) from public.worker_groups x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'worker_group_memberships', to_jsonb(x) from public.worker_group_memberships x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'attendance', to_jsonb(x) from public.attendance x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'work_types', to_jsonb(x) from public.work_types x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'work_assignments', to_jsonb(x) from public.work_assignments x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'work_assignment_workers', to_jsonb(x) from public.work_assignment_workers x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'financial_transactions', to_jsonb(x) from public.financial_transactions x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'settlements', to_jsonb(x) from public.settlements x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'settlement_items', to_jsonb(x) from public.settlement_items x
      where x.farm_id = p_farm_id and x.server_seq > p_after
    union all select x.server_seq, 'audit_events', to_jsonb(x) from public.audit_events x
      where x.farm_id = p_farm_id and x.server_seq > p_after
  ), page as (
    select * from c order by s limit v_limit
  )
  select coalesce(jsonb_agg(jsonb_build_object('s', s, 't', t, 'd', d) order by s), '[]'::jsonb),
         max(s), count(*)
    into v_changes, v_last, v_count
  from page;
  return jsonb_build_object('changes', v_changes, 'last_seq', coalesce(v_last, p_after),
                            'has_more', v_count = v_limit);
end;
$$;

-- Everything the app needs to decide what the signed-in user may do.
create or replace function public.get_my_context()
returns jsonb language plpgsql stable security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_email text;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  select lower(email) into v_email from auth.users where id = v_uid;
  return jsonb_build_object(
    'user_id', v_uid,
    'email', v_email,
    'server_time', now(),
    'profile', (select to_jsonb(p) from public.user_profiles p where p.id = v_uid),
    'memberships', coalesce((
      select jsonb_agg(jsonb_build_object('member_id', m.id, 'farm_id', m.farm_id, 'farm_name', f.name,
                                          'role', m.role, 'status', m.status, 'full_name', m.full_name)
                       order by m.created_at)
      from public.farm_members m join public.farms f on f.id = m.farm_id
      where m.user_id = v_uid), '[]'::jsonb),
    'invitations', coalesce((
      select jsonb_agg(jsonb_build_object('member_id', m.id, 'farm_id', m.farm_id, 'farm_name', f.name,
                                          'role', m.role, 'full_name', m.full_name))
      from public.farm_members m join public.farms f on f.id = m.farm_id
      where m.user_id is null and m.status = 'invited' and m.email = v_email), '[]'::jsonb));
end;
$$;

-- Owner onboarding. Idempotent for the same farm id and owner.
create or replace function public.create_farm(p_farm_id uuid, p_farm_name text, p_full_name text,
                                              p_display_name_kn text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_email text;
  v_name text;
  v_member_id uuid := gen_random_uuid();
  c private.op_ctx;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if exists (select 1 from public.farms where id = p_farm_id) then
    if exists (select 1 from public.farms where id = p_farm_id and created_by = v_uid) then
      return public.get_my_context();
    end if;
    raise exception 'farm_exists' using errcode = '42501';
  end if;
  if exists (select 1 from public.farm_members where user_id = v_uid and status = 'active') then
    raise exception 'already_member' using errcode = '42501';
  end if;
  select lower(email) into v_email from auth.users where id = v_uid;
  v_name := private.req_text(p_full_name, 100, 'invalid_name');

  insert into public.user_profiles (id, full_name, display_name_kn, email)
  values (v_uid, v_name, private.opt_text(p_display_name_kn, 100), v_email)
  on conflict (id) do update set full_name = excluded.full_name, display_name_kn = excluded.display_name_kn;

  insert into public.farms (id, name, created_by)
  values (p_farm_id, private.req_text(p_farm_name, 120, 'invalid_name'), v_uid);

  insert into public.farm_members (id, farm_id, user_id, email, role, status, full_name, display_name_kn)
  values (v_member_id, p_farm_id, v_uid, coalesce(v_email, v_uid::text || '@unknown.local'), 'owner', 'active',
          v_name, private.opt_text(p_display_name_kn, 100));

  insert into public.work_types (id, farm_id, code, name_kn, name_en, sort_order) values
    (gen_random_uuid(), p_farm_id, 'arecanut_harvest', 'ಅಡಿಕೆ ಕೊಯ್ಲು', 'Arecanut harvesting', 10),
    (gen_random_uuid(), p_farm_id, 'weeding', 'ಕಳೆ ತೆಗೆಯುವುದು', 'Weeding', 20),
    (gen_random_uuid(), p_farm_id, 'fertilizer', 'ಗೊಬ್ಬರ ಹಾಕುವುದು', 'Fertilizer application', 30),
    (gen_random_uuid(), p_farm_id, 'irrigation', 'ನೀರು ಹಾಯಿಸುವುದು', 'Irrigation', 40),
    (gen_random_uuid(), p_farm_id, 'cleaning', 'ಸ್ವಚ್ಛತೆ', 'Cleaning', 50),
    (gen_random_uuid(), p_farm_id, 'other', 'ಇತರೆ', 'Other', 90);

  c := row(p_farm_id, v_uid, v_name, 'owner', null, null, 0)::private.op_ctx;
  perform private.audit(c, 'farm.created', 'farm', p_farm_id, null,
                        (select to_jsonb(f) from public.farms f where f.id = p_farm_id));
  return public.get_my_context();
end;
$$;

-- An invited family member joins after signing up with the invited email.
create or replace function public.accept_invitation(p_member_id uuid, p_full_name text,
                                                    p_display_name_kn text default null)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := auth.uid();
  v_email text;
  v_confirmed timestamptz;
  v_old public.farm_members;
  v_new public.farm_members;
  v_name text;
  c private.op_ctx;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  select lower(email), confirmed_at into v_email, v_confirmed from auth.users where id = v_uid;
  if v_confirmed is null then
    raise exception 'email_not_confirmed' using errcode = '42501';
  end if;
  select * into v_old from public.farm_members
    where id = p_member_id and user_id is null and status = 'invited' and email = v_email for update;
  if not found then
    raise exception 'invitation_not_found' using errcode = '42501';
  end if;
  v_name := coalesce(private.opt_text(p_full_name, 100), v_old.full_name);

  insert into public.user_profiles (id, full_name, display_name_kn, email)
  values (v_uid, v_name, private.opt_text(p_display_name_kn, 100), v_email)
  on conflict (id) do update set full_name = excluded.full_name,
    display_name_kn = coalesce(excluded.display_name_kn, public.user_profiles.display_name_kn);

  update public.farm_members set user_id = v_uid, status = 'active', full_name = v_name,
    display_name_kn = private.opt_text(p_display_name_kn, 100)
  where id = v_old.id returning * into v_new;

  c := row(v_old.farm_id, v_uid, v_name, v_new.role, null, null, 0)::private.op_ctx;
  perform private.audit(c, 'member.joined', 'member', v_new.id, to_jsonb(v_old), to_jsonb(v_new));
  return public.get_my_context();
end;
$$;
