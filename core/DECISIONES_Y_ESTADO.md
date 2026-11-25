# EDITH CORE v2 — checkpoint de laboratorio
## Implementado
- Normalización de clasificación, fechas estrictas, 14 reglas de revisión, oportunidad paramétrica y máquina de estados propuesta.
- 24 folios ficticios, tres años, seis distritos, duplicidad sintética, semanas inválidas y fechas inconsistentes.
- Dos cortes reproducibles con cierre matemático; historial privado y bloqueo transaccional.
- Flujo de seguimiento sintético con control de versión, idempotencia, rechazo de roles de lectura y bitácora transaccional.
- 64 comprobaciones ejecutadas en STAGING: 12 clasificación + 32 calidad, reglas y permisos + 16 flujo + 4 cortes. Prueba adicional RLS sin identidad/MFA: cero filas. No equivale a una certificación de todos los perfiles.
- Laboratorio HTML offline (core/lab/index.html), filtro por año, CSV y JSON sintéticos. Sintaxis comprobada; pendiente prueba de navegador.
- Runner PostgreSQL desechable y CI restringida a la rama de desarrollo. No usa credenciales institucionales.
- HTTP 403: se identificó que loadData consultaba tablas nominales sin GRANT SELECT. En rama de desarrollo se sustituyeron por proyecciones existentes bajo RLS, sin modificar permisos. Pendiente prueba en sesión real y promoción.
- Los Workers de producción y staging conservan sus despliegues previos. No se modificó Supabase producción.

## Bloqueos de decisión / promoción
1. Validación institucional de clasificación (incluida zona gris), criterio de caso y origen de las etiquetas. No reclasificar registros automáticamente.
2. Carátula DGE: confirmar versión oficial autorizada, diccionario de campos, obligatoriedad por etapa, valores y política de importación; no liberar captura real hasta validar.
3. Oportunidad: confirmar instantes de inicio y fin, manejo de hora ausente, zona horaria, días naturales vs hábiles. El motor de prueba utiliza horas transcurridas; 15 días=360 horas solo como supuesto técnico.
4. Flujo: aprobar transiciones, actores, requisitos de cierre, reapertura, conciliación y control de versiones. El simulador no es una frontera de seguridad productiva.
5. Duplicados: definir identidad autorizada y reglas de coincidencia; nunca fusionar sin revisión. La prueba actual usa identificadores ficticios.
6. Permisos: completar RLS con sesiones reales y MFA, crear cuenta sintética de consultor en staging por flujo de alta autorizado; no falsificar sesiones. No publicar celdas institucionales en GitHub Pages.
7. Agregados: definir frecuencia y contrato de fuente institucional; probar refresco con datos sintéticos antes de automatizar producción. Mapas actuales conservan fuentes históricas.
8. Validar descargas y paridad en navegador; aprobar promoción después de pruebas end-to-end.
9. Revisar aviso de contraseña filtrada y RLS sin política; no cambiar configuración de autenticación por inferencia.
10. Tratamientos: validar las guías aplicables y revisión clínica antes de precargar dosis o automatizar recomendaciones.

## Principios
Producción congelada; cambios de base solo en STAGING. No copiar datos reales a GitHub, laboratorio o STAGING. No compras, no migración productiva, no aprobación clínica simulada. Las pruebas de funciones son pruebas técnicas, no validación clínica.
