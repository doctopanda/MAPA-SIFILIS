# EDITH TITAN · Reactivación SA + SC + PRENATAL

## Decisión de producto (2026-11-25)
Reactivar EDITH SA como programa de EDITH ÚNICA, junto a EDITH SC, compartiendo CORE, FLOW, GUARDIAN, catálogos, distritos y servicios analíticos, sin mezclar definiciones de caso, numeradores ni expedientes de los dos programas.

## Política de captura progresiva
- Permitir guardar borradores parciales y registrar explícitamente datos faltantes. No bloquear el ingreso por ausencia de campos clínicos no disponibles.
- La notificación exige únicamente un mínimo operativo a validar institucionalmente. No se confunde borrador, alerta de tamizaje, notificación y caso confirmado.
- Los estados desconocido, no realizado, pendiente, no aplica y negativo son distintos; no imputar datos ni fechas.
- Generar lista de pendientes, calidad y responsables; solicitar campos según la etapa, con revisión previa a clasificación y cierre.
- No exigir CURP de recién nacido para comenzar una notificación. Identidad, deduplicación y mínimos oficiales requieren revisión.

## Recuperación de SA
- Reutilizar el canónico SA, eventos, solicitudes, importaciones, notificaciones, auditoría y exportaciones existentes.
- Mantener SC y SA independientes. TITAN será una capa de navegación y relación autorizada, no un expediente nominal universal expuesto al cliente.
- Auditar payload por diccionario y procedencia sin exportar valores personales. Preparar proyecciones seguras y agregados institucionales; no exponer la vista TITAN nominal.
- La reactivación inicial se construirá con expedientes ficticios en STAGING; no trasladar pacientes reales ni publicar cifras institucionales en GitHub Pages.
- No cambiar producción, RLS o permisos por inferencia.

## EDITH PRENATAL
Módulo de seguimiento de tamizaje, resultados, referencia, tratamiento documentado, seguimiento de pareja/contactos bajo confidencialidad, parto y seguimiento del recién nacido. Vincular eventos a episodios maternos y, si procede, expedientes SA y SC mediante relaciones revisadas, nunca por coincidencia automática de nombre o municipio. Un resultado reactivo no equivale por sí solo a un caso confirmado ni toda exposición a un caso SC.

## Indicadores candidatos
- SA: notificaciones, clasificación propia, oportunidad de diagnóstico y tratamiento, seguimiento y atención a contactos.
- Prenatal: cobertura de tamizaje por embarazo elegible, proporción de resultados positivos según algoritmo validado, tratamiento documentado, pendientes y continuidad de atención.
- SC: casos según definición operacional, residencia materna, nacimiento, seguimiento, incidencia con denominador y corte compatibles.
- Medir faltantes y cobertura de fuentes; no sumar SA + SC como personas únicas. No llamar prevalencia a registros de vigilancia.

## Secuencia de desarrollo
1. Auditar contrato y seguridad de las tablas SA existentes y recuperar versión anterior del formulario y diccionario.
2. Construir fixtures sintéticos SA, embarazo y vínculos; pruebas negativas de identidad, distrito, roles y consultor.
3. Adaptar captura parcial y flujo de SA, separar clasificador SA del SC.
4. Prototipo prenatal y lista de pendientes; vinculación revisada y auditable.
5. Agregados protegidos por programa, mapas, exportaciones y prueba de paridad.
6. Validación normativa, clínica, institucional, pruebas end-to-end y autorización de promoción.

## Decisiones reservadas
Definiciones operacionales SA y SC, mínimo de notificación, algoritmo de tamizaje y tratamiento vigente, alcance de roles prenatal/laboratorio, reglas de vinculación y contacto, acceso nominal, denominadores y autorización de despliegue. No automatizar diagnóstico, prescripción ni fusiones de pacientes.

Referencias para validación:
- OPS: https://www.paho.org/es/documentos/orientaciones-para-eliminacion-sifilis-sifilis-congenita-americas
- OMS: https://www.who.int/publications/i/item/9789240090767/
- DGE: https://epidemiologia.salud.gob.mx/gobmx/salud/documentos/manuales/31_Manual_SIFILIS.pdf
