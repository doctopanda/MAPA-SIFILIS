begin;
do $$
declare n timestamptz:='2026-11-25T12:00-07';e timestamptz:='2026-11-25T12:05-07';s text[]:=array['SUMMARY','DIARY'];
begin
 if edith_core.gesta_code_model_v1(n,e,'ISSUED',0,true,true,true,true)<>'PENDING_PATIENT_CONFIRMATION' then raise exception 'correct code only pending';end if;
 if edith_core.gesta_code_model_v1(n,e,'ISSUED',0,false,true,true,true)<>'DENIED_RECORD_ATTEMPT' then raise exception 'wrong code';end if;
 if edith_core.gesta_code_model_v1(n,e,'ISSUED',5,true,true,true,true)<>'DENIED' then raise exception 'attempt limit';end if;
 if edith_core.gesta_code_model_v1(e,e,'ISSUED',0,true,true,true,true)<>'DENIED' then raise exception 'exact expiry';end if;
 if edith_core.gesta_code_model_v1(n,e,'CONSUMED',0,true,true,true,true)<>'DENIED' then raise exception 'replay';end if;
 if edith_core.gesta_code_model_v1(n,e,'ISSUED',0,true,false,true,true)<>'DENIED' then raise exception 'unverified provider';end if;
 if edith_core.gesta_code_model_v1(n,e,'ISSUED',0,true,true,true,false)<>'DENIED' then raise exception 'aal1';end if;
 if edith_core.gesta_code_model_v1(n,e,'ISSUED',0,true,true,false,true)<>'DENIED' then raise exception 'session';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,'P1','P1','S1','S1','SUMMARY',s,true,true)<>'ALLOW_SYNTHETIC_READ' then raise exception 'approved';end if;
 if edith_core.gesta_access_model_v1('PENDING',n,e,null,true,true,true,'P1','P1','S1','S1','SUMMARY',s,true,true)<>'DENIED' then raise exception 'pending';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,'P2','P1','S1','S1','SUMMARY',s,true,true)<>'DENIED' then raise exception 'different provider';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,'P1','P1','S2','S1','SUMMARY',s,true,true)<>'DENIED' then raise exception 'different session';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,'P1','P1','S1','S1','LAB_REPORTS',s,true,true)<>'DENIED' then raise exception 'scope';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,'P1','P1','S1','S1','WRITE',array['WRITE'],true,true)<>'DENIED' then raise exception 'read only';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,n,true,true,true,'P1','P1','S1','S1','SUMMARY',s,true,true)<>'DENIED' then raise exception 'revoked';end if;
 if edith_core.gesta_access_model_v1('APPROVED',e,e,null,true,true,true,'P1','P1','S1','S1','SUMMARY',s,true,true)<>'DENIED' then raise exception 'expired';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,'P1','P1','S1','S1','SUMMARY',s,false,true)<>'DENIED' then raise exception 'no consent';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,'P1','P1','S1','S1','SUMMARY',s,true,false)<>'DENIED' then raise exception 'unit scope';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,null,'P1','P1','S1','S1','SUMMARY',s,true,true)<>'DENIED' then raise exception 'null aal2';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,null,null,'S1','S1','SUMMARY',s,true,true)<>'DENIED' then raise exception 'null identity';end if;
 if edith_core.gesta_access_model_v1('APPROVED',n,e,null,true,true,true,'P1','P1','S1','S1','SUMMARY',null,true,true)<>'DENIED' then raise exception 'null scope';end if;
 if has_function_privilege('authenticated','edith_core.gesta_access_model_v1(text,timestamptz,timestamptz,timestamptz,boolean,boolean,boolean,text,text,text,text,text,text[],boolean,boolean)','EXECUTE') or has_function_privilege('anon','edith_core.gesta_code_model_v1(timestamptz,timestamptz,text,integer,boolean,boolean,boolean,boolean)','EXECUTE') then raise exception 'public functions';end if;
end $$;
select 22 as checks_passed,'PASS' as result;
rollback;