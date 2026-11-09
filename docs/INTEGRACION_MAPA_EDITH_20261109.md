# Integración MAPA-SÍFILIS → EDITH ÚNICA (2026-11-09)

## Alcance de esta propuesta
- `cloudflare-pages/mapa/index.html` es el mismo visor público de `/index.html` del repositorio (mismo blob Git), sin alterar ni reemplazar la versión de GitHub Pages.
- `cloudflare-pages/mapa/data/` contiene copias idénticas de los archivos agregados públicos existentes en `data/`, incluyendo el histórico comprimido. No se deben colocar datos nominales, secretos ni geocodificaciones individuales en este directorio.
- En `cloudflare-pages/index.html`, EDITH incorpora una pestaña **MAPA-SÍFILIS · Visor** y un acceso desde **Panorama territorial**. El visor se presenta en un iframe de **mismo origen**, dentro de Cloudflare Workers assets.
- `/captura/` y `/biblioteca/` permanecen sin cambios. No se modificaron tablas, auth ni políticas de Supabase.
- La rama es independiente; el cambio necesita revisión y fusión después del trabajo paralelo en la carátula.

## Lectura correcta de cifras
El MAPA-SÍFILIS incrustado utiliza **cortes públicos estáticos** previamente publicados. EDITH consulta métricas agregadas en Supabase mediante autenticación y RLS. No son la misma extracción, ni los filtros se sincronizan en esta entrega. No se debe mostrar el corte público como "en vivo" o usarlo para resolver discordancias contra el conteo institucional.

Se mantiene la diferencia epidemiológica entre **residencia materna**, **municipio de nacimiento** y **flujo obstétrico**. La incidencia sólo puede calcularse con numerador y denominador del mismo periodo, ámbito y definición. La política de supresión de celdas de 1–4 sigue siendo obligatoria para el mapa público.

## Pruebas antes de fusionar y desplegar
1. Abrir `/mapa/` y comprobar que se carga Leaflet, el GeoJSON municipal, las capas y los datos 2024, 2025 y 2026; revisar solicitudes fallidas a CDN, OpenStreetMap y fuente externa de polígonos.
2. Comprobar que las 36 rutas nuevas `cloudflare-pages/mapa/` se sirven en la implementación de prueba, incluido `data/history/*.json.gz`; verificar si Cloudflare entrega .gz sin descompresión automática adicional.
3. Entrar a EDITH con un usuario de prueba autorizado y abrir **MAPA-SÍFILIS**; usar Recargar, Pantalla completa y acceder desde Panorama territorial.
4. Probar escritorio, celular, y que la carátula, biblioteca, login, importación y controles RLS existentes continúan.
5. Verificar que `/data/`, `/README.md` y demás archivos ajenos a `cloudflare-pages` **no** se expongan en el Worker.
6. Confirmar la supresión de celdas pequeñas y que los JSON públicos no contienen información nominal.
7. No fusionar esta rama hasta conciliar cambios paralelos recientes en `cloudflare-pages/index.html` y evitar resolver conflictos sobrescribiendo la carátula.

## Evolución siguiente
La integración **en tiempo real** requerirá una vista/RPC de agregación territorial autorizada por rol, probada con RLS, cortes versionados y supresión de celdas pequeñas incluso ante diferencias entre filtros. No se reemplazará el mapa público por lecturas nominales desde el navegador.

## Sincronización futura del mapa
Al actualizar `/index.html` o `data/` en el repositorio, sus copias bajo `cloudflare-pages/mapa/` deben actualizarse en el mismo cambio: la copia de esta rama no se sincroniza automáticamente. Priorizar una rutina de construcción reproducible antes de nuevas publicaciones.
