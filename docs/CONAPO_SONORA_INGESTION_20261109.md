# PLAN CONAPO · Normalización demográfica para panoramas EDITH-SC

**Fecha:** 2026-11-09. **Estado:** CONAPO incorporado en Preview; 72 municipios × 3 años, con desglose sexo y totales validados. No liberado a main.

## Fuentes primarias
- CONAPO: Reconstrucción y proyecciones de la población de los municipios de México 1990–2040:
  https://www.gob.mx/conapo/documentos/reconstruccion-y-proyecciones-de-la-poblacion-de-los-municipios-de-mexico-1990-2040
- Datos abiertos del Gobierno de México (CSV nacional): https://www.datos.gob.mx/dataset/proyecciones-de-poblacion/resource/3c3092be-583e-4490-8c23-67ef9a64b198
- COESPO Sonora, fuente metodológica y descargas: https://coespo.sonora.gob.mx/informacion-institucional/indicadores/proyecciones-de-poblacion

## Reglas de ingestión
1. **Fuente ya utilizada:** réplica CSV versionada de la base CONAPO 2024 (población a mitad de año) en `lapanquecita/poblacion-estimada/poblacion_municipal/{total,hombres,mujeres}.csv`. Se registraron hashes de blobs de GitHub para las tres tablas y URL primaria de CONAPO. **Pendiente como control adicional:** cotejo SHA-256 con descarga primaria directa del portal oficial, actualmente no disponible en este entorno.
2. **Completado:** entidad 26, años 2024–2026, claves de tres dígitos y 72 municipios únicos por año, conciliados con el crosswalk territorial del mapa.
3. **Completado:** población **a mitad del año**, Total = Hombres + Mujeres por municipio/año (216 combinaciones); grupos quinquenales de edad pendientes para fase de pirámides.
4. **Completado:** no se aceptan ceros, nulos, municipios ajenos ni sexos inconsistentes. Totales estatales: 2024 **3,111,704**, 2025 **3,140,762**, 2026 **3,168,624**. El cotejo uno a uno contra la descarga primaria oficial continúa pendiente.
5. **Completado en la rama de pruebas:** `cloudflare-pages/mapa/data/conapo_sonora_2024_2026.json` público con agregados y metadatos, sin datos personales. La población distrital se deriva de los seis distritos ya validados del proyecto.
6. Para regiones IMSS-Bienestar, no sumar ni publicar población ni tasas hasta validar oficialmente el cruce municipio–región de Sonora y las excepciones por localidad/unidad.
7. **Jamás usar población CONAPO como denominador de incidencia de sífilis congénita**, que requiere nacidos vivos y numerador de casos congruentes en territorio, definición y periodo. CONAPO será contexto demográfico o denominador de indicadores de población general apropiados.
8. **Implementado en CI:** prueba de 216 celdas municipio–año, 72 códigos, coherencia de sexos, sumas estatales y visualización con muestra conocida de Hermosillo. Sigue pendiente QA de roles institucionales reales antes de producción.

**Estado actual de la interfaz:** municipal y distrital muestran CONAPO validado con fuente derivada verificable; regional muestra `N/D` por adscripción operativa provisional. Las tasas de sífilis congénita **no usan CONAPO** como denominador. Los datos no se han importado a la tabla `edith_population_conapo` en Supabase, que permanece vacía; la integración de Preview utiliza un JSON público controlado.
