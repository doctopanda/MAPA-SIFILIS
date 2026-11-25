-- TITAN CLOCK/ALERT/BRIDGE v0.1. SYNTHETIC STAGING ONLY.
-- Pure date arithmetic and private fixtures. No dependency on clinical tables.
create function edith_core.titan_due_date_v1(anchor_date date,unit text,amount integer)
returns date language sql immutable security invoker set search_path=pg_catalog as $$
 select case when anchor_date is null or amount is null or amount<0 or amount>1200 then null
 when unit='calendar_days' then anchor_date+amount
 when unit='calendar_months' then (anchor_date+make_interval(months=>amount))::date
 when unit='gestational_weeks' then anchor_date+amount*7
 else null end;
$$;
create function edith_core.titan_clock_v1(
 applicable boolean,unit text,amount integer,anchor_date date,anchor_at timestamptz,
 complete_date date,complete_at timestamptz,as_of timestamptz,warning_days int default 2)
returns jsonb language plpgsql stable security invoker set search_path=pg_catalog,edith_core as $$
declare due_date date; due_at timestamptz; local_today date; status text; timeliness text;
begin
 if applicable is false then return jsonb_build_object('status','NO_APLICA');end if;
 if applicable is null then return jsonb_build_object('status','APLICABILIDAD_PENDIENTE');end if;
 if as_of is null then return jsonb_build_object('status','NO_CALCULABLE');end if;
 if amount is null or amount<0 or amount>1200 or unit not in ('hours','calendar_days','calendar_months','gestational_weeks') or unit is null then return jsonb_build_object('status','REVISION_MANUAL');end if;
 if unit='hours' then
  if anchor_at is null then return jsonb_build_object('status','NO_CALCULABLE');end if;
  if anchor_at>as_of or (complete_at is not null and (complete_at<anchor_at or complete_at>as_of)) then return jsonb_build_object('status','CRONOLOGIA_INVALIDA');end if;
  due_at:=anchor_at+make_interval(hours=>amount);
  if complete_at is not null then status:='CUMPLIDA';timeliness:=case when complete_at<=due_at then 'OPORTUNA' else 'TARDIA' end;
  elsif as_of>due_at then status:='VENCIDA';
  elsif due_at-as_of<=make_interval(hours=>24*greatest(0,least(coalesce(warning_days,0),30))) then status:='PROXIMA';
  else status:='PROGRAMADA';end if;
 else
  if anchor_date is null then return jsonb_build_object('status','NO_CALCULABLE');end if;
  local_today:=(as_of at time zone 'America/Hermosillo')::date;
  if anchor_date>local_today or (complete_date is not null and (complete_date<anchor_date or complete_date>local_today)) then return jsonb_build_object('status','CRONOLOGIA_INVALIDA');end if;
  due_date:=titan_due_date_v1(anchor_date,unit,amount);
  if due_date is null then return jsonb_build_object('status','NO_CALCULABLE');end if;
  if complete_date is not null then status:='CUMPLIDA';timeliness:=case when complete_date<=due_date then 'OPORTUNA' else 'TARDIA' end;
  elsif local_today>due_date then status:='VENCIDA';
  elsif due_date-local_today<=greatest(0,least(coalesce(warning_days,0),30)) then status:='PROXIMA';
  else status:='PROGRAMADA';end if;
 end if;
 return jsonb_strip_nulls(jsonb_build_object('status',status,'timeliness',timeliness,'due_date',due_date,'due_at',due_at));
