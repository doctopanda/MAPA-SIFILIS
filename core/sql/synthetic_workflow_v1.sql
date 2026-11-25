-- Prototype of the lifecycle. Private synthetic sandbox, never an application authorization boundary.
create table edith_core.workflow_v1 (
 folio text primary key references edith_core.fixture_v1(folio),
 state text not null default 'BORRADOR' check(state in ('BORRADOR','NOTIFICADO','INVESTIGACION','REVISION_ESTATAL','DEVUELTO','CLASIFICADO','CERRADO')),
 version bigint not null default 0 check(version>=0)
);
create table edith_core.workflow_event_v1 (
 event_id bigint generated always as identity primary key,
 request_key uuid not null unique,
 folio text not null references edith_core.workflow_v1(folio),
 old_state text not null, new_state text not null,
 test_role text not null, old_version bigint not null, new_version bigint not null,
 event_at timestamptz not null default now(),
 unique(folio,new_version),
 check(new_version=old_version+1)
);
alter table edith_core.workflow_v1 enable row level security;
alter table edith_core.workflow_event_v1 enable row level security;
revoke all on all tables in schema edith_core from public,anon,authenticated;
revoke all on all sequences in schema edith_core from public,anon,authenticated;
insert into edith_core.workflow_v1(folio) select folio from edith_core.fixture_v1;
create function edith_core.advance_synthetic_v1(p_folio text,p_expected_version bigint,p_new_state text,p_test_role text,p_request_key uuid)
returns jsonb language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
declare w workflow_v1%rowtype; e workflow_event_v1%rowtype;
begin
 if p_request_key is null then return jsonb_build_object('status','INVALID_REQUEST'); end if;
 perform pg_advisory_xact_lock(hashtextextended(p_request_key::text,20261125));
 select * into e from workflow_event_v1 where request_key=p_request_key;
 if found then
  if (e.folio,e.old_version,e.new_state,e.test_role) is distinct from (p_folio,p_expected_version,p_new_state,p_test_role) then return jsonb_build_object('status','REQUEST_KEY_CONFLICT'); end if;
  return jsonb_build_object('status','REPLAY','version',e.new_version,'state',e.new_state);
 end if;
 select * into w from workflow_v1 where folio=p_folio for update;
 if not found then return jsonb_build_object('status','UNKNOWN_FIXTURE'); end if;
 if w.version is distinct from p_expected_version then return jsonb_build_object('status','VERSION_CONFLICT','version',w.version); end if;
 if not transition_v1(w.state,p_new_state,p_test_role) then return jsonb_build_object('status','TRANSITION_DENIED'); end if;
 insert into workflow_event_v1(request_key,folio,old_state,new_state,test_role,old_version,new_version)
 values(p_request_key,w.folio,w.state,p_new_state,p_test_role,w.version,w.version+1);
 update workflow_v1 set state=p_new_state,version=w.version+1 where folio=w.folio;
 return jsonb_build_object('status','APPLIED','state',p_new_state,'version',w.version+1);
end $$;
revoke all on function edith_core.advance_synthetic_v1(text,bigint,text,text,uuid) from public,anon,authenticated;
comment on function edith_core.advance_synthetic_v1(text,bigint,text,text,uuid) is 'Test harness only. Role input is simulated; production must derive authenticated role and district server-side and validate all release gates.';
