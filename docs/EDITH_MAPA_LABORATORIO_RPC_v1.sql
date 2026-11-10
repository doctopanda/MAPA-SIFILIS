-- MAPA-SÍFILIS: contrato institucional de clasificación final con criterio de laboratorio.
-- IMPLEMENTADA EN SUPABASE EDITH (2026-11-09); comprobar QA por rol antes de liberar UI a main.
-- No equivale a positividad aislada de VDRL, ni sustituye dictaminación clínica.
-- Conserva RLS de edith_sc_cases (SECURITY INVOKER) y autorización por perfil.
create or replace function public.edith_sc_mapa_laboratorio_v1()
returns jsonb
language sql stable security invoker
set search_path = ''
as $$
with perfil as materialized (
 select p.role::text rol,p.district_id
 from public.edith_sc_profiles p
 where p.user_id=(select auth.uid()) and p.active=true
   and p.role::text in ('ALIMENTADOR_DISTRITAL','ADMINISTRADOR_ESTATAL','ADMINISTRADOR_MAESTRO')
),
catalogo as materialized (
 select distinct d.municipality_code, d.municipality_name
 from public.edith_birth_denominators d
 where d.source_year=2026 and d.municipality_code~'^[0-9]{3}$'
),
base as materialized (
 select c.source_year::int anio, m.municipality_code,
  upper(trim(coalesce(c.payload->>'CLAS_FINAL',''))) in
   ('CONFIRMADO LESP','CONFIRMADO POR LABORATORIO','CONFIRMADO POR WESTERN BLOT') as lab_criteria
 from public.edith_sc_cases c
 cross join perfil p
 join catalogo m on m.municipality_name=public.edith_sc_canonical_municipality(c.municipality)
 where c.is_deleted=false and c.source_year in (2024,2025,2026)
  and (p.rol in ('ADMINISTRADOR_ESTATAL','ADMINISTRADOR_MAESTRO')
       or (p.rol='ALIMENTADOR_DISTRITAL' and p.district_id=c.district_id))
),
agregado as (
 select anio, municipality_code,count(*)::int total,
 count(*) filter(where lab_criteria)::int lab_confirmed
 from base group by anio,municipality_code
),
safe as (
 select anio,municipality_code,
   case when total>=5 and lab_confirmed not between 1 and 4
     and (total-lab_confirmed) not between 1 and 4 then lab_confirmed else null end lab_confirmed,
   case when total<5 or lab_confirmed between 1 and 4
     or (total-lab_confirmed) between 1 and 4 then true else false end suppressed
 from agregado
)
select jsonb_build_object(
 'schema','EDITH_SC_MAPA_LAB_CLASS_RLS_V1',
 'definition','CLAS_FINAL_CONFIRMADO_LESP_LABORATORIO_WESTERN_BLOT',
 'interpretation','Clasificación final con criterio de laboratorio; no prueba individual validada',
 'source','edith_sc_cases',
 'geography','MUNICIPIO_RESIDENCIA',
 'suppression_threshold',5,
 'scope',(select rol from perfil limit 1),
 'generated_at',current_timestamp,
 'rows',coalesce((select jsonb_agg(jsonb_build_object(
 'year',anio,'municipality_code',municipality_code,
 'lab_confirmed',lab_confirmed,'suppressed',suppressed
 ) order by anio,municipality_code) from safe),'[]'::jsonb)
) where exists(select 1 from perfil);
$$;
revoke all on function public.edith_sc_mapa_laboratorio_v1() from public, anon;
grant execute on function public.edith_sc_mapa_laboratorio_v1() to authenticated;

-- ESTADO DE VALIDACIÓN POSTIMPLEMENTACIÓN:
-- 1. APROBADO: SEC INVOKER, anon sin EXECUTE, authenticated con EXECUTE; sin auth.uid devuelve NULL.
-- 2. PARCIAL: catálogo 72 municipios; laboratorio 2024 32 en total y 31 homologables a municipio; 2025 13/13; 2026 11/11.
-- 3. PENDIENTE: QA con sesiones reales para supresión primaria 1–4 y secundaria de complementos 1–4.
-- 4. PARCIAL: total de clasificaciones CLAS_FINAL confirmado por lab 32/13/11; homologar definiciones por año.
-- 5. Validar respuesta en rol distrital, administrador estatal, maestro y pendiente.
