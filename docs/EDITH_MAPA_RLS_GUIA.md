# Puente autenticado EDITH-SC ↔ MAPA-SÍFILIS (v1, 09-11-2026)

## Estado
RPC `public.edith_sc_mapa_residencia_v1()` creada mediante migración en el proyecto Supabase **EDIT SC**. El código SQL de referencia está en `docs/EDITH_MAPA_RPC_RLS_v1.sql`.

La rama GitHub agrega el puente frontend en `cloudflare-pages/index.html` y una capa de lectura autorizada en `cloudflare-pages/mapa/index.html`. **No está fusionada ni desplegada en Cloudflare** al momento de redactar esta nota.

## Flujo de datos
1. EDITH inicia sesión institucional mediante Supabase Auth, con credenciales de un usuario activo.
2. El parent EDITH llama a la RPC sin argumentos, con token en memoria. Consulta periódica cada 120 s únicamente si el módulo está visible, o al pulsar el botón de actualización.
3. La función `SECURITY INVOKER` lee `edith_sc_cases` con RLS, coteja el perfil autorizado y aplica alcance estatal o distrital. Normaliza municipios con catálogo EDITH.
4. Devuelve **solamente año de fuente, clave municipal y recuento permitido**. Si hay 1 a 4 registros, marca `suppressed=true` y `cases=null`. Sin totales por distrito, estado, semana ni clasificación. Sin información personal.
5. La página EDITH remite la respuesta por `postMessage` a su único iframe cartográfico del mismo origen, tras validar `origin` y `source`. **Jamás transmite el token**, cookies, claves o expedientes.
6. El mapa muestra por defecto el agregado autorizado tras recibir la primera consulta, con opción de volver al corte público estático; al abrir el visor público en otra pestaña no se transfiere la sesión.

## Advertencias analíticas y de privacidad
- Las cifras son **registros activos**, no automáticamente confirmados, casos incidentes o incidencia. `source_year` es el año de fuente, no fecha de notificación ni de nacimiento.
- El universo puede crecer dentro del año; `generated_at` es fecha de consulta, no validación epidemiológica oficial.
- Los municipios no mapeables se excluyen del mapa, pero siguen en la base canónica. No interpretar municipios omitidos como cero casos confirmado.
- No sumar celdas visibles para declarar totales; existen celdas suprimidas y registros sin geografía.
- La rama preserva el mapa público y sus capas históricas. Los archivos replicados bajo `cloudflare-pages/mapa/data` requieren sincronización deliberada, no automática.

## Comprobaciones realizadas en Supabase
- Función `SECURITY INVOKER`, `search_path` fijado.
- `has_function_privilege('anon',...,'execute')=false`; `authenticated=true`.
- Sesión sin usuario retorna `null`.
- Prueba de consulta con perfil estatal autorizado: respuesta válida y sin celdas pequeñas expuestas.
- Prueba con perfil distrital activo: respuesta de perfil distrital y sin cifras pequeñas expuestas.
- Security Advisor revisado. Reporta alertas en otras funciones preexistentes; ninguna autoriza relajar la seguridad de esta RPC.

## QA requerido antes de pasar a producción
- Validar consulta funcional real en navegador con usuarios estatales y distritales y comprobar que las cifras correspondan a su universo RLS.
- Confirmar mapa sobre Cloudflare (/mapa/, GeoJSON, historia comprimida y CDN Leaflet).
- Verificar que al cambiar año / regresar a corte público no se mezclen datos o indicadores.
- Verificar comportamiento sin sesión, al salir de EDITH, con pestaña pública abierta y en celular.
- Auditar advertencias de seguridad preexistentes y nuevas; evitar tocar funciones antiguas sin revisión formal.
- Mantener la rama aislada de los cambios concurrentes de /captura/ y /biblioteca/ hasta resolver el PR.

## Evolución futura
La incidencia SC por 1,000 nacidos vivos, clasificación confirmada, flujos obstétricos y cortes subanuales deben mantenerse como fuentes separadas hasta disponer de numeradores/denominadores alineados y reglas de divulgación resistentes a ataques de diferenciación entre filtros.

## Cartografía municipal integrada
El visor utiliza `cloudflare-pages/mapa/data/sonora_municipios.geojson`, que contiene los 72 municipios de Sonora sin redondear coordenadas. Fuente: **INEGI, Marco Geoestadístico 2025**, distribuido por [MacWilliXD/INEGI-geojson](https://github.com/MacWilliXD/INEGI-geojson), archivo `geojson_descargas/AGEM_26.geojson`. Se conservan únicamente clave y nombre municipal junto con la geometría, sin atributos demográficos adicionales. El visor ya no depende de GitHub para descargar polígonos, aunque Leaflet y el fondo OpenStreetMap siguen requiriendo conexión.

El lector de históricos `.json.gz` detecta la firma de gzip antes de descomprimir para aceptar tanto bytes comprimidos como respuestas descomprimidas automáticamente por el navegador.
