-- PRENATAL v0.2, private synthetic staging. Preserve previous tables and interface.
-- NOM-007-SSA2-2016 5.2.1.3.2: FUM + 280 days. Clinical selection is explicit.
create function edith_core.prenatal_dating_v1(fum date,fum_reliable boolean,scan_date date,scan_age_days int,selected_method text,as_of date)
returns jsonb language plpgsql immutable security invoker set search_path=pg_catalog as $$
declare base date; n int;
begin
 if as_of is null then return jsonb_build_object('status','NO_CALCULABLE');end if;
 if selected_method='FUM' then
  if fum is null or fum_reliable is distinct from true then return jsonb_build_object('status','FUM_NO_VALIDADA');end if;
  base:=fum;
 elsif selected_method='USG_VALIDADO' then
  if scan_date is null or scan_age_days is null or scan_age_days not between 0 and 315 or scan_date>as_of then return jsonb_build_object('status','USG_NO_VALIDADO');end if;
  base:=scan_date-scan_age_days;
 else return jsonb_build_object('status','METODO_PENDIENTE');end if;
 n:=as_of-base;
 if n<0 then return jsonb_build_object('status','CRONOLOGIA_INVALIDA');end if;
 if n>315 then return jsonb_build_object('status','REVISION_CLINICA');end if;
 return jsonb_build_object('status','ESTIMACION','method',selected_method,'weeks',n/7,'days',n%7,'estimated_due_date',base+280,'as_of',as_of);
end $$;
create function edith_core.prenatal_age_v1(birth date,as_of date)
returns int language sql immutable security invoker set search_path=pg_catalog as $$
 select case when birth is null or as_of is null or birth>as_of then null else extract(year from age(as_of,birth))::int end;
$$;
-- Existing pregnancy and event data are not rewritten. Add version columns for optimistic locking.
alter table edith_core.prenatal_pregnancy_v1 add column revision bigint not null default 0 check(revision>=0);
alter table edith_core.prenatal_event_v1 add column revision bigint not null default 0 check(revision>=0);
create table edith_core.prenatal_capture_audit_v1(
 request_id uuid primary key, folio text not null references edith_core.prenatal_pregnancy_v1,
 target_key text not null, expected_revision bigint not null, new_revision bigint not null,
 patch jsonb not null, recorded_at timestamptz not null default now(),
 check(new_revision=expected_revision+1),check(jsonb_typeof(patch)='object')
);
alter table edith_core.prenatal_capture_audit_v1 enable row level security;
-- Merge patch keys only; explicit JSON null preserved, never replace an entire record silently.
create function edith_core.prenatal_save_patch_v1(p_folio text,p_target text,p_revision bigint,p_patch jsonb,p_request uuid)
returns jsonb language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
declare oldrow prenatal_capture_audit_v1%rowtype; current_revision bigint; affected int; new_rev bigint;
begin
 if p_request is null or p_revision is null or p_revision<0 or jsonb_typeof(p_patch) is distinct from 'object' then return jsonb_build_object('status','INVALID_REQUEST');end if;
 perform pg_advisory_xact_lock(hashtextextended(p_request::text,38));
 select * into oldrow from prenatal_capture_audit_v1 where request_id=p_request;
 if found then
  if (oldrow.folio,oldrow.target_key,oldrow.expected_revision,oldrow.patch) is distinct from (p_folio,p_target,p_revision,p_patch) then return jsonb_build_object('status','REQUEST_CONFLICT');end if;
  return jsonb_build_object('status','REPLAY','revision',oldrow.new_revision);
 end if;
 if p_target=p_folio then
  select revision into current_revision from prenatal_pregnancy_v1 where folio=p_folio for update;
 elsif p_target like 'PN-TEST-EVT-%' then
  select revision into current_revision from prenatal_event_v1 where folio=p_folio and event_key=p_target for update;
 else return jsonb_build_object('status','UNKNOWN_TARGET');end if;
 if not found then return jsonb_build_object('status','UNKNOWN_TARGET');end if;
 if current_revision<>p_revision then return jsonb_build_object('status','VERSION_CONFLICT','revision',current_revision);end if;
 if p_patch='{}'::jsonb then return jsonb_build_object('status','NO_CHANGE','revision',current_revision);end if;
 new_rev:=current_revision+1;
 if p_target=p_folio then update prenatal_pregnancy_v1 set data=data||p_patch,revision=new_rev where folio=p_folio;
 else update prenatal_event_v1 set data=data||p_patch,revision=new_rev where folio=p_folio and event_key=p_target;end if;
 get diagnostics affected=row_count;
 if affected<>1 then raise exception 'Atomic capture update failed';end if;
 insert into prenatal_capture_audit_v1(request_id,folio,target_key,expected_revision,new_revision,patch) values(p_request,p_folio,p_target,p_revision,new_rev,p_patch);
 return jsonb_build_object('status','SAVED','revision',new_rev);
end $$;
-- Reviewed adapter: raw test codes must not automatically classify or create an SA case.
create table edith_core.prenatal_review_v1(
 event_key text primary key,folio text not null,
 decision text not null check(decision in ('EVALUACION_PENDIENTE','REFERENCIA_INDICADA','SIN_REFERENCIA_POR_AHORA')),
 evidence_ref text not null check(evidence_ref~'^SYN-EVID-[0-9]{3}$'),
 reviewed_at timestamptz not null, reviewed_revision bigint not null check(reviewed_revision>=0),
 foreign key(event_key,folio) references edith_core.prenatal_event_v1(event_key,folio)
);
alter table edith_core.prenatal_review_v1 enable row level security;
create function edith_core.prenatal_review_guard_v1() returns trigger
language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
begin
 if not exists(select 1 from prenatal_event_v1 e where e.event_key=new.event_key and e.folio=new.folio and e.group_id='detecciones' and e.revision=new.reviewed_revision) then raise exception 'Reviewed detection and matching revision required' using errcode='23514';end if;
 return new;
end $$;
create trigger prenatal_review_guard before insert or update on edith_core.prenatal_review_v1 for each row execute function edith_core.prenatal_review_guard_v1();
create function edith_core.prenatal_bridge_queue_v1()
returns table(folio text,event_key text,status text,evidence_ref text)
language sql stable security invoker set search_path=pg_catalog,edith_core as $$
 select e.folio,e.event_key,case when r.event_key is null then 'PENDIENTE_REVISION' when r.reviewed_revision<>e.revision then 'REVALIDAR_CAMBIO' else r.decision end,
 case when r.reviewed_revision=e.revision then r.evidence_ref else null end
 from prenatal_event_v1 e left join prenatal_review_v1 r using(event_key,folio)
 where e.group_id='detecciones' order by e.event_key;
$$;
revoke all on all tables in schema edith_core from public,anon,authenticated;
revoke all on all functions in schema edith_core from public,anon,authenticated;
comment on function edith_core.prenatal_dating_v1(date,boolean,date,int,text,date) is 'Estimate only, explicit selected method; never overwrites recorded FPP or auto-selects clinical dating.';
comment on table edith_core.prenatal_capture_audit_v1 is 'Private synthetic patches only; production audit data minimization and access controls must be approved.';
