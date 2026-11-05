# EDITH NEXT · integración con MAPA-SIFILIS

Esta carpeta aloja **únicamente una vista previa pública** de la evolución visual de EDITH SC v1.3.2 hacia una red integrada de programas e instituciones.

## Separación obligatoria
- **Privado**: EDITH SC operativa, datos nominales, sesiones, perfiles y solicitudes protegidos por Supabase Auth + RLS.
- **Público**: maqueta de navegación sin datos, enlace al mapa, documentos sin datos identificables y agregados autorizados.
- La app original v1.3.2 contenía un snapshot comprimido de casos en el propio HTML: **jamás subir esa versión sin saneamiento y evaluación de seguridad**.
- GitHub Pages no ofrece control de acceso para proteger el contenido del código fuente.

## Programas
Sífilis congénita: base operativa existente. Sífilis adquirida: tabla existente en Supabase, integración por definir. VIH y hepatitis C: espacios planificados. Unidades y nacimientos: catálogos y denominadores existentes, pendientes de un contrato de integración.

## Consistencia analítica
Una sola definición canónica por universo, fecha y nivel geográfico; numeradores y denominadores alineados; hash/revisión del corte y auditoría. Mantener Chart.js sin destrucción en actualizaciones del mismo tipo. La aplicación clínica aún no tiene eventos Realtime habilitados en `supabase_realtime`; el polling de cambios requiere comprobaciones y QA.

## Estado
Vista previa v0.1 integrada al repositorio, no un sistema clínico desplegado. Todos los accesos, roles y funciones adicionales requieren diseño y prueba.