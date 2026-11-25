-- Synthetic directory for adapter contract. Production source remains edith_sc_health_units.
create table edith_core.prenatal_unit_fixture_v1(
 unit_key text primary key check(unit_key~'^UNIT-TEST-[0-9]{3}$'),
 clues text not null unique check(clues~'^TEST-CLUES-[0-9]{3}$'),
 name text not null check(name like 'FICTICIA%'),
 institution text not null, municipality text not null,
 district text not null check(district~'^DS0[1-6]$'),active boolean not null default true
);
alter table edith_core.prenatal_unit_fixture_v1 enable row level security;
insert into edith_core.prenatal_unit_fixture_v1 values
('UNIT-TEST-001','TEST-CLUES-001','FICTICIA CENTRO UNO','TEST-INSTITUCION-A','TEST-MUNICIPIO-A','DS01',true),
('UNIT-TEST-002','TEST-CLUES-002','FICTICIA CENTRO DOS','TEST-INSTITUCION-B','TEST-MUNICIPIO-A','DS01',true),
('UNIT-TEST-003','TEST-CLUES-003','FICTICIA CENTRO TRES','TEST-INSTITUCION-A','TEST-MUNICIPIO-B','DS02',true),
('UNIT-TEST-004','TEST-CLUES-004','FICTICIA CENTRO INACTIVO','TEST-INSTITUCION-A','TEST-MUNICIPIO-A','DS01',false);
create function edith_core.prenatal_unit_search_v1(search text,filter_district text,filter_institution text,filter_municipality text)
returns table(unit_key text,clues text,name text,institution text,municipality text,district text)
language sql stable security invoker set search_path=pg_catalog,edith_core as $$
select u.unit_key,u.clues,u.name,u.institution,u.municipality,u.district from prenatal_unit_fixture_v1 u
where u.active and (filter_district is null or u.district=filter_district)
and (filter_institution is null or u.institution=filter_institution)
and (filter_municipality is null or u.municipality=filter_municipality)
and (nullif(trim(search),'') is null or strpos(lower(u.name),lower(trim(search)))>0 or strpos(lower(u.clues),lower(trim(search)))>0)
order by u.name,u.clues limit 50;
$$;
create table edith_core.prenatal_unit_assignment_v1(
 folio text primary key references edith_core.prenatal_pregnancy_v1,
 unit_key text not null references edith_core.prenatal_unit_fixture_v1,
 assigned_at timestamptz not null default now()
);
alter table edith_core.prenatal_unit_assignment_v1 enable row level security;
create function edith_core.prenatal_unit_guard_v1() returns trigger language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
begin
 if not exists(select 1 from prenatal_unit_fixture_v1 u join prenatal_pregnancy_v1 p on p.district=u.district where p.folio=new.folio and u.unit_key=new.unit_key and u.active) then raise exception 'Unit unavailable or district mismatch' using errcode='23514';end if;
 return new;
end $$;
create trigger prenatal_unit_guard before insert or update on edith_core.prenatal_unit_assignment_v1 for each row execute function edith_core.prenatal_unit_guard_v1();
revoke all on all tables in schema edith_core from public,anon,authenticated;
revoke all on all functions in schema edith_core from public,anon,authenticated;
comment on function edith_core.prenatal_unit_search_v1(text,text,text,text) is 'Synthetic catalog adapter. District filter is not authorization; production derives scope from authenticated session. No write to master CLUES.';
