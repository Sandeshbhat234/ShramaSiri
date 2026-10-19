-- ShramaSiri: authorization
-- Clients get read-only access to their own farms' rows through RLS. All
-- writes go through the SECURITY DEFINER RPCs in 0002, which derive the actor
-- from auth.uid() and check membership/role themselves.

-- Private helpers are not reachable by API roles except the one RLS needs.
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;
revoke all on all functions in schema private from public, anon, authenticated;
alter default privileges in schema private revoke execute on functions from public, anon, authenticated;
grant execute on function private.my_farm_ids() to authenticated;

do $$
declare
  t text;
begin
  foreach t in array array[
    'farm_sync_state', 'farms', 'user_profiles', 'farm_members', 'workers', 'worker_groups',
    'worker_group_memberships', 'attendance', 'work_types', 'work_assignments',
    'work_assignment_workers', 'financial_transactions', 'settlements', 'settlement_items',
    'audit_events', 'sync_operations'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from public, anon, authenticated', t);
  end loop;

  -- Read-only, farm-scoped access for active members.
  foreach t in array array[
    'farm_sync_state', 'farm_members', 'workers', 'worker_groups', 'worker_group_memberships',
    'attendance', 'work_types', 'work_assignments', 'work_assignment_workers',
    'financial_transactions', 'settlements', 'settlement_items', 'audit_events'
  ] loop
    execute format('grant select on public.%I to authenticated', t);
    execute format(
      'create policy member_read on public.%I for select to authenticated
         using (farm_id in (select private.my_farm_ids()))', t);
  end loop;
end;
$$;

grant select on public.farms to authenticated;
create policy member_read on public.farms for select to authenticated
  using (id in (select private.my_farm_ids()));

-- Own profile, plus profiles of people who share a farm with you.
grant select on public.user_profiles to authenticated;
create policy profile_read on public.user_profiles for select to authenticated
  using (
    id = auth.uid()
    or id in (select m.user_id from public.farm_members m
              where m.farm_id in (select private.my_farm_ids()) and m.user_id is not null)
  );

-- sync_operations: no policies at all, so no client can read or write it.

-- RPC endpoints: authenticated only.
revoke all on function public.apply_ops(jsonb) from public, anon;
revoke all on function public.pull_changes(uuid, bigint, integer) from public, anon;
revoke all on function public.get_my_context() from public, anon;
revoke all on function public.create_farm(uuid, text, text, text) from public, anon;
revoke all on function public.accept_invitation(uuid, text, text) from public, anon;
grant execute on function public.apply_ops(jsonb) to authenticated;
grant execute on function public.pull_changes(uuid, bigint, integer) to authenticated;
grant execute on function public.get_my_context() to authenticated;
grant execute on function public.create_farm(uuid, text, text, text) to authenticated;
grant execute on function public.accept_invitation(uuid, text, text) to authenticated;

-- Realtime: devices subscribe to their farm's farm_sync_state row and treat
-- each change as a prompt to pull. Only the farm id and counter are exposed.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.farm_sync_state;
  end if;
end;
$$;
