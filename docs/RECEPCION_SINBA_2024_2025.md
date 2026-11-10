# Preparación de carga SINBA 2024 y 2025 · EDITH-SC / MAPA-SÍFILIS

**Preparado:** 09-11-2026. **Estado:** a la espera de bases originales; no contiene datos de pacientes.

## Insumos aceptables
- Archivo .xlsx/.xls/.csv por año, con **nacidos vivos** y municipio de **residencia de la madre** (no municipio del hospital).
- Es imprescindible conocer **fecha inicial/final del corte**, año de referencia, fuente de extracción y reglas de exclusión.
- Si contiene información nominal, conservarla sólo en área institucional protegida; generar aquí agregados municipales ya validados. No subir nominales ni CURP a carpetas públicas de GitHub ni a `cloudflare-pages`.
- Para tasas comparables requerimos el mismo periodo del numerador: fecha de nacimiento y definición epidemiológica de sífilis congénita (nacidos vivos y mortinatos según norma), no mezclar notificaciones con fecha de nacimiento.

## Validaciones de recepción por año
1. Confirmar entidad 26 Sonora, 72 códigos municipales INEGI sin duplicados, municipio de residencia materna y fechas.
2. Separar residentes de ocurrencia; confirmar que los **residentes** sean el denominador epidemiológico esperado.
3. Identificar registros duplicados y distinguir nacidos vivos de nacimientos totales, defunciones fetales, traslados y correcciones.
4. Reportar registros sin municipio, municipio fuera de Sonora, nombres no homologados y diferencias en totales antes de asignarlos.
5. Validar agregados municipales con sumas independientes por 6 distritos y total estatal; conservar procedencia, fecha, versión y SHA-256.
6. No publicar tasas anuales con denominadores incompletos o de diferente periodo. Para 2026, el corte vigente SINBA es **2026-09-24** (19,690 nacidos vivos residentes).
7. No calcular ni etiquetar prevalencia de sífilis congénita simplemente dividiendo casos acumulados por población CONAPO.

## Modelo de almacenamiento propuesto
Para cada año, archivo agregado `births_municipal_YEAR.json` privado en su etapa de revisión, y sólo después de QA:
```json
{
  "schema": "EDITH_SINBA_BIRTHS_MUNICIPAL_V1",
  "year": 2025,
  "period": ["2025-01-01", "2025-12-31"],
  "geography": "residencia_materna",
  "source": "SINBA",
  "cut": "fecha y versión por confirmar",
  "rows": [{"c": "001", "r": null, "o": null}]
}
```
Los nulos del ejemplo son **marcadores**, nunca cifras. Los valores sólo se completarán desde datos validados.

## Integración y seguridad
- La tabla institucional `public.edith_birth_denominators` ya almacena 2026 y permite cortes versionados; incorporar 2024 y 2025 mediante operaciones controladas con registro de lote y bitácora, sin sobrescribir 2026.
- Revisar RLS por rol, permisos de captura y trazabilidad; no importar directamente desde la página pública.
- Para ficha epidemiológica: mostrar la fuente, año, corte y condición de año parcial o cerrado junto a cada tasa.
- Mantener **N/D** en incidencia cuando falte una definición de caso compatible, fechas alineadas o clasificación final válida.
- Continuar mostrando población CONAPO separada del denominador de nacidos vivos.

## Estado de laboratorio, 09-11-2026
- La RPC `edith_sc_mapa_laboratorio_v1()` se instaló con `SECURITY INVOKER`; la ejecución anónima fue revocada. Sin sesión de usuario devuelve NULL.
- Clasificación final con criterio laboratorial: 32 registros en 2024 (31 homologables territorialmente), 13 en 2025, 11 en 2026.
- Falta QA real por ALIMENTADOR_DISTRITAL, ADMINISTRADOR_ESTATAL, ADMINISTRADOR_MAESTRO y PENDIENTE. El frontend muestra N/D cuando no hay RPC autorizada o un agregado publicable.
