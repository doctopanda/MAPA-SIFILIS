# PRENATAL v0.2 · Sprint de integración 2026-11-25
- No cambios en producción ni despliegues Worker. STAGING privado y exclusivamente ficticio.
- 179 campos técnicos preliminares; 57 campos de catálogo pendientes de equivalencias oficiales. La copia del instructivo 2025 no sustituye el archivo original aprobado en Sonora.
- FUM + 280 días conforme NOM-007-SSA2-2016 5.2.1.3.2: https://www.dof.gob.mx/nota_detalle.php?codigo=5432289&fecha=07/04/2016 . USG: método explícitamente seleccionado por tratante, no sustitución automática; cálculo aritmético de prueba, no criterio de redatación clínica.
- Guardado parcial con versión, solicitud idempotente y auditoría privada; no es una API clínica. No se modifica la carátula original ni se eliminan campos.
- Puente de detecciones: revisión explícita vinculada a versión del evento, cambios invalidan revisión; no genera casos ni referencias automáticamente.
- Catálogo sintético: 3 unidades activas, búsqueda y filtros; producción reutiliza directorio edith_sc_health_units, sin duplicar ni cambiar datos. Adaptación a sesión y permisos aún pendiente.
- Planes sintéticos: autorización, actividades programadas por profesional y evidencia; no calcula medicamentos, dosis ni intervalos terapéuticos; falta de evidencia no prueba incumplimiento.
- Laboratorio ampliado core/lab/prenatal_v02.html, autónomo, en memoria, con datos ficticios estáticos; sintaxis JS comprobada, no prueba de navegador ni conexión a Supabase. La selección CLUES y la estimación se muestran como paneles de demostración, no persisten en la carátula.
- 47 comprobaciones nuevas (26 captura/estimación/puente, 9 catálogo, 12 tratamiento); 160 acumuladas en STAGING. CI de la revisión 23c5bfd: completed / success https://github.com/doctopanda/MAPA-SIFILIS/actions/runs/45703307552.
- Auditoría: 20/20 tablas edith_core con RLS, 0 con SELECT anon/authenticated. Avisos previos: RLS sin política y protección de contraseña filtrada. No equivalen a certificación de seguridad.
## Antes de piloto clínico
Obtener original 2025/2026, cotejar códigos y obligatoriedad, aprobar reglas obstétricas y terapéuticas, ajustar adaptador CLUES real, definir unidad/distrito y roles, probar API autenticada y MFA, revisión de auditoría, validar integración y UI. No activar tratamientos, alertas clínicas ni exportaciones oficiales hasta autorización. GESTASON y GESTAPP siguen en PIN.
