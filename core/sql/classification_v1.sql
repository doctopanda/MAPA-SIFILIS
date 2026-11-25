-- EDITH CORE: pure classification normalization, no data access.
create schema edith_core;
revoke all on schema edith_core from public, anon, authenticated;
create function edith_core.classify_v1(raw_label text)
returns text language sql immutable parallel safe security invoker set search_path = pg_catalog
as $$
 select case
   when label like 'CONFIRM%' or label='CONF LESP' then 'CONFIRMADO'
   when label like 'DESC%' or label like 'NEG ZONA GRIS%' then 'DESCARTADO'
   when label like '%ZONA GRIS%' then 'ZONA GRIS'
   else 'SIN CLASIFICAR'
 end from (select upper(regexp_replace(trim(coalesce(raw_label,'')), '[[:space:]]+', ' ', 'g')) label) q;
$$;
revoke all on function edith_core.classify_v1(text) from public, anon, authenticated;
comment on function edith_core.classify_v1(text) is 'EDITH CORE v2 alpha: reproduces legacy panorama classification; descriptive, pending epidemiological validation. No patient data access.';