end $$;
create table edith_core.titan_episode_v1(
 folio text primary key check(folio~'^TITAN-TEST-[A-Z]{2}-[0-9]{3}$'),
 program text not null check(program in ('SA','PRENATAL','SC','INFANCIA')),
 district text not null check(district~'^DS0[1-6]$'),
 phase text not null default 'BORRADOR',
 created_at timestamptz not null default now(),
 check((program='SA' and folio like 'TITAN-TEST-SA-%') or (program='PRENATAL' and folio like 'TITAN-TEST-PN-%') or (program='SC' and folio like 'TITAN-TEST-SC-%') or (program='INFANCIA' and folio like 'TITAN-TEST-IN-%'))
);
create table edith_core.titan_link_v1(
 parent_folio text references edith_core.titan_episode_v1(folio),
 child_folio text references edith_core.titan_episode_v1(folio),
 relation text not null check(relation in ('SA_EMBARAZO','EMBARAZO_PRODUCTO','CONTINUIDAD_INFANTIL')),
 reviewed boolean not null default false,
 primary key(parent_folio,child_folio,relation),check(parent_folio<>child_folio)
);
create function edith_core.titan_link_guard_v1() returns trigger
language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
declare p text;c text;
begin
 select program into p from titan_episode_v1 where folio=new.parent_folio;
 select program into c from titan_episode_v1 where folio=new.child_folio;
 if not coalesce((p,c,new.relation) in (('SA','PRENATAL','SA_EMBARAZO'),('PRENATAL','SC','EMBARAZO_PRODUCTO'),('SC','INFANCIA','CONTINUIDAD_INFANTIL')),false) then raise exception 'Invalid program relationship' using errcode='23514';end if;
 return new;
end $$;
create trigger titan_link_guard before insert or update on edith_core.titan_link_v1 for each row execute function edith_core.titan_link_guard_v1();
create table edith_core.titan_task_v1(
 task_id text primary key check(task_id~'^TITAN-TASK-[0-9]{3}$'),
 folio text not null references edith_core.titan_episode_v1(folio),
 rule_id text not null,rule_version text not null default '0.1-draft',
 owner text not null,applicable boolean,
 unit text,amount int,anchor_date date,anchor_at timestamptz,
 complete_date date,complete_at timestamptz,
 evidence_ref text check(evidence_ref is null or evidence_ref~'^SYN-EVID-[0-9]{3}$'),
 check((complete_date is null and complete_at is null) or evidence_ref is not null)
);
create table edith_core.titan_handoff_v1(
 from_folio text not null references edith_core.titan_episode_v1(folio),
 to_folio text not null references edith_core.titan_episode_v1(folio),
 referred_at timestamptz not null,
 received_at timestamptz,first_visit_at timestamptz,
 specialist_followup_open boolean not null default true,
 primary key(from_folio,to_folio),
 check(received_at is null or received_at>=referred_at),
 check(first_visit_at is null or (received_at is not null and first_visit_at>=received_at))
);
create function edith_core.titan_handoff_guard_v1() returns trigger
language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
begin
 if not exists(select 1 from titan_link_v1 where parent_folio=new.from_folio and child_folio=new.to_folio and relation='CONTINUIDAD_INFANTIL' and reviewed) then raise exception 'Reviewed continuity link required' using errcode='23514';end if;
 return new;
end $$;
create trigger titan_handoff_guard before insert or update on edith_core.titan_handoff_v1 for each row execute function edith_core.titan_handoff_guard_v1();
alter table edith_core.titan_episode_v1 enable row level security;
alter table edith_core.titan_link_v1 enable row level security;
alter table edith_core.titan_task_v1 enable row level security;
alter table edith_core.titan_handoff_v1 enable row level security;
revoke all on all tables in schema edith_core from public,anon,authenticated;
revoke all on all functions in schema edith_core from public,anon,authenticated;
insert into edith_core.titan_episode_v1(folio,program,district,phase) values
 ('TITAN-TEST-SA-001','SA','DS01','SEGUIMIENTO'),('TITAN-TEST-SA-002','SA','DS02','BORRADOR'),
 ('TITAN-TEST-PN-001','PRENATAL','DS01','SEGUIMIENTO'),('TITAN-TEST-PN-002','PRENATAL','DS03','BORRADOR'),
 ('TITAN-TEST-SC-001','SC','DS01','SEGUIMIENTO'),('TITAN-TEST-SC-002','SC','DS01','INVESTIGACION'),
 ('TITAN-TEST-SC-003','SC','DS04','BORRADOR'),('TITAN-TEST-IN-001','INFANCIA','DS01','REFERIDO'),
 ('TITAN-TEST-IN-002','INFANCIA','DS01','RECIBIDO');
