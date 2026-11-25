-- EDITH CORE · read-only production audit; run as authorized administrator.
-- Returns statewide annual aggregates only. Do not publish the results.
with canon as (
 select source_year, count(*) as records, count(distinct case_uid) as distinct_uid,
 count(*) filter(where case_uid is null or trim(case_uid)='') as missing_uid,
 count(*) filter(where district_id is null) as missing_district,
 count(*) filter(where epidemiological_week is null or epidemiological_week not between 1 and 53) as invalid_week
 from public.edith_sc_cases where not is_deleted group by source_year
), safe as (
 select source_year, upper(regexp_replace(trim(coalesce(clinical_payload->>'CLAS_FINAL','')),'[[:space:]]+',' ','g')) as label
 from public.edith_sc_cases_safe_v1 where not is_deleted
), categorized as (
 select source_year, case when label like 'CONFIRM%' or label='CONF LESP' then 'CONFIRMADO'
 when label like 'DESC%' or label like 'NEG ZONA GRIS%' then 'DESCARTADO'
 when label like '%ZONA GRIS%' then 'ZONA GRIS' else 'SIN CLASIFICAR' end as category
 from safe
), annual as (
 select source_year,count(*) as analytical_records,
 count(*) filter(where category='CONFIRMADO') as confirmed,
 count(*) filter(where category='DESCARTADO') as discarded,
 count(*) filter(where category='ZONA GRIS') as gray,
 count(*) filter(where category='SIN CLASIFICAR') as pending
 from categorized group by source_year
)
select source_year,canon.records,annual.analytical_records,distinct_uid,missing_uid,missing_district,invalid_week,confirmed,discarded,gray,pending,
 canon.records=annual.analytical_records as count_match,
 annual.analytical_records=confirmed+discarded+gray+pending as classification_closes
 from canon full join annual using(source_year) order by source_year;