begin;
do $$
declare bad boolean;
begin
 if (select count(*) from edith_core.prenatal_unit_search_v1(null,null,null,null))<>3 then raise exception 'active';end if;
 if (select count(*) from edith_core.prenatal_unit_search_v1('uno',null,null,null))<>1 then raise exception 'name';end if;
 if (select count(*) from edith_core.prenatal_unit_search_v1('test-clues-003',null,null,null))<>1 then raise exception 'clues';end if;
 if (select count(*) from edith_core.prenatal_unit_search_v1(null,'DS01','TEST-INSTITUCION-A','TEST-MUNICIPIO-A'))<>1 then raise exception 'filters';end if;
 if (select count(*) from edith_core.prenatal_unit_search_v1('%',null,null,null))<>0 then raise exception 'literal search';end if;
 insert into edith_core.prenatal_unit_assignment_v1(folio,unit_key) values('PN-TEST-EMB-001','UNIT-TEST-001');
 if (select count(*) from edith_core.prenatal_unit_assignment_v1)<>1 then raise exception 'assignment';end if;
 bad:=false;begin update edith_core.prenatal_unit_assignment_v1 set unit_key='UNIT-TEST-003' where folio='PN-TEST-EMB-001';exception when check_violation then bad:=true;end;if not bad then raise exception 'district';end if;
 bad:=false;begin update edith_core.prenatal_unit_assignment_v1 set unit_key='UNIT-TEST-004' where folio='PN-TEST-EMB-001';exception when check_violation then bad:=true;end;if not bad then raise exception 'inactive';end if;
 if has_function_privilege('authenticated','edith_core.prenatal_unit_search_v1(text,text,text,text)','EXECUTE') or has_table_privilege('anon','edith_core.prenatal_unit_fixture_v1','SELECT') then raise exception 'private adapter';end if;
end $$;
select 9 as checks_passed,'PASS' as result;
rollback;