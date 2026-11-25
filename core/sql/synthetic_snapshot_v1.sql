-- Synthetic-only isolated subsystem. No dependency on production tables.
create table edith_core.fixture_v1 (
 folio text primary key check(folio ~ '^CORE-TEST-[0-9]{3}$'),
 source_year int not null, epi_week int, district text, synthetic_person_key text not null,
 payload jsonb not null check(jsonb_typeof(payload)='object')
);
create table edith_core.snapshot_v1 (
 run_id bigint generated always as identity primary key,
 generated_at timestamptz not null default now(),
 rule_version text not null default 'core-v1-alpha',
 payload jsonb not null,
 check(payload->>'environment'='SYNTHETIC_STAGING')
);
alter table edith_core.fixture_v1 enable row level security;
alter table edith_core.snapshot_v1 enable row level security;
revoke all on all tables in schema edith_core from public,anon,authenticated;
revoke all on all sequences in schema edith_core from public,anon,authenticated;
insert into edith_core.fixture_v1(folio,source_year,epi_week,district,synthetic_person_key,payload)
select 'CORE-TEST-'||lpad(i::text,3,'0'),2024+((i-1)%3),case when i=7 then 0 when i=8 then null else i end,
 'DS0'||(1+((i-1)%6)),case when i in(10,11) then 'SYNTHETIC-DUPLICATE' else 'SYNTHETIC-'||i end,
 jsonb_build_object('CLAS_FINAL',case i%4 when 0 then 'CONFIRMADO' when 1 then 'DESCARTADO' when 2 then 'ZONA GRIS' else 'PENDIENTE' end,
 'FECHA_NOTIFICACION',case when i=5 then null when i=6 then '2026-02-30' else (2024+((i-1)%3))||'-01-05' end,
 'FECHA_INICIO_ESTUDIO',(2024+((i-1)%3))||'-01-06',
 'FECHA_TERMINACION_ESTUDIO',case when i=9 then (2024+((i-1)%3))||'-01-01' when i%4 in(0,1) then (2024+((i-1)%3))||'-01-10' else null end)
from generate_series(1,24)i;
create function edith_core.refresh_synthetic_v1() returns bigint
language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
declare result_id bigint; doc jsonb;
begin
 perform pg_advisory_xact_lock(20261125,2);
 with b as materialized(select * from fixture_v1), annual as(
 select source_year,count(*) records,count(*) filter(where classify_v1(payload->>'CLAS_FINAL')='CONFIRMADO') confirmed,
 count(*) filter(where classify_v1(payload->>'CLAS_FINAL')='DESCARTADO') discarded,
 count(*) filter(where classify_v1(payload->>'CLAS_FINAL')='ZONA GRIS') gray,
 count(*) filter(where classify_v1(payload->>'CLAS_FINAL')='SIN CLASIFICAR') pending from b group by source_year),
 flags as(select q.code,q.severity,count(*) records from b cross join lateral quality_v1(b.source_year,b.epi_week,b.district,b.payload) q group by 1,2),
 districts as(select source_year,district,count(*) records from b group by 1,2),
 weeks as(select source_year,epi_week,count(*) records from b where epi_week between 1 and 53 group by 1,2)
 select jsonb_build_object('environment','SYNTHETIC_STAGING','rule_version','core-v1-alpha',
 'records',(select count(*) from b),'annual',(select coalesce(jsonb_agg(to_jsonb(a) order by source_year),'[]') from annual a),
 'quality',(select coalesce(jsonb_agg(to_jsonb(f) order by code),'[]') from flags f),
 'districts',(select coalesce(jsonb_agg(to_jsonb(d) order by source_year,district),'[]') from districts d),
 'weekly',(select coalesce(jsonb_agg(to_jsonb(w) order by source_year,epi_week),'[]') from weeks w),
 'duplicate_candidate_groups',(select count(*) from (select synthetic_person_key from b group by 1 having count(*)>1)t)) into doc;
 if exists(select 1 from jsonb_array_elements(doc->'annual') a where (a->>'records')::int<>(a->>'confirmed')::int+(a->>'discarded')::int+(a->>'gray')::int+(a->>'pending')::int) then raise exception 'Annual classification does not close'; end if;
 insert into snapshot_v1(payload) values(doc) returning run_id into result_id;
 return result_id;
end $$;
revoke all on function edith_core.refresh_synthetic_v1() from public,anon,authenticated;
comment on table edith_core.fixture_v1 is 'Synthetic test data only; never import production records.';
comment on table edith_core.snapshot_v1 is 'Private synthetic append-only-by-design snapshots, not an institutional or public data source.';
