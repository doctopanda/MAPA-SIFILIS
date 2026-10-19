# Arquitectura territorial MAPA-SIFILIS

## 1. Dos programas, una cartografía

MAPA-SIFILIS consumirá dos productos canónicos:

- EDITH SA: sífilis adquirida.
- EDITH SC: sífilis congénita.

La cartografía será compartida. La semántica epidemiológica cambia según el programa.

## 2. Geografía principal

### SA
La unidad territorial principal es la residencia del caso.

### SC
La unidad territorial principal es la residencia de la madre.

El lugar de nacimiento del recién nacido es una dimensión diferente y debe mantenerse separada.

## 3. Capas territoriales

- Municipios.
- 6 Distritos de Salud.
- 10 Regiones Operativas IMSS-Bienestar.

La selección debe permitir alternar la misma métrica entre distintas regionalizaciones.

## 4. Derechohabiencia

La derechohabiencia no se cartografiará como ubicación individual.

Se representará mediante:
- composición porcentual por polígono;
- categoría dominante;
- conteos agregados;
- filtros cruzados con SA / SC.

## 5. Flujo obstétrico para SC

Se conservarán dos llaves independientes:

- territorio de residencia materna;
- territorio del lugar de nacimiento.

Esto habilita una capa de flujo origen → destino sin alterar la atribución epidemiológica del caso.

Ejemplo conceptual:

Municipio de residencia de la madre → municipio/hospital de nacimiento.

## 6. Contrato mínimo que EDITH debe exportar

Cada fila agregada destinada al mapa deberá contener:

- program: SA | SC
- period_start
- period_end
- epidemiological_week_from
- epidemiological_week_to
- year
- geography_type
- geography_id
- metric_id
- numerator
- denominator, cuando aplique
- value
- source_system
- source_cut_date
- calculation_version

Para derechohabiencia:
- rightsholder_category
- category_count
- eligible_total

Para flujo SC:
- origin_geography_id
- destination_geography_id
- flow_count

## 7. Trazabilidad

Todo valor visible en el mapa deberá poder explicar:

- qué significa;
- numerador;
- denominador;
- fórmula;
- periodo;
- fuente;
- versión del cálculo.

La apertura de registros nominales deberá ocurrir dentro de EDITH según permisos, nunca desde GitHub Pages.

## 8. Crosswalk territorial operativo

El crosswalk de los 72 municipios hacia las 10 Regiones Operativas IMSS-Bienestar ya está cargado en `data/municipality_region_crosswalk.json` con la distribución proporcionada por el responsable del proyecto.

Cada municipio conserva dos llaves simultáneas: Distrito de Salud y Región IMSS-Bienestar. No se fusionan ambas regionalizaciones; el visor debe permitir alternarlas y comparar resultados.

La matriz de traslape se encuentra en `data/region_district_matrix.json`.
