-- Revisión de puente RLS MAPA-SÍFILIS: mapear municipio por catálogo de nacidos vivos.
-- PENDIENTE DE VALIDACIÓN DE ROL Y AUTORIZACIÓN PARA APLICAR A SUPABASE ACTIVO.
-- El catálogo edith_sc_municipalities actualmente está vacío; el de nacimientos tiene 72 municipios.
create or replace function public.edith_sc_mapa_residencia_v1()
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
 select distinct municipality_code,municipality_name
 from public.edith_birth_denominators
 where source_year=2026 and municipality_code~'^[0-9]{3}$'
),
base as materialized (
 select c.source_year::int anio,public.edith_sc_canonical_municipality(c.municipality) municipio
 from public.edith_sc_cases c
 cross join perfil p
 where c.is_deleted=false and c.source_year in (2024,2025,2026)
   and (p.rol in ('ADMINISTRADOR_ESTATAL','ADMINISTRADOR_MAESTRO')
      or (p.rol='ALIMENTADOR_DISTRITAL' and p.district_id=c.district_id))
),
agregado as (
 select b.anio,m.municipality_code codigo,count(*)::int total
 from base b
 join catalogo m on m.municipality_name=b.municipio
 group by b.anio,m.municipality_code
)
select jsonb_build_object(
 'schema','EDITH_SC_MAPA_RLS_V1',
 'source','edith_sc_cases',
 'case_definition','REGISTROS_ACTIVOS_NO_CASOS_CONFIRMADOS',
 'geography','MUNICIPIO_RESIDENCIA',
 'years',jsonb_build_array(2024,2025,2026),
 'generated_at',current_timestamp,
 'scope',(select rol from perfil limit 1),
 'suppression_threshold',5,
 'rows',coalesce((
   select jsonb_agg(jsonb_build_object(
      'year',a.anio,'municipality_code',a.codigo,
      'cases',case when a.total>=5 then a.total else null end,
      'suppressed',a.total between 1 and 4
    ) order by a.anio,a.codigo)
   from agregado a),'[]'::jsonb)
) where exists(select 1 from perfil);
$$;
revoke all on function public.edith_sc_mapa_residencia_v1() from public,anon;
grant execute on function public.edith_sc_mapa_residencia_v1() to authenticated;
-- Revisar 23 registros con residencia no asignable a código municipal (5 en 2024, 17 en 2025 y 1 en 2026).
-- No inventar municipio ni reasignarlos para forzar un total estatal.
-- Verificar SELECT RLS, cobertura de catálogo, roles y supresión antes del despliegue.
