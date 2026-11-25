-- CORE v2 alpha: pure validation helpers; no table or patient access.
create function edith_core.parse_date_v1(raw text) returns date
language plpgsql immutable security invoker set search_path=pg_catalog as $$
declare s text:=trim(coalesce(raw,'')); d date; p text[];
begin
 if s ~ '^\d{4}-\d{2}-\d{2}$' then
   if substring(s,1,4)::int not between 1900 and 2100 then return null; end if;
   return make_date(substring(s,1,4)::int,substring(s,6,2)::int,substring(s,9,2)::int);
 elsif s ~ '^\d{1,2}/\d{1,2}/\d{4}$' then
   p:=string_to_array(s,'/'); if p[3]::int not between 1900 and 2100 then return null; end if;
   return make_date(p[3]::int,p[2]::int,p[1]::int);
 elsif s ~ '^\d{5}$' and s::int between 35000 and 65000 then
   return date '1899-12-30'+s::int;
 end if;
 return null;
exception when datetime_field_overflow or invalid_datetime_format or numeric_value_out_of_range or invalid_text_representation then return null;
end $$;
create function edith_core.quality_v1(p_year int,p_week int,p_district text,p_payload jsonb)
returns table(code text,severity text) language sql immutable security invoker set search_path=pg_catalog,edith_core as $$
 with n as(select parse_date_v1(p_payload->>'FECHA_NOTIFICACION') nt,
 parse_date_v1(p_payload->>'FECHA_INICIO_ESTUDIO') st,parse_date_v1(p_payload->>'FECHA_TERMINACION_ESTUDIO') en,
 classify_v1(p_payload->>'CLAS_FINAL') cl)
 select v.code,v.severity from n cross join lateral(values
 ('YEAR_INVALID','ERROR',p_year is null or p_year not between 1900 and 2100),
 ('WEEK_INVALID','REVIEW',p_week is null or p_week not between 1 and 53),
 ('DISTRICT_MISSING','ERROR',nullif(trim(p_district),'') is null),
 ('NOTIFICATION_DATE_MISSING','REVIEW',nullif(trim(p_payload->>'FECHA_NOTIFICACION'),'') is null),
 ('NOTIFICATION_DATE_INVALID','ERROR',nullif(trim(p_payload->>'FECHA_NOTIFICACION'),'') is not null and nt is null),
 ('STUDY_START_INVALID','ERROR',nullif(trim(p_payload->>'FECHA_INICIO_ESTUDIO'),'') is not null and st is null),
 ('STUDY_END_INVALID','ERROR',nullif(trim(p_payload->>'FECHA_TERMINACION_ESTUDIO'),'') is not null and en is null),
 ('STUDY_END_BEFORE_START','ERROR',en<st),
 ('STUDY_START_BEFORE_NOTIFICATION','REVIEW',st<nt),
 ('NOTIFICATION_YEAR_DIFFERS','REVIEW',extract(year from nt)<>p_year),
 ('CLASSIFICATION_PENDING','REVIEW',cl='SIN CLASIFICAR'),
 ('CLASSIFICATION_GRAY','REVIEW',cl='ZONA GRIS'),
 ('FINAL_WITHOUT_STUDY_END','REVIEW',cl in ('CONFIRMADO','DESCARTADO') and en is null),
 ('CLASSIFICATION_LAB_REVIEW','REVIEW',cl='CONFIRMADO' and upper(trim(coalesce(p_payload->>'EDITH_VIA_CLASIFICACION','')))='LABORATORIO' and nullif(trim(p_payload->>'VDRL'),'') is null and nullif(trim(p_payload->>'RPR'),'') is null and nullif(trim(p_payload->>'WESTERN_IGM'),'') is null)
 ) v(code,severity,flag) where v.flag is true;
$$;
create function edith_core.opportunity_v1(start_at timestamptz,end_at timestamptz,limit_hours numeric)
returns jsonb language sql immutable security invoker set search_path=pg_catalog as $$
 select case when limit_hours is null or limit_hours<=0 then jsonb_build_object('status','INVALID_THRESHOLD')
 when start_at is null or end_at is null then jsonb_build_object('status','NO_CALCULABLE')
 when end_at<start_at then jsonb_build_object('status','CHRONOLOGY_INVALID')
 else jsonb_build_object('status',case when extract(epoch from end_at-start_at)/3600<=limit_hours then 'WITHIN_LIMIT' else 'OUTSIDE_LIMIT' end,'hours',extract(epoch from end_at-start_at)/3600) end;
$$;
create function edith_core.transition_v1(old_state text,new_state text,actor_role text)
returns boolean language sql immutable security invoker set search_path=pg_catalog as $$
 select coalesce(case when actor_role in ('PENDIENTE','CONSULTOR_ESTATAL') then false
 when actor_role in ('ALIMENTADOR_DISTRITAL','ADMINISTRADOR_ESTATAL','ADMINISTRADOR_MAESTRO') and (old_state,new_state) in (('BORRADOR','NOTIFICADO'),('NOTIFICADO','INVESTIGACION'),('INVESTIGACION','REVISION_ESTATAL'),('DEVUELTO','INVESTIGACION')) then true
 when actor_role in ('ADMINISTRADOR_ESTATAL','ADMINISTRADOR_MAESTRO') and (old_state,new_state) in (('REVISION_ESTATAL','DEVUELTO'),('REVISION_ESTATAL','CLASIFICADO'),('CLASIFICADO','CERRADO'),('CERRADO','REVISION_ESTATAL')) then true
 else false end,false);
$$;
revoke all on all functions in schema edith_core from public,anon,authenticated;
comment on function edith_core.transition_v1(text,text,text) is 'Proposed transition rules; pure function, never an authorization boundary. Requires institutional approval, session and scope checks before clinical use.';
comment on function edith_core.quality_v1(int,int,text,jsonb) is 'Review flags only; no case modification or inference of official classification.';
