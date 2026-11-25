-- GESTA GUARDIAN: pure authorization model for SYNTHETIC STAGING.
-- This is NOT authentication, a code generator, a redemption endpoint or a real access grant.
-- Arguments are test assertions, never to be supplied as authorization claims by a client.
create function edith_core.gesta_access_model_v1(
 p_state text,p_now timestamptz,p_expiry timestamptz,p_revoked_at timestamptz,
 p_professional_verified boolean,p_live_session boolean,p_aal2 boolean,
 p_actor text,p_bound_actor text,p_session text,p_bound_session text,
 p_requested_scope text,p_allowed_scopes text[],p_patient_confirmed boolean,
 p_unit_authorized boolean
) returns text language sql immutable security invoker set search_path=pg_catalog as $$
 select case
 when p_state is distinct from 'APPROVED' then 'DENIED'
 when p_now is null or p_expiry is null or p_now>=p_expiry then 'DENIED'
 when p_revoked_at is not null then 'DENIED'
 when p_professional_verified is distinct from true or p_live_session is distinct from true or p_aal2 is distinct from true or p_patient_confirmed is distinct from true or p_unit_authorized is distinct from true then 'DENIED'
 when nullif(trim(p_actor),'') is null or p_actor is distinct from p_bound_actor then 'DENIED'
 when nullif(trim(p_session),'') is null or p_session is distinct from p_bound_session then 'DENIED'
 when p_requested_scope not in ('SUMMARY','DIARY','LAB_REPORTS','US_REPORTS') or p_requested_scope is null then 'DENIED'
 when (p_requested_scope=any(p_allowed_scopes)) is distinct from true then 'DENIED'
 else 'ALLOW_SYNTHETIC_READ' end;
$$;
create function edith_core.gesta_code_model_v1(
 p_now timestamptz,p_expiry timestamptz,p_state text,p_attempts integer,
 p_match boolean,p_professional_verified boolean,p_live_session boolean,p_aal2 boolean
) returns text language sql immutable security invoker set search_path=pg_catalog as $$
 select case when p_now is null or p_expiry is null or p_now>=p_expiry
 or p_state is distinct from 'ISSUED' or p_attempts is null or p_attempts<0 or p_attempts>=5
 or p_professional_verified is distinct from true or p_live_session is distinct from true or p_aal2 is distinct from true then 'DENIED'
 when p_match is distinct from true then 'DENIED_RECORD_ATTEMPT'
 else 'PENDING_PATIENT_CONFIRMATION' end;
$$;
revoke all on function edith_core.gesta_access_model_v1(text,timestamptz,timestamptz,timestamptz,boolean,boolean,boolean,text,text,text,text,text,text[],boolean,boolean) from public,anon,authenticated;
revoke all on function edith_core.gesta_code_model_v1(timestamptz,timestamptz,text,integer,boolean,boolean,boolean,boolean) from public,anon,authenticated;
comment on function edith_core.gesta_code_model_v1(timestamptz,timestamptz,text,integer,boolean,boolean,boolean,boolean) is 'Pure synthetic decision model. No code generation, verification, storage, attempt counters, sessions or grants. Never expose as API.';
