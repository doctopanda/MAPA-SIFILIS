-- TITAN TREATMENT: synthetic clinician-plan contract. No drug, dosage or regimen recommendations.
create table edith_core.titan_plan_v1(
 plan_key text primary key check(plan_key~'^PLAN-TEST-[0-9]{3}$'),
 folio text not null references edith_core.titan_episode_v1,
 plan_version int not null check(plan_version>0),
 status text not null check(status in ('BORRADOR','AUTORIZADO','SUSTITUIDO','CANCELADO')),
 protocol_ref text not null check(protocol_ref like 'SYN-PROTOCOL-%'),
 authorization_ref text check(authorization_ref~'^SYN-EVID-[0-9]{3}$'),
 authorized_at timestamptz,
 unique(folio,plan_version),
 check(status<>'AUTORIZADO' or (authorization_ref is not null and authorized_at is not null))
);
create unique index titan_one_authorized_plan_v1 on edith_core.titan_plan_v1(folio) where status='AUTORIZADO';
create table edith_core.titan_plan_item_v1(
 item_key text primary key check(item_key~'^ITEM-TEST-[0-9]{3}$'),
 plan_key text not null references edith_core.titan_plan_v1,
 ordinal int not null check(ordinal>0),
 activity_type text not null check(activity_type in ('ADMINISTRACION','CONTROL','REFERENCIA')),
 scheduled_at timestamptz,
 unique(plan_key,ordinal)
);
create table edith_core.titan_plan_evidence_v1(
 item_key text primary key references edith_core.titan_plan_item_v1,
 performed_at timestamptz not null,
 recorded_at timestamptz not null,
 evidence_ref text not null check(evidence_ref~'^SYN-EVID-[0-9]{3}$'),
 check(recorded_at>=performed_at)
);
create function edith_core.titan_plan_evidence_guard_v1() returns trigger language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
begin
 if not exists(select 1 from titan_plan_item_v1 i join titan_plan_v1 p using(plan_key) where i.item_key=new.item_key and p.status='AUTORIZADO' and new.performed_at>=p.authorized_at) then raise exception 'Authorized plan and valid chronology required' using errcode='23514';end if;
 return new;
end $$;
create trigger titan_plan_evidence_guard before insert or update on edith_core.titan_plan_evidence_v1 for each row execute function edith_core.titan_plan_evidence_guard_v1();
create function edith_core.titan_plan_queue_v1(as_of timestamptz)
returns table(plan_key text,folio text,item_key text,activity_type text,scheduled_at timestamptz,performed_at timestamptz,status text)
language sql stable security invoker set search_path=pg_catalog,edith_core as $$
select p.plan_key,p.folio,i.item_key,i.activity_type,i.scheduled_at,e.performed_at,
case when p.status<>'AUTORIZADO' then 'PLAN_NO_ACTIVO'
when as_of is null then 'NO_CALCULABLE'
when e.performed_at is not null and e.performed_at<=as_of and e.recorded_at<=as_of then 'REALIZADA_DOCUMENTADA'
when i.scheduled_at is null then 'SIN_FECHA'
when i.scheduled_at<as_of then 'SIN_EVIDENCIA_VENCIDA'
when i.scheduled_at-as_of<=interval '48 hours' then 'PROXIMA'
else 'PROGRAMADA' end
from titan_plan_v1 p join titan_plan_item_v1 i using(plan_key) left join titan_plan_evidence_v1 e using(item_key) order by p.plan_key,i.ordinal;
$$;
alter table edith_core.titan_plan_v1 enable row level security;
alter table edith_core.titan_plan_item_v1 enable row level security;
alter table edith_core.titan_plan_evidence_v1 enable row level security;
revoke all on all tables in schema edith_core from public,anon,authenticated;
revoke all on all functions in schema edith_core from public,anon,authenticated;
insert into edith_core.titan_plan_v1 values
('PLAN-TEST-001','TITAN-TEST-PN-001',1,'AUTORIZADO','SYN-PROTOCOL-DEMO','SYN-EVID-201','2026-11-01T09:00-07'),
('PLAN-TEST-002','TITAN-TEST-SA-002',1,'BORRADOR','SYN-PROTOCOL-DEMO',null,null);
insert into edith_core.titan_plan_item_v1 values
('ITEM-TEST-001','PLAN-TEST-001',1,'ADMINISTRACION','2026-11-02T09:00-07'),
('ITEM-TEST-002','PLAN-TEST-001',2,'ADMINISTRACION','2026-11-09T09:00-07'),
('ITEM-TEST-003','PLAN-TEST-001',3,'CONTROL','2026-11-26T09:00-07'),
('ITEM-TEST-004','PLAN-TEST-001',4,'REFERENCIA',null),
('ITEM-TEST-005','PLAN-TEST-002',1,'CONTROL','2026-11-24T09:00-07');
insert into edith_core.titan_plan_evidence_v1 values('ITEM-TEST-001','2026-11-02T10:00-07','2026-11-02T11:00-07','SYN-EVID-202');
comment on function edith_core.titan_plan_queue_v1(timestamptz) is 'Synthetic workflow: due time is entered by clinician, not calculated from a treatment guideline; missing evidence does not establish a missed dose or therapeutic failure.';
