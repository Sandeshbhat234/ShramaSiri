#!/usr/bin/env bash
# Runs the database test suite against a disposable Postgres container built
# from the Supabase Postgres image (which provides auth.uid(), auth.users and
# the anon/authenticated roles).
#
#   supabase/tests/run_tests.sh            # start container, test, remove it
#   KEEP=1 supabase/tests/run_tests.sh     # leave the container running
set -euo pipefail
cd "$(dirname "$0")/../.."

NAME=${PG_CONTAINER:-shramasiri-pgtest}
IMAGE=${PG_IMAGE:-public.ecr.aws/supabase/postgres:17.6.1.166}

if ! docker ps --format '{{.Names}}' | grep -qx "$NAME"; then
  docker run -d --name "$NAME" -e POSTGRES_PASSWORD=postgres "$IMAGE" >/dev/null
  echo "waiting for postgres..."
  for _ in $(seq 1 60); do
    docker exec "$NAME" pg_isready -U postgres >/dev/null 2>&1 && break
    sleep 1
  done
  sleep 5
fi

psql() { docker exec -i "$NAME" psql -U postgres -X -v ON_ERROR_STOP=1 -q "$@"; }

psql -c "drop schema if exists tests cascade; drop schema if exists private cascade;" \
     -c "drop table if exists public.farm_sync_state, public.farms, public.user_profiles, public.farm_members,
           public.workers, public.worker_groups, public.worker_group_memberships, public.attendance,
           public.work_types, public.work_assignments, public.work_assignment_workers,
           public.financial_transactions, public.settlements, public.settlement_items,
           public.audit_events, public.sync_operations cascade;" \
     -c "drop function if exists public.apply_ops, public.pull_changes, public.get_my_context,
           public.create_farm, public.accept_invitation;" >/dev/null 2>&1 || true

for f in supabase/migrations/*.sql; do
  echo "applying $f"
  psql < "$f" >/dev/null
done

echo "running tests"
# Query results go to /dev/null; NOTICE lines (ok - ...) and errors remain.
set +e
psql -o /dev/null < supabase/tests/database_test.sql 2>&1 | sed -e 's/^psql:[^ ]* //' -e 's/^NOTICE:  //'
status=${PIPESTATUS[0]}
if [ "$status" = "0" ]; then
  PG_CONTAINER="$NAME" bash supabase/tests/concurrency_test.sh || status=$?
fi
set -e

if [ -z "${KEEP:-}" ]; then docker rm -f "$NAME" >/dev/null; fi
exit "$status"
