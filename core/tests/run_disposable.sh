#!/usr/bin/env bash
set -euo pipefail
# Local/disposable CI only. No remote Supabase connection, no credentials or production reads.
export PGHOST=127.0.0.1 PGDATABASE=edith_core_ci
unset DATABASE_URL PGSERVICE PGSERVICEFILE PGOPTIONS
cd "$(dirname "$0")/../.."
psql -X -At -v ON_ERROR_STOP=1 -c "select current_database()" | grep -qx edith_core_ci
psql -X -v ON_ERROR_STOP=1 -c "create role anon nologin; create role authenticated nologin;"
for f in classification_v1 quality_flow_v1 synthetic_snapshot_v1 synthetic_workflow_v1 titan_clock_bridge_v1 prenatal_card_draft_v1 prenatal_capture_bridge_v2 prenatal_catalog_adapter_v1 titan_treatment_plan_lab_v1; do
 psql -X -v ON_ERROR_STOP=1 -f "core/sql/$f.sql"
done
psql -X -At -v ON_ERROR_STOP=1 -f core/tests/classification_v1.sql | grep -qx '12|12|0|f|f|f'
psql -X -At -v ON_ERROR_STOP=1 -f core/tests/quality_flow_snapshot_v1.sql | grep -qx '32|32|\[\]'
psql -X -At -v ON_ERROR_STOP=1 -f core/tests/synthetic_workflow_v1.sql | grep -qx '16|PASS'
psql -X -At -v ON_ERROR_STOP=1 -c "select edith_core.refresh_synthetic_v1();" >/dev/null
psql -X -At -v ON_ERROR_STOP=1 -c "select edith_core.refresh_synthetic_v1();" >/dev/null
psql -X -At -v ON_ERROR_STOP=1 -c "with s as(select payload from edith_core.snapshot_v1 order by run_id desc limit 2) select (select count(*) from s)=2,(select count(distinct payload) from s)=1,(select bool_and((payload->>'records')::int=24 and (payload->>'duplicate_candidate_groups')::int=1) from s),(select bool_and((a->>'records')::int=(a->>'confirmed')::int+(a->>'discarded')::int+(a->>'gray')::int+(a->>'pending')::int) from s cross join lateral jsonb_array_elements(payload->'annual') a);" | grep -qx 't|t|t|t'
psql -X -At -v ON_ERROR_STOP=1 -f core/tests/titan_clock_bridge_v1.sql | grep -qx '29|PASS'
psql -X -At -v ON_ERROR_STOP=1 -f core/tests/prenatal_card_draft_v1.sql | grep -qx '20|PASS'
psql -X -At -v ON_ERROR_STOP=1 -f core/tests/prenatal_capture_bridge_v2.sql | grep -qx '26|PASS'
psql -X -At -v ON_ERROR_STOP=1 -f core/tests/prenatal_catalog_adapter_v1.sql | grep -qx '9|PASS'
psql -X -At -v ON_ERROR_STOP=1 -f core/tests/titan_treatment_plan_lab_v1.sql | grep -qx '12|PASS'
echo "EDITH CORE + TITAN + PRENATAL: 160 checks passed"
