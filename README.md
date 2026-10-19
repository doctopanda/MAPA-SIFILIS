# MAPA-SIFILIS 🗺️🧬

Visor territorial epidemiológico para sífilis adquirida (EDITH SA) y sífilis congénita (EDITH SC) en Sonora.

## Objetivo

Representar territorialmente la concentración y distribución de sífilis adquirida y congénita mediante una sola arquitectura cartográfica, con navegación por:

- 6 Distritos de Salud de Sonora.
- 10 Regiones Operativas IMSS-Bienestar.
- Municipio.
- Capas epidemiológicas derivadas de EDITH SA y EDITH SC.

El repositorio público NO es una base nominal. GitHub Pages deberá recibir únicamente geometrías públicas y agregados epidemiológicos autorizados.

## Capas epidemiológicas previstas

### Sífilis adquirida
- Residencia del caso.
- Conteo de casos.
- Tasa, cuando exista denominador validado.
- Semana / periodo epidemiológico.
- Distrito de Salud.
- Región IMSS-Bienestar.
- Derechohabiencia agregada.

### Sífilis congénita
- Residencia de la madre como geografía epidemiológica principal.
- Lugar de nacimiento del recién nacido como capa independiente.
- Derechohabiencia de la madre / binomio en forma agregada.
- Conteo de casos.
- Indicador con denominador obstétrico validado cuando corresponda.
- Distrito de Salud.
- Región IMSS-Bienestar.

## Regla analítica

Nunca mezclar residencia materna con lugar de nacimiento.

Un caso de sífilis congénita puede pertenecer epidemiológicamente a un municipio/distrito por residencia de la madre y, al mismo tiempo, haber nacido en otra región por referencia obstétrica. Ambas dimensiones deben poder compararse.

Esto permitirá visualizar también flujos territoriales de referencia:
Residencia materna → lugar de nacimiento.

## Arquitectura

EDITH SA / EDITH SC
↓
Motor canónico de métricas
↓
Agregación territorial autorizada
↓
MAPA-SIFILIS

El mapa público no consulta tablas nominales directamente.

## Seguridad

No publicar:
- nombres;
- CURP;
- domicilios;
- coordenadas individuales;
- expedientes;
- fechas de nacimiento identificables;
- registros nominales;
- celdas pequeñas sin una política explícita de supresión.

La política de supresión de celdas pequeñas deberá definirse antes de publicar agregados reales.

## Estado

Fase 0: arquitectura territorial y contrato de capas.

- Distritos de Salud: heredados del esquema territorial usado en MAPA-BALAM.
- Regiones IMSS-Bienestar: se reconocen las 10 regiones operativas oficialmente reportadas para Sonora.
- Crosswalk municipio → Región IMSS-Bienestar: pendiente de validación documental; no se inferirá por nombre de cabecera.

## Fuentes de referencia

- Secretaría de Salud de Sonora / IMSS-Bienestar: 10 regiones operativas de conducción médica.
- MAPA-BALAM: lógica de distritos y separación entre cartografía pública y bases nominales.
