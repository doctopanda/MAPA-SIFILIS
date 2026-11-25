begin;
do $$
declare f text:='CORE-TEST-001'; a jsonb; k uuid:='00000000-0000-4000-8000-000000000001';
begin
 a:=edith_core.advance_synthetic_v1(f,0,'NOTIFICADO','CONSULTOR_ESTATAL',k); if a->>'status'<>'TRANSITION_DENIED' then raise exception 'consultor write';end if;
 a:=edith_core.advance_synthetic_v1(f,0,'NOTIFICADO','ALIMENTADOR_DISTRITAL',k); if a->>'status'<>'APPLIED' then raise exception 'notification';end if;
 a:=edith_core.advance_synthetic_v1(f,0,'NOTIFICADO','ALIMENTADOR_DISTRITAL',k); if a->>'status'<>'REPLAY' then raise exception 'replay';end if;
 a:=edith_core.advance_synthetic_v1(f,0,'INVESTIGACION','ALIMENTADOR_DISTRITAL',k); if a->>'status'<>'REQUEST_KEY_CONFLICT' then raise exception 'key collision';end if;
 a:=edith_core.advance_synthetic_v1(f,0,'INVESTIGACION','ALIMENTADOR_DISTRITAL','00000000-0000-4000-8000-000000000002'); if a->>'status'<>'VERSION_CONFLICT' then raise exception 'stale version';end if;
 a:=edith_core.advance_synthetic_v1(f,1,'INVESTIGACION','ALIMENTADOR_DISTRITAL','00000000-0000-4000-8000-000000000002'); if a->>'status'<>'APPLIED' then raise exception 'investigation';end if;
 a:=edith_core.advance_synthetic_v1(f,2,'REVISION_ESTATAL','ALIMENTADOR_DISTRITAL','00000000-0000-4000-8000-000000000003'); if a->>'status'<>'APPLIED' then raise exception 'submission';end if;
 a:=edith_core.advance_synthetic_v1(f,3,'CLASIFICADO','ALIMENTADOR_DISTRITAL','00000000-0000-4000-8000-000000000004'); if a->>'status'<>'TRANSITION_DENIED' then raise exception 'district approval';end if;
 a:=edith_core.advance_synthetic_v1(f,3,'DEVUELTO','ADMINISTRADOR_ESTATAL','00000000-0000-4000-8000-000000000004'); if a->>'status'<>'APPLIED' then raise exception 'return';end if;
 a:=edith_core.advance_synthetic_v1(f,4,'INVESTIGACION','ALIMENTADOR_DISTRITAL','00000000-0000-4000-8000-000000000005'); if a->>'status'<>'APPLIED' then raise exception 'resubmit investigation';end if;
 a:=edith_core.advance_synthetic_v1(f,5,'REVISION_ESTATAL','ALIMENTADOR_DISTRITAL','00000000-0000-4000-8000-000000000006'); if a->>'status'<>'APPLIED' then raise exception 'resubmission';end if;
 a:=edith_core.advance_synthetic_v1(f,6,'CLASIFICADO','ADMINISTRADOR_ESTATAL','00000000-0000-4000-8000-000000000007'); if a->>'status'<>'APPLIED' then raise exception 'state approve';end if;
 a:=edith_core.advance_synthetic_v1(f,7,'CERRADO','ADMINISTRADOR_ESTATAL','00000000-0000-4000-8000-000000000008'); if a->>'status'<>'APPLIED' then raise exception 'closure';end if;
 if (select count(*) from edith_core.workflow_event_v1 where folio=f)<>8 then raise exception 'event count';end if;
 if not exists(select 1 from edith_core.workflow_v1 where folio=f and state='CERRADO' and version=8) then raise exception 'final state';end if;
 if has_function_privilege('authenticated','edith_core.advance_synthetic_v1(text,bigint,text,text,uuid)','EXECUTE') then raise exception 'unsafe grant';end if;
end $$;
select 16 as checks_passed,'PASS' as result;
rollback;