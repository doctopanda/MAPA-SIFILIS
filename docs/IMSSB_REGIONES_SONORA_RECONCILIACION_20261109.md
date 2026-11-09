# MAPA-SÍFILIS · Reconciliación de las 10 regiones IMSS-Bienestar Sonora
**Fecha:** 2026-11-09 · **Carácter:** auditoría operativa del cruce municipal existente, NO publicación oficial de límites regionales.

## Afirmaciones que sí tienen respaldo externo
- IMSS-Bienestar enumera **10 regiones operativas de conducción médica**: San Luis Río Colorado, Caborca, Nogales, Moctezuma, Ures, Hermosillo, Guaymas, Ciudad Obregón, Navojoa y Huatabampo (comunicado 054/2025, 12-jul-2025).
- La Secretaría de Salud de Sonora también menciona 10 regiones, con la variante de nombre `Cajeme` para Ciudad Obregón.
- Un directorio de calidad de unidades médicas por región aporta evidencia de asignación de **unidades** a regiones, pero NO equivale automáticamente a una regionalización municipal oficial, sin solapamientos.

**Fuentes externas:**
- https://cdn.imssbienestar.gob.mx/ssib/assets/docs/notas_informativas/sala_prensa/148/20250712_imssbienestarinaugurahospitalcomunitarioviicamswitchquetraeraijusticiasocialensaludalpuebloyaqui.pdf
- https://www.sonora.gob.mx/gobierno/acciones/gobernador/gobernador-durazo-fortalece-atencion-medica-en-todo-el-estado-con-entrega-de-231-vehiculos-y-ambulancias-de-imss-bienestar
- https://sites.google.com/view/calidad-imss-bienestar-sonora/reporte-de-evidencias
- https://sites.google.com/view/planestrategica/clues

## Correspondencia municipio → región ACTUAL EN MAPA-SÍFILIS (provisional, 72 municipios)
El origen interno es `data/imss_bienestar_regions.json` y `data/municipality_region_crosswalk.json`; el archivo declara `operational_crosswalk_supplied_by_project_owner`, actualizado 2026-10-19. La integridad de claves no equivale a la validación sanitaria del territorio.

| ID | Región / nombre oficial habitual | Municipios asignados por el cruce del proyecto | N |
|---|---|---|---:|
| IB01 | San Luis Río Colorado | San Luis Río Colorado, Puerto Peñasco, General Plutarco Elías Calles | 3 |
| IB02 | Caborca | Caborca, Altar, Átil, Oquitoa, Pitiquito, Sáric, Trincheras, Tubutama | 8 |
| IB03 | Nogales | Nogales, Agua Prieta, Benjamín Hill, Cananea, Cucurpe, Fronteras, Ímuris, Magdalena, Naco, Santa Ana, Santa Cruz | 11 |
| IB04 | Moctezuma | Moctezuma, Bacadéhuachi, Bacerac, Bacoachi, Bavispe, Cumpas, Divisaderos, Granados, Huachinera, Huásabas, Nácori Chico, Nacozari de García, Tepache, Villa Hidalgo | 14 |
| IB05 | Ures | Ures, Aconchi, Arivechi, Arizpe, Bacanora, Banámichi, Baviácora, Huépac, Mazatán, Opodepe, Rayón, Sahuaripa, San Felipe de Jesús, San Pedro de la Cueva, Soyopa, Villa Pesqueira | 16 |
| IB06 | Hermosillo | Hermosillo, Carbó, La Colorada, San Miguel de Horcasitas | 4 |
| IB07 | Guaymas | Guaymas, Empalme, Ónavas, San Javier, Suaqui Grande | 5 |
| IB08 | Ciudad Obregón / Cajeme | Cajeme, Bácum, Quiriego, Rosario, San Ignacio Río Muerto, Yécora | 6 |
| IB09 | Navojoa | Navojoa, Álamos | 2 |
| IB10 | Huatabampo | Huatabampo, Benito Juárez, Etchojoa | 3 |
| | **TOTAL** | **72 municipios en correspondencia única provisional** | **72** |

## Hallazgos que impiden declarar oficial el cruce municipal
1. La lista municipal circulada en conversación asigna **Puerto Peñasco** a Caborca; el directorio de unidades médicas de Región 01 San Luis Río Colorado ubica allí el Hospital Integral de Puerto Peñasco y sus centros. El cruce actual del mapa sí lo ubica en IB01.
2. La lista circulada asigna **Agua Prieta** simultáneamente a Nogales y Moctezuma: imposible para una correspondencia municipal única si no se distinguen subterritorios o unidades.
3. El directorio de unidades Región 04 Moctezuma incluye centros de **Arivechi y Sahuaripa**, pero el cruce municipal actual los ubica en **IB05 Ures**.
4. El directorio de unidades Región 05 Ures incluye centro de **Bacoachi**, mientras que el cruce municipal actual ubica Bacoachi en **IB04 Moctezuma**.
5. El directorio de unidades Región 06 Hermosillo incluye centros de **Ónavas, San Javier y Suaqui Grande**; el cruce municipal actual los asigna a **IB07 Guaymas**.
6. El directorio Región 09 Navojoa incluye centro de **Etchojoa** y un centro urbano de **Villa Juárez**; el cruce actual asigna Etchojoa y Benito Juárez a **IB10 Huatabampo**.
7. El directorio registra unidades vinculadas a Región 07 Guaymas en localidades yaquis distribuidas en municipios colindantes. La región de una unidad o de referencia no implica automáticamente que todo el municipio pertenece a dicha región.
8. En la lista circulada faltan municipios y algunos aparecen en regiones diferentes. Evitar sustituir de forma automática un cruce de 72 códigos por un texto no exhaustivo.

## Reglas para Panorama regional IMSS-Bienestar
- Mantener por separado dos dimensiones:
  - `maternal_residence_municipality` → municipio por residencia; `analytic_imssb_region` únicamente con cruce municipal versionado y validado.
  - `health_unit_clues` → región de conducción de unidad médica, vía catálogo CLUES y su versión.
- No asignar una única región operativa de atención a una persona sólo por residencia sin validar la lógica de referencia.
- Etiquetar todo resultado agrupado por el cruce actual como **"Regionalización municipal operativa del proyecto; pendiente validación formal"**.
- No mover casos, cambiar denominadores ni calcular tasas regionales a partir de un mapeo no homologado.
- Cuando se apruebe un catálogo oficial, documentar emisor, vigencia, fecha, nombre/CLUES, municipio, relación con región y criterios de excepciones por localidad/unidad. Versionar el cambio y publicar un informe de diferencias antes de aplicar en producción.
- Los seis distritos de salud tienen catálogo independiente y no se redefinen por las diez regiones IMSS-Bienestar.

## Controles verificables hoy
- 10 regiones; 72 códigos municipales sin duplicados; correspondencia simétrica entre los dos JSON regionales.
- 6 distritos; 72 códigos distritales únicos.
- **Pendiente:** respaldo normativo/documental municipio→región que confirme cada una de las 72 asignaciones y tratamiento de excepciones.

**Decisión de seguridad:** no modificar ni la cartografía ni los conteos epidemiológicos hasta homologar el cruce.
