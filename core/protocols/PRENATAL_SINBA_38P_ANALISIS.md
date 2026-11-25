# EDITH PRENATAL · Análisis inicial SINBA-SIS-38-P
Estado: borrador de diseño; no producción. Fuente 2022: anverso https://www.studocu.com/es-mx/document/instituto-superior-de-bienestar-integral-mexicano/vida-saludable-y-deporte/tarjeta-de-control-prenatal-sinba-sis-38-p-2022/147208516 ; reverso https://www.studocu.com/es-mx/document/instituto-superior-de-bienestar-integral-mexicano/vida-saludable-y-deporte/tarjeta-de-atencion-integral-del-embarazo-y-lactancia-sinba-sis-38-p/147208514 ; instructivo DGIS 2022 (copia de terceros) https://es.scribd.com/document/667240783/INSTRUCTIVO-DE-LLENADO-DE-LA-TARJETA-DE-CONTROL-DE-EMBARAZO-PUERPERIO-Y-LACTANCIA . Instructivo DGIS 2025 (copia de terceros, fecha 2024-12-05): https://es.scribd.com/document/883560232/Instructivo-de-Llenado-Tarjeta-Emb-Puerperio-y-Lactancia . Portal DGIS 2022 no accesible durante revisión. 2025 menciona acceso con usuario y contraseña al archivo Excel. No afirmar vigencia 2026 ni exhaustividad; cotejar con archivo oficial autorizado Sonora antes de cerrar diccionario o activar captura.
## Diseño longitudinal
Unidad/persona prestadora y usuaria se registran una vez o recuperan catálogos autorizados; embarazo es episodio, no identidad. Consultas, detecciones, inmunizaciones, laboratorio, visitas y tratamientos son eventos repetibles con fechas y fuente. Atención obstétrica separada de productos (0..n); puerperio y lactancia tienen consultas independientes. Captura progresiva y faltantes explícitos; no convertir ausente en negativo. Asteriscos y códigos oficiales se conservarán por versión tras cotejo. Datos adicionales TITAN separados y nunca presentados como campos SIS. No copiar datos personales a STAGING o GitHub.
## Grupos del formato
Anverso: unidad y profesional; identificación; ingreso; antecedentes familiares, patológicos y reproductivos; grupo/Rh; consumo; odontología; nutrición; vacunas; detecciones VIH/sífilis; citas prenatales; visitas domiciliarias; enfermedades y baja.
Reverso: atención obstétrica y productos; seguimiento puerperal; lactancia; baja.
2025: folio del formato, CURP prestador, derechohabiencia y catálogos actualizados; próxima cita en puerperio/lactancia. No asumir equivalencia de códigos entre versiones. Extraer catálogo completo del original institucional.
## Modelo propuesto
- person_ref: UUID protegido; referencia al registro autorizado existente, sin duplicar identificación; no exponer a consultor.
- pregnancy: UUID, folio aleatorio, person_ref, unit_ref (CLUES), source_form_version, ingreso/etapa, FUM y confiabilidad, FPP registrada y derivada por separado, estado.
- pregnancy_baseline: antecedentes y condiciones en catálogos versionados; datos antropométricos iniciales, plan de seguridad.
- prenatal_visit: fecha real, próxima cita, edad gestacional y método, peso, presión, altura uterina, FCF, signos/síntomas y actividades.
- test_event: tipo, fecha, técnica, estado, resultado original, interpretación documentada; título cuantitativo separado; repetible; vincular a visita sin obligarla.
- procedure_event: vacuna, odontología, educación, nutrición, visita comunitaria, medicamento; extensiones específicas con campos propios y no listas delimitadas.
- obstetric_event: fecha, tipo de atención, lugar, profesional, traslado, complicaciones, anticoncepción, fecha de obtención de información.
- birth_product: ordinal único por evento, condición, sexo, medidas, escalas y tamizajes; referencia a SC o infancia solo por vínculo revisado.
- postpartum_visit, lactation_visit: fechas, signos/síntomas, peso, tratamiento, alimentación y observaciones, próxima cita.
- discharge_event: fase, motivo, fecha; no cerrar seguimiento especializado automáticamente.
- form_version, field_dictionary, code_catalog, source_provenance: mapeo versionado de campo, tipo, unidad, condición de obligatoriedad, fuente y validación.
## Reglas de protección
RLS por programa, unidad y distrito; rol prenatal pendiente de definición; enlaces TITAN revisados. Sin publicación nominal ni códigos de acceso reutilizables. Exportación oficial solo si validada y autorizada; captura parcial persistente, revisión de obligatoriedad antes de envío SIS.
## Próximo paso
Obtener PDF/Excel oficial 2025/2026 y confirmar anverso y reverso; inventario campo a campo con códigos exactos, obligatoriedad y cardinalidad; construir prototipo de formulario y SQL en STAGING sintético. No migración productiva.
