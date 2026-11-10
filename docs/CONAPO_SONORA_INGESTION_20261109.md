# PLAN CONAPO · Normalización demográfica para panoramas EDITH-SC

**Fecha:** 2026-11-09. **Estado:** fuente oficial localizada; cifras municipales aún no incorporadas ni verificadas.

## Fuentes primarias
- CONAPO: Reconstrucción y proyecciones de la población de los municipios de México 1990–2040:
  https://www.gob.mx/conapo/documentos/reconstruccion-y-proyecciones-de-la-poblacion-de-los-municipios-de-mexico-1990-2040
- Datos abiertos del Gobierno de México (CSV nacional): https://www.datos.gob.mx/dataset/proyecciones-de-poblacion/resource/3c3092be-583e-4490-8c23-67ef9a64b198
- COESPO Sonora, fuente metodológica y descargas: https://coespo.sonora.gob.mx/informacion-institucional/indicadores/proyecciones-de-poblacion

## Reglas de ingestión
1. Obtener el fichero oficial y registrar URL exacta, versión, fecha de descarga, huella SHA-256 y columnas originales.
2. Filtrar entidad 26 (Sonora), y años 2024, 2025, 2026; tratar código municipal como texto de tres dígitos; validar **72 municipios únicos por año** y su correspondencia con INEGI/crosswalk.
3. Usar la población **a mitad del año** si está disponible; validar que sexo Total no se duplique con Hombres/Mujeres y que los grupos de edad no generen doble conteo. Conservar grupos quinquenales y sexo opcionales para futuras pirámides.
4. No aceptar ceros inesperados, nulos, municipios no homologados ni variaciones de revisión sin informe de diferencias. Comprobar totales contra publicación oficial.
5. Publicar sólo agregados municipales sin datos personales y metadatos de procedencia. Derivar población distrital de los 72 municipios **sólo después** de homologar el catálogo distrital vigente.
6. Para regiones IMSS-Bienestar, no sumar ni publicar población ni tasas hasta validar oficialmente el cruce municipio–región de Sonora y las excepciones por localidad/unidad.
7. **Jamás usar población CONAPO como denominador de incidencia de sífilis congénita**, que requiere nacidos vivos y numerador de casos congruentes en territorio, definición y periodo. CONAPO será contexto demográfico o denominador de indicadores de población general apropiados.
8. Antes de fusionar a producción, añadir pruebas de 216 celdas municipio–año, cobertura de 6 DS, coherencia de sexos, cero duplicados, metadatos de corte y visualización `N/D` cuando falten datos.

**Estado actual de la interfaz:** tarjetas municipal, distrital y regional muestran `N/D` CONAPO porque no se han validado cifras originales. No reemplazar por números reconstruidos desde fuentes secundarias sin cotejo.
