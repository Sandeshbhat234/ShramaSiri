#!/usr/bin/env bash
# Scenario E / F under real concurrency: two sessions race for the same
# leader money and the same attendance slot. Exactly one may win each race.
# Expects the container from run_tests.sh with migrations applied.
set -euo pipefail
NAME=${PG_CONTAINER:-shramasiri-pgtest}
psql() { docker exec -i "$NAME" psql -U postgres -X -v ON_ERROR_STOP=1 -q -t -A "$@"; }

OWNER=c0000000-0000-4000-8000-000000000001
DAD=c0000000-0000-4000-8000-000000000002
FARM=c1000000-0000-4000-8000-000000000001
LEADER=c2000000-0000-4000-8000-00000000000a
WA=c2000000-0000-4000-8000-000000000001
WB=c2000000-0000-4000-8000-000000000002

as_user() { # $1 uid, $2 sql
  printf "begin;\nset local role authenticated;\nselect set_config('request.jwt.claim.sub', '%s', true);\n%s\ncommit;\n" "$1" "$2"
}
op() { # $1 type, $2 payload json
  printf "select public.apply_ops(jsonb_build_array(jsonb_build_object('op_id', gen_random_uuid(), 'farm_id', '%s', 'op_type', '%s', 'base_revision', 0, 'device_id', 'race', 'payload', '%s'::jsonb)))->0->>'code', 'x';" "$FARM" "$1" "$2"
}

psql >/dev/null <<SQL
do \$\$ begin
  if exists (select 1 from information_schema.columns where table_schema = 'auth' and table_name = 'users' and column_name = 'email_confirmed_at') then
    insert into auth.users (id, email, email_confirmed_at) values
      ('$OWNER', 'race-owner@example.com', now()), ('$DAD', 'race-dad@example.com', now());
  else
    insert into auth.users (id, email, confirmed_at) values
      ('$OWNER', 'race-owner@example.com', now()), ('$DAD', 'race-dad@example.com', now());
  end if;
end \$\$;
SQL
psql >/dev/null <<SQL
$(as_user $OWNER "select public.create_farm('$FARM', 'Race Farm', 'Race Owner');
$(op member_invite "{\"id\": \"c3000000-0000-4000-8000-000000000001\", \"email\": \"race-dad@example.com\", \"full_name\": \"Race Dad\"}")
$(op worker_upsert "{\"id\": \"$LEADER\", \"name_kn\": \"L\", \"default_wage_paise\": 50000, \"is_leader\": true}")
$(op worker_upsert "{\"id\": \"$WA\", \"name_kn\": \"A\", \"default_wage_paise\": 50000}")
$(op worker_upsert "{\"id\": \"$WB\", \"name_kn\": \"B\", \"default_wage_paise\": 50000}")
$(op ledger_create "{\"id\": \"c4000000-0000-4000-8000-000000000001\", \"entry_type\": \"leader_transfer\", \"worker_id\": \"$LEADER\", \"amount_paise\": 50000, \"business_date\": \"2026-10-17\"}")")
$(as_user $DAD "select public.accept_invitation('c3000000-0000-4000-8000-000000000001', 'Race Dad');")
SQL

# Session 1 allocates and holds its transaction open; session 2 races it.
race() { # $1 uid, $2 sql-with-op, $3 sleep-after
  as_user "$1" "select coalesce(($2)::text, 'applied'); select pg_sleep($3);" | psql 2>&1 | sed -n 2p
}
alloc_a=$(op ledger_create "{\"id\": \"c4000000-0000-4000-8000-0000000000a1\", \"entry_type\": \"leader_allocation\", \"worker_id\": \"$WA\", \"leader_worker_id\": \"$LEADER\", \"amount_paise\": 50000, \"business_date\": \"2026-10-17\"}" | sed 's/, .x.;$//; s/^select //')
alloc_b=$(op ledger_create "{\"id\": \"c4000000-0000-4000-8000-0000000000b1\", \"entry_type\": \"leader_allocation\", \"worker_id\": \"$WB\", \"leader_worker_id\": \"$LEADER\", \"amount_paise\": 50000, \"business_date\": \"2026-10-17\"}" | sed 's/, .x.;$//; s/^select //')
race $OWNER "$alloc_a" 2 > /tmp/race1.out &
sleep 0.5
race $DAD "$alloc_b" 0 > /tmp/race2.out &
wait
r1=$(cat /tmp/race1.out); r2=$(cat /tmp/race2.out)
echo "allocation race: session1=$r1 session2=$r2"

pool=$(psql -c "select private.leader_pool('$FARM', '$LEADER');")
allocs=$(psql -c "select count(*) from public.financial_transactions where farm_id = '$FARM' and entry_type = 'leader_allocation';")
[ "$pool" = "0" ] && [ "$allocs" = "1" ] && [ "$r2" = "insufficient_leader_funds" ] \
  || { echo "FAILED: concurrent allocations overspent (pool=$pool allocations=$allocs)"; exit 1; }
echo "ok - scenario E (concurrent): one allocation applied, the other rejected, pool never negative"

att_a=$(op attendance_upsert "{\"id\": \"c5000000-0000-4000-8000-0000000000a1\", \"worker_id\": \"$WA\", \"work_date\": \"2026-10-16\", \"units_milli\": 1000, \"rate_paise\": 50000}" | sed 's/, .x.;$//; s/^select //')
att_b=$(op attendance_upsert "{\"id\": \"c5000000-0000-4000-8000-0000000000b1\", \"worker_id\": \"$WA\", \"work_date\": \"2026-10-16\", \"units_milli\": 500, \"rate_paise\": 50000}" | sed 's/, .x.;$//; s/^select //')
race $OWNER "$att_a" 2 > /tmp/race3.out &
sleep 0.5
race $DAD "$att_b" 0 > /tmp/race4.out &
wait
r3=$(cat /tmp/race3.out); r4=$(cat /tmp/race4.out)
echo "attendance race: session1=$r3 session2=$r4"
rows=$(psql -c "select count(*) from public.attendance where worker_id = '$WA' and work_date = '2026-10-16';")
[ "$rows" = "1" ] && [ "$r4" = "attendance_exists" ] \
  || { echo "FAILED: concurrent attendance duplicated (rows=$rows)"; exit 1; }
echo "ok - scenario F (concurrent): one attendance row, the other device gets a conflict"
echo "CONCURRENCY TESTS PASSED"
