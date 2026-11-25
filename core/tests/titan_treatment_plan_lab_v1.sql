begin;
do $$
declare a timestamptz:='2026-11-25T12:00-07';bad boolean;
begin
 if (select count(*) from edith_core.titan_plan_queue_v1(a))<>5 then raise exception 'queue size';end if;
 if (select status from edith_core.titan_plan_queue_v1(a) where item_key='ITEM-TEST-001')<>'REALIZADA_DOCUMENTADA' then raise exception 'evidence';end if;
 if (select status from edith_core.titan_plan_queue_v1(a) where item_key='ITEM-TEST-002')<>'SIN_EVIDENCIA_VENCIDA' then raise exception 'missing documentation';end if;
 if (select status from edith_core.titan_plan_queue_v1(a) where item_key='ITEM-TEST-003')<>'PROXIMA' then raise exception 'next activity';end if;
 if (select status from edith_core.titan_plan_queue_v1(a) where item_key='ITEM-TEST-004')<>'SIN_FECHA' then raise exception 'no date';end if;
 if (select status from edith_core.titan_plan_queue_v1(a) where item_key='ITEM-TEST-005')<>'PLAN_NO_ACTIVO' then raise exception 'draft no alerts';end if;
 bad:=false;begin insert into edith_core.titan_plan_evidence_v1 values('ITEM-TEST-005',a,a,'SYN-EVID-203');exception when check_violation then bad:=true;end;if not bad then raise exception 'draft evidence';end if;
 bad:=false;begin insert into edith_core.titan_plan_evidence_v1 values('ITEM-TEST-002','2026-10-31T12:00-07',a,'SYN-EVID-203');exception when check_violation then bad:=true;end;if not bad then raise exception 'before authorization';end if;
 bad:=false;begin insert into edith_core.titan_plan_v1 values('PLAN-TEST-003','TITAN-TEST-PN-001',2,'AUTORIZADO','SYN-PROTOCOL-DEMO','SYN-EVID-203',a);exception when unique_violation then bad:=true;end;if not bad then raise exception 'two active plans';end if;
 bad:=false;begin insert into edith_core.titan_plan_v1 values('PLAN-TEST-003','TITAN-TEST-SA-001',1,'AUTORIZADO','SYN-PROTOCOL-DEMO',null,null);exception when check_violation then bad:=true;end;if not bad then raise exception 'authorization evidence';end if;
 if (select status from edith_core.titan_plan_queue_v1('2026-11-02T10:30-07') where item_key='ITEM-TEST-001')='REALIZADA_DOCUMENTADA' then raise exception 'future evidence leakage';end if;
 if has_function_privilege('authenticated','edith_core.titan_plan_queue_v1(timestamptz)','EXECUTE') or has_table_privilege('anon','edith_core.titan_plan_v1','SELECT') then raise exception 'permissions';end if;
end $$;
select 12 as checks_passed,'PASS' as result;
rollback;