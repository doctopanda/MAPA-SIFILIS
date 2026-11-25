begin;
do $$
declare bad boolean;
begin
 if (select count(*) from edith_core.prenatal_field_v1)<>179 then raise exception 'dictionary count';end if;
 if (select count(distinct group_id) from edith_core.prenatal_field_v1)<>24 then raise exception 'section count';end if;
 if (select count(*) from edith_core.prenatal_pregnancy_v1 where person_key='PN-TEST-PER-001')<>2 then raise exception 'repeat pregnancies';end if;
 if (select count(*) from edith_core.prenatal_pregnancy_v1 where data='{}')<>2 then raise exception 'partial data';end if;
 if (select count(*) from edith_core.prenatal_event_v1 where folio='PN-TEST-EMB-001' and group_id='citas')<>2 then raise exception 'repeat visits';end if;
 if (select count(*) from edith_core.prenatal_product_v1 where event_key='PN-TEST-EVT-004')<>2 then raise exception 'multiple products';end if;
 if not exists(select 1 from edith_core.prenatal_event_v1 where data->'detecciones.resultado_deteccion'='null'::jsonb and event_date is null) then raise exception 'null distinct';end if;
 if not exists(select 1 from edith_core.prenatal_event_v1 where data->'puerperio.plan_seguridad'='false'::jsonb) then raise exception 'false distinct';end if;
 bad:=false;begin update edith_core.prenatal_pregnancy_v1 set data='{"unknown":1}' where folio='PN-TEST-EMB-002';exception when check_violation then bad:=true;end;if not bad then raise exception 'unknown field';end if;
 bad:=false;begin update edith_core.prenatal_pregnancy_v1 set data='{"citas.peso_kg":70}' where folio='PN-TEST-EMB-002';exception when check_violation then bad:=true;end;if not bad then raise exception 'scope';end if;
 bad:=false;begin update edith_core.prenatal_event_v1 set data='{"puerperio.peso_kg":70}' where event_key='PN-TEST-EVT-001';exception when check_violation then bad:=true;end;if not bad then raise exception 'wrong group';end if;
 bad:=false;begin update edith_core.prenatal_pregnancy_v1 set data='{"gineco.gestas":1.5}' where folio='PN-TEST-EMB-002';exception when check_violation then bad:=true;end;if not bad then raise exception 'integer';end if;
 bad:=false;begin update edith_core.prenatal_pregnancy_v1 set data='{"ingreso.fum":"2026-02-30"}' where folio='PN-TEST-EMB-002';exception when check_violation then bad:=true;end;if not bad then raise exception 'date';end if;
 bad:=false;begin update edith_core.prenatal_event_v1 set data='{"citas.peso_kg":"70"}' where event_key='PN-TEST-EVT-001';exception when check_violation then bad:=true;end;if not bad then raise exception 'type';end if;
 bad:=false;begin update edith_core.prenatal_event_v1 set data='{"citas.signos_alarma":[5]}' where event_key='PN-TEST-EVT-001';exception when check_violation then bad:=true;end;if not bad then raise exception 'array type';end if;
 bad:=false;begin insert into edith_core.prenatal_product_v1 values('PN-TEST-RN-003','PN-TEST-EVT-001','PN-TEST-EMB-001',1,'{}');exception when check_violation then bad:=true;end;if not bad then raise exception 'wrong event';end if;
 bad:=false;begin insert into edith_core.prenatal_product_v1 values('PN-TEST-RN-003','PN-TEST-EVT-004','PN-TEST-EMB-002',1,'{}');exception when check_violation or foreign_key_violation then bad:=true;end;if not bad then raise exception 'cross pregnancy';end if;
 bad:=false;begin insert into edith_core.prenatal_product_v1 values('PN-TEST-RN-003','PN-TEST-EVT-004','PN-TEST-EMB-001',1,'{}');exception when unique_violation then bad:=true;end;if not bad then raise exception 'duplicate product';end if;
 if has_schema_privilege('anon','edith_core','USAGE') or has_schema_privilege('authenticated','edith_core','USAGE') then raise exception 'schema exposed';end if;
 if exists(select 1 from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='edith_core' and c.relname like 'prenatal_%' and c.relkind='r' and (not c.relrowsecurity or has_table_privilege('authenticated',c.oid,'SELECT') or has_table_privilege('anon',c.oid,'SELECT'))) then raise exception 'table access';end if;
end $$;
select 20 as checks_passed,'PASS' as result;
rollback;