insert into edith_core.titan_link_v1 values
 ('TITAN-TEST-SA-001','TITAN-TEST-PN-001','SA_EMBARAZO',true),
 ('TITAN-TEST-PN-001','TITAN-TEST-SC-001','EMBARAZO_PRODUCTO',true),
 ('TITAN-TEST-PN-001','TITAN-TEST-SC-002','EMBARAZO_PRODUCTO',true),
 ('TITAN-TEST-SC-001','TITAN-TEST-IN-001','CONTINUIDAD_INFANTIL',true),
 ('TITAN-TEST-SC-002','TITAN-TEST-IN-002','CONTINUIDAD_INFANTIL',true);
insert into edith_core.titan_handoff_v1 values
 ('TITAN-TEST-SC-001','TITAN-TEST-IN-001','2026-11-20T10:00-07',null,null,true),
 ('TITAN-TEST-SC-002','TITAN-TEST-IN-002','2026-11-20T10:00-07','2026-11-21T10:00-07',null,true);
insert into edith_core.titan_task_v1(task_id,folio,rule_id,owner,applicable,unit,amount,anchor_date,anchor_at,complete_date,complete_at,evidence_ref) values
 ('TITAN-TASK-001','TITAN-TEST-SC-001','SC-NOT-24H','EPIDEMIOLOGIA',true,'hours',24,null,'2026-11-23T10:00-07',null,'2026-11-24T09:00-07','SYN-EVID-001'),
 ('TITAN-TASK-002','TITAN-TEST-SC-002','SC-NOT-24H','EPIDEMIOLOGIA',true,'hours',24,null,'2026-11-23T10:00-07',null,null,null),
 ('TITAN-TASK-003','TITAN-TEST-SC-003','SC-NOT-24H','EPIDEMIOLOGIA',true,'hours',24,'2026-11-25',null,null,null,null),
 ('TITAN-TASK-004','TITAN-TEST-SC-001','SC-LAB-15D','EPIDEMIOLOGIA',true,'calendar_days',15,'2026-11-12',null,null,null,null),
 ('TITAN-TASK-005','TITAN-TEST-SC-002','SC-DICT-31D','EPIDEMIOLOGIA',false,'calendar_days',31,'2026-11-10',null,null,null,null),
 ('TITAN-TASK-006','TITAN-TEST-SA-001','SA-PRIMARY-SECONDARY-FU','TRATANTE',true,'calendar_months',3,'2026-09-30',null,null,null,null),
 ('TITAN-TASK-007','TITAN-TEST-PN-001','PREN-POSTPARTUM-FU','TRATANTE',true,'calendar_months',3,'2026-08-25',null,null,null,null),
 ('TITAN-TASK-008','TITAN-TEST-PN-002','PREN-POS-REF','PRENATAL',null,null,null,null,null,null,null,null),
 ('TITAN-TASK-009','TITAN-TEST-SC-001','SC-CHILD-FU','PEDIATRIA',true,'calendar_months',2,'2026-09-20',null,'2026-11-23',null,'SYN-EVID-009'),
 ('TITAN-TASK-010','TITAN-TEST-IN-001','SC-HANDOFF','INFANCIA',true,null,null,null,null,null,null,null),
 ('TITAN-TASK-011','TITAN-TEST-SA-002','SA-SUIVE','EPIDEMIOLOGIA',true,null,null,null,null,null,null,null);
create function edith_core.titan_queue_v1(as_of timestamptz)
returns table(task_id text,folio text,program text,district text,rule_id text,owner text,result jsonb)
language sql stable security invoker set search_path=pg_catalog,edith_core as $$
 select t.task_id,t.folio,e.program,e.district,t.rule_id,t.owner,titan_clock_v1(t.applicable,t.unit,t.amount,t.anchor_date,t.anchor_at,t.complete_date,t.complete_at,as_of,2)
 from titan_task_v1 t join titan_episode_v1 e using(folio) order by t.task_id;
$$;
revoke all on function edith_core.titan_queue_v1(timestamptz) from public,anon,authenticated;
comment on table edith_core.titan_episode_v1 is 'SYNTHETIC ONLY. Partial capture does not imply official notification.';
comment on function edith_core.titan_clock_v1(boolean,text,integer,date,timestamptz,date,timestamptz,timestamptz,integer) is 'Draft rules simulator; not an approved clinical protocol. Month-end uses PostgreSQL calendar arithmetic.';
