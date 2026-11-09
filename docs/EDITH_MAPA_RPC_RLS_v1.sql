-- Documentación de la migración aplicada en Supabase EDITH el 09-11-2026.
-- Nombre de la migración: edith_sc_mapa_territorial_rls_v1
-- Esta función se ejecuta con permisos del llamante; respeta RLS.
-- No se brindan totales estatales/distritales ni cortes parciales diferenciales.
create or replace function public.edith_sc_mapa_residencia_v1()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $fn$
with perfil as materialized (
 select p.role::text as rol, p.district_id
 from public.edith_sc_profiles p
 where p.user_id = (select auth.uid())
   and p.active = true
   and p.role::text in ('ALIMENTADOR_DISTRITAL','ADMINISTRADOR_ESTATAL','ADMINISTRADOR_MAESTRO')
),
base as materialized (
 select c.source_year::int as anio,
        public.edith_sc_canonical_municipality(c.municipality) as municipio
 from public.edith_sc_cases c
 cross join perfil p
 where c.is_deleted = false
   and c.source_year in (2024,2025,2026)
   and (p.rol in ('ADMINISTRADOR_ESTATAL','ADMINISTRADOR_MAESTRO')
        or (p.rol = 'ALIMENTADOR_DISTRITAL' and p.district_id = c.district_id))
),
agregado as (
 select b.anio, m.municipality_code as codigo, count(*)::int as total
 from base b
 join public.edith_sc_municipalities m on m.active and m.name = b.municipio
 group by b.anio, m.municipality_code
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
     'year',a.anio,
     'municipality_code',a.codigo,
     'cases',case when a.total>=5 then a.total else null end,
     'suppressed',a.total between 1 and 4
   ) order by a.anio,a.codigo) from agregado a
 ),'[]'::jsonb)
)
where exists(select 1 from perfil);
$fn$;
revoke all on function public.edith_sc_mapa_residencia_v1() from public,anon,authenticated;
grant execute on function public.edith_sc_mapa_residencia_v1() to authenticated;
comment on function public.edith_sc_mapa_residencia_v1()
 is 'EDITH SC: conteos municipales por año, bajo RLS; celdas 1–4 suprimidas; registros activos, no incidencia ni confirmados.';
