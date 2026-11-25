# ADR propuesto · GESTAPP + EDITH PRENATAL: núcleo materno compartido
Fecha 2026-11-25. Decisión de arquitectura propuesta a partir del diálogo; no despliegue ni migración de producción.
## Finalidades
GESTASON: interfaz voluntaria de la paciente (prerregistro, diario, educación, documentos, consentimiento y código temporal).
GESTAPP: plataforma clínica web responsiva, captura oficial prenatal, validación de prerregistro, historial, mediciones, informes, planificación, impresión, comparación de fuentes, coordinación de atención materna. No requiere que la paciente use GESTASON.
EDITH PRENATAL: módulo/perspectiva epidemiológica del mismo ecosistema, con datos mínimos autorizados para vigilancia, calidad, indicadores, seguimiento de detecciones y referencias de sífilis; conecta EDITH SA/SC e Infancia mediante TITAN. No se otorga acceso a todo el expediente materno por un rol epidemiológico.
## Núcleo lógico único
Reutilizar lo construido: 179 campos técnicos preliminares, esquema longitudinal privado, control de revisiones, CLUES, estimación obstétrica, PRINT, BRIDGE, CLOCK, TREATMENT. No clonar carátulas ni reescribir EDITH SA/SC. Núcleo lógico no implica una sola tabla, ni un proyecto Supabase común obligatorio; separación física según evaluación de privacidad y operación. Identidad protegida, embarazo y consultas con UUID; cada programa usa proyecciones limitadas por finalidad. Nunca replicar la base nominal de embarazadas a repositorios o visores públicos.
## Separación de procedencia
1. Declarado por paciente, incluido diario y medición doméstica: original inmutable por versión, tiempo, fuente, estado de verificación.
2. Registro clínico: profesional/unidad, encuentro, método, fecha, medición, unidad y autor. Verificación explícita de un dato declarado produce nueva versión clínica vinculada al original, sin borrarlo.
3. Documento externo: informe original y metadatos, extracción no verificada, validación profesional separada.
4. Derivado: fórmula/regla/versión, entradas y fechas, no se presenta como medición original.
Vista comparativa por variable/tiempo; conflictos visibles, no promediar ni sobrescribir fuentes. Ejemplo: peso domicilio 68.2 kg y consulta 68.9 kg son dos observaciones; FUM declarada y FPP clínica se preservan por separado. Impresión oficial utiliza campos clínicos autorizados según mapeo validado; no vuelca el diario completo.
## Banco materno
Una persona puede tener múltiples embarazos y cada embarazo múltiples consultas, productos, referencias. Registro de población atendida, no censo de todas las embarazadas de Sonora. Denominadores de alcance clínico, adopción, completitud y continuidad diferenciados. Sin inferencia de cobertura poblacional sin denominador externo válido. Identidad, unidad y distrito verificadas; acceso por relación asistencial y ámbito, MFA profesional, autorización, registros de acceso y protección de información sensible. GESTASON voluntario; atención y seguimiento por canales alternativos sin penalizar a quien no tenga app. No reidentificación en tableros; supresión de celdas pequeñas cuando proceda.
## Despliegue incremental
Fase 1: GESTAPP web para embarazadas ya en control y personal de unidades piloto; usar EDITH PRENATAL existente, ficha, captura parcial, consultas, impresión y CLUES. Incorporar GESTASON voluntariamente en la unidad, con asistencia de registro.
Fase 2: código temporal, consentimiento, recepción y comparación de diario/prerregistro; no depender de app para atender. Pruebas de seguridad reales antes de apertura.
Fase 3: promoción/captación voluntaria de embarazadas todavía fuera de control, orientación y referencia a unidad; no confundir prerregistro con atención realizada; confirmar primera consulta.
Fase 4: documentos y apoyo clínico explicable, integración TITAN, evaluación de cobertura con denominadores válidos.
## Indicadores piloto
Personas y episodios distintos; registros clínicos activos; invitadas a GESTASON; activación voluntaria entre invitadas; días con diario sobre días esperados (periodo definido); referencias emitidas, recibidas y consultas realizadas; completitud por fuente y sección; tiempo de captura e impresión; consultas repetidas sin duplicación; no usar adopción de app como condición de atención.
## Puertas pendientes
Original SINBA-SIS-38-P autorizado, catálogo oficial, validación clínica y normativa, roles, permisos y privacidad, API autenticada con MFA, pruebas de navegador y flujo completo, aprobación institucional antes de datos reales. GESTA GUARDIAN es modelo sintético, no autenticación efectiva. 182 pruebas técnicas de regresión conjunta confirmadas en https://github.com/doctopanda/MAPA-SIFILIS/actions/runs/45716516248; no certificación clínica ni de seguridad integral.
