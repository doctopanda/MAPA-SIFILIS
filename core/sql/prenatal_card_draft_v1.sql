-- Private synthetic laboratory only. Never copy production clinical data here.
create table edith_core.prenatal_field_v1(
 field_id text primary key, group_id text not null, scope text not null check(scope in ('baseline','event','product')),
 value_type text not null check(value_type in ('txt','cat','multi','bool','date','int','num')),
 source_locator text not null, required_mark_visible boolean
);
insert into edith_core.prenatal_field_v1 values
('unidad.clues','unidad','baseline','txt','5.2',true),
('unidad.nombre_unidad','unidad','baseline','txt','5.2',null),
('unidad.localidad_unidad','unidad','baseline','txt','5.2',null),
('unidad.municipio_unidad','unidad','baseline','txt','5.2',null),
('unidad.jurisdiccion','unidad','baseline','txt','5.2',null),
('unidad.entidad_unidad','unidad','baseline','txt','5.2',null),
('personal.tipo_personal','personal','baseline','cat','5.3',true),
('personal.servicio','personal','baseline','cat','5.3',true),
('personal.nombre_prestador','personal','baseline','txt','5.3',true),
('personal.curp_prestador','personal','baseline','txt','5.3',true),
('identificacion.curp','identificacion','baseline','txt','5.4',true),
('identificacion.nombres','identificacion','baseline','txt','5.4',true),
('identificacion.primer_apellido','identificacion','baseline','txt','5.4',true),
('identificacion.segundo_apellido','identificacion','baseline','txt','5.4',null),
('identificacion.entidad_nacimiento','identificacion','baseline','cat','5.4',true),
('identificacion.fecha_nacimiento','identificacion','baseline','date','5.4',true),
('identificacion.edad','identificacion','baseline','int','5.4',null),
('identificacion.expediente','identificacion','baseline','txt','5.4',null),
('identificacion.derechohabiencia','identificacion','baseline','cat','5.4',true),
('identificacion.estado_conyugal','identificacion','baseline','cat','5.4',true),
('identificacion.escolaridad','identificacion','baseline','cat','5.4',true),
('identificacion.tipo_escolaridad','identificacion','baseline','cat','5.4',true),
('identificacion.peso_previo_kg','identificacion','baseline','num','5.4',true),
('identificacion.talla_m','identificacion','baseline','num','5.4',true),
('identificacion.imc','identificacion','baseline','num','5.4',null),
('identificacion.afromexicana','identificacion','baseline','bool','5.4',null),
('identificacion.migrante','identificacion','baseline','cat','5.4',true),
('identificacion.origen_nacional','identificacion','baseline','txt','5.4',null),
('identificacion.origen_internacional','identificacion','baseline','txt','5.4',null),
('identificacion.indigena','identificacion','baseline','bool','5.4',true),
('identificacion.lengua_materna_indigena','identificacion','baseline','bool','5.4',null),
('identificacion.lengua_indigena','identificacion','baseline','cat','5.4',null),
('identificacion.habla_espanol','identificacion','baseline','bool','5.4',null),
('identificacion.domicilio','identificacion','baseline','txt','5.4',null),
('identificacion.telefono','identificacion','baseline','txt','5.4',null),
('ingreso.fecha_ingreso','ingreso','baseline','date','5.5',null),
('ingreso.etapa_ingreso','ingreso','baseline','cat','5.5',null),
('ingreso.fum_ignorada','ingreso','baseline','bool','5.5',true),
('ingreso.fum','ingreso','baseline','date','5.5',null),
('ingreso.fum_confiable','ingreso','baseline','bool','5.5',true),
('ingreso.fecha_usg','ingreso','baseline','date','5.5',null),
('ingreso.semanas_usg','ingreso','baseline','num','5.5',null),
('ingreso.prueba_embarazo','ingreso','baseline','bool','5.5',null),
('ingreso.fpp','ingreso','baseline','date','5.5',null),
('ingreso.plan_seguridad','ingreso','baseline','bool','5.5',null),
('comunidad.personal_comunitario','comunidad','baseline','cat','5.5',null),
('familiares.antecedentes_familiares','familiares','baseline','multi','5.6',null),
('patologicos.antecedentes_personales','patologicos','baseline','multi','5.7',null),
('patologicos.otro_antecedente_personal','patologicos','baseline','cat','5.7',null),
('detecciones.fecha_prueba','detecciones','event','date','4.1.1',null),
('detecciones.deteccion_ordinal','detecciones','event','cat','4.1.1',null),
('detecciones.infeccion','detecciones','event','cat','4.1.1',null),
('detecciones.tecnica_prueba','detecciones','event','cat','4.1.1',null),
('detecciones.resultado_deteccion','detecciones','event','cat','4.1.1',null),
('detecciones.tipo_confirmatoria','detecciones','event','cat','4.1.1',null),
('detecciones.fecha_confirmatoria','detecciones','event','date','4.1.1',null),
('detecciones.resultado_confirmatoria','detecciones','event','cat','4.1.1',null),
('detecciones.resultado_carga_viral','detecciones','event','cat','4.1.1',null),
('detecciones.fecha_curva_glucosa','detecciones','event','date','4.1.1',null),
('detecciones.glucosa_ayuno_mg_dl','detecciones','event','num','4.1.1',null),
('detecciones.glucosa_60_mg_dl','detecciones','event','num','4.1.1',null),
('detecciones.glucosa_120_mg_dl','detecciones','event','num','4.1.1',null),
('gineco.atencion_pregestacional','gineco','baseline','bool','4.1.1',null),
('gineco.riesgos_pregestacionales','gineco','baseline','multi','4.1.1',null),
('gineco.gestas','gineco','baseline','int','4.1.1',true),
('gineco.partos','gineco','baseline','int','4.1.1',null),
('gineco.cesareas','gineco','baseline','int','4.1.1',null),
('gineco.abortos','gineco','baseline','int','4.1.1',null),
('gineco.ectopicos','gineco','baseline','int','4.1.1',null),
('gineco.molas','gineco','baseline','int','4.1.1',null),
('gineco.embarazos_multiples','gineco','baseline','int','4.1.1',null),
('gineco.hijos_vivos','gineco','baseline','int','4.1.1',null),
('gineco.hijos_muertos','gineco','baseline','int','4.1.1',null),
('gineco.resolucion_ultimo_embarazo','gineco','baseline','cat','4.1.1',null),
('gineco.fecha_ultima_resolucion','gineco','baseline','date','4.1.1',null),
('gineco.anticonceptivo_previo','gineco','baseline','cat','4.1.1',true),
('gineco.tiempo_uso','gineco','baseline','txt','4.1.1',null),
('gineco.fecha_suspension','gineco','baseline','date','4.1.1',null),
('gineco.falla_anticonceptivo','gineco','baseline','bool','4.1.1',null),
('gineco.otros_gineco','gineco','baseline','multi','4.1.1',null),
('adicciones.tabaco','adicciones','baseline','bool','4.1.1',null),
('adicciones.alcohol','adicciones','baseline','bool','4.1.1',null),
('adicciones.antidepresivos','adicciones','baseline','bool','4.1.1',null),
('adicciones.ansioliticos','adicciones','baseline','bool','4.1.1',null),
('adicciones.otros_consumos','adicciones','baseline','txt','4.1.1',null),
('adicciones.consumo_actual','adicciones','baseline','bool','4.1.1',null),
('adicciones.tiempo_suspension_anos','adicciones','baseline','int','4.1.1',null),
('adicciones.tiempo_suspension_meses','adicciones','baseline','int','4.1.1',null),
('bucal.revision_odontologica','bucal','event','bool','4.1.1',null),
('bucal.caries','bucal','event','bool','4.1.1',null),
('bucal.periodontitis','bucal','event','bool','4.1.1',null),
('bucal.otro_bucal','bucal','event','txt','4.1.1',null),
('biologicos.biologico','biologicos','event','cat','4.1.1',null),
('biologicos.numero_dosis','biologicos','event','int','4.1.1',null),
('biologicos.fecha_aplicacion','biologicos','event','date','4.1.1',null),
('sangre.grupo_sanguineo','sangre','baseline','cat','4.1.1',null),
('sangre.rh','sangre','baseline','cat','4.1.1',null),
('sangre.prueba_coombs','sangre','baseline','bool','4.1.1',null),
('sangre.tratamiento_coombs','sangre','baseline','bool','4.1.1',null),
('nutricion.valoracion_nutricional','nutricion','event','bool','4.1.1',null),
('inicio_citas.fecha_inicio_citas','inicio_citas','baseline','date','5.15 pendiente numeración',null),
('citas.fecha_consulta','citas','event','date','4.1.1',null),
('citas.semanas_gestacion','citas','event','num','4.1.1',null),
('citas.peso_kg','citas','event','num','4.1.1',null),
('citas.pa_sistolica','citas','event','num','4.1.1',null),
('citas.pa_diastolica','citas','event','num','4.1.1',null),
('citas.fondo_uterino_cm','citas','event','num','4.1.1',null),
('citas.fcf_lpm','citas','event','num','4.1.1',null),
('citas.acompanante','citas','event','cat','4.1.1',null),
('citas.signos_alarma','citas','event','multi','4.1.1',null),
('citas.medicamentos','citas','event','multi','4.1.1',null),
('citas.glucemia','citas','event','num','4.1.1',null),
('citas.enzimas_hepaticas_alteraciones','citas','event','txt','4.1.1',null),
('citas.hemoglobina','citas','event','num','4.1.1',null),
('citas.hematocrito','citas','event','num','4.1.1',null),
('citas.plaquetas','citas','event','num','4.1.1',null),
('citas.leucocitos','citas','event','num','4.1.1',null),
('citas.proteinuria','citas','event','txt','4.1.1',null),
('citas.glucosuria','citas','event','txt','4.1.1',null),
('citas.hematuria','citas','event','txt','4.1.1',null),
('citas.bacteriuria','citas','event','txt','4.1.1',null),
('citas.semanas_usg','citas','event','num','4.1.1',null),
('citas.resultado_usg','citas','event','txt','4.1.1',null),
('citas.orientacion','citas','event','multi','4.1.1',null),
('citas.enfermedades_cie10','citas','event','multi','4.1.1',null),
('citas.referencia_destino','citas','event','cat','4.1.1',null),
('citas.referencia_motivo','citas','event','cat','4.1.1',null),
('citas.plan_seguridad','citas','event','bool','4.1.1',null),
('domicilio.fecha_visita','domicilio','event','date','4.1.1',null),
('domicilio.resultado_visita','domicilio','event','cat','4.1.1',null),
('domicilio.personal_visita','domicilio','event','cat','4.1.1',null),
('enfermedades.diagnostico_cie10','enfermedades','event','cat','4.1.1',null),
('baja_embarazo.fecha_baja','baja_embarazo','event','date','4.1.1',null),
('baja_embarazo.motivo_baja','baja_embarazo','event','cat','4.1.1',null),
('obstetricia.fecha_atencion','obstetricia','event','date','4.1.2',null),
('obstetricia.tipo_atencion','obstetricia','event','cat','4.1.2',null),
('obstetricia.procedimiento_aborto','obstetricia','event','cat','4.1.2',null),
('obstetricia.tipo_parto','obstetricia','event','cat','4.1.2',null),
('obstetricia.semanas_gestacion','obstetricia','event','num','4.1.2',null),
('obstetricia.anticoncepcion_postevento','obstetricia','event','bool','4.1.2',null),
('obstetricia.metodo_anticonceptivo','obstetricia','event','cat','4.1.2',null),
('obstetricia.transporte','obstetricia','event','cat','4.1.2',null),
('obstetricia.lugar_atencion','obstetricia','event','txt','4.1.2',null),
('obstetricia.personal_atencion','obstetricia','event','txt','4.1.2',null),
('obstetricia.complicaciones','obstetricia','event','multi','4.1.2',null),
('obstetricia.multiplicidad','obstetricia','event','cat','4.1.2',null),
('obstetricia.fecha_obtencion_datos','obstetricia','event','date','4.1.2',null),
('obstetricia.apego_inmediato','obstetricia','event','bool','4.1.2',null),
('obstetricia.egreso_lme','obstetricia','event','bool','4.1.2',null),
('obstetricia.sucedaneo_b24x','obstetricia','event','bool','4.1.2',null),
('obstetricia.profilaxis_b24x','obstetricia','event','bool','4.1.2',null),
('obstetricia.profilaxis_a539','obstetricia','event','bool','4.1.2',null),
('producto.ordinal','producto','product','int','4.1.2',null),
('producto.condicion_nacimiento','producto','product','cat','4.1.2',null),
('producto.sexo','producto','product','cat','4.1.2',null),
('producto.peso_g','producto','product','num','4.1.2',null),
('producto.talla_cm','producto','product','num','4.1.2',null),
('producto.apgar_5min','producto','product','int','4.1.2',null),
('producto.silverman','producto','product','int','4.1.2',null),
('producto.tamiz_metabolico','producto','product','bool','4.1.2',null),
('producto.tamiz_auditivo','producto','product','bool','4.1.2',null),
('puerperio.primera_consulta_menor_8_dias','puerperio','event','bool','4.1.2',null),
('puerperio.fecha_consulta','puerperio','event','date','4.1.2',null),
('puerperio.peso_kg','puerperio','event','num','4.1.2',null),
('puerperio.signos_alarma','puerperio','event','multi','4.1.2',true),
('puerperio.medicamentos','puerperio','event','multi','4.1.2',true),
('puerperio.enfermedades_presentes','puerperio','event','multi','4.1.2',null),
('puerperio.plan_seguridad','puerperio','event','bool','4.1.2',null),
('puerperio.deteccion_depresion','puerperio','event','cat','4.1.2',null),
('lactancia.fecha_consulta','lactancia','event','date','4.1.2',null),
('lactancia.peso_kg','lactancia','event','num','4.1.2',null),
('lactancia.lactancia_exclusiva','lactancia','event','cat','4.1.2',true),
('lactancia.sucedaneo_b24x','lactancia','event','bool','4.1.2',null),
('lactancia.signos_alarma','lactancia','event','multi','4.1.2',true),
('lactancia.medicamentos','lactancia','event','multi','4.1.2',true),
('lactancia.observaciones','lactancia','event','multi','4.1.2',null),
('baja_lactancia.fecha_baja','baja_lactancia','event','date','4.1.2',null),
('baja_lactancia.motivo_baja','baja_lactancia','event','cat','4.1.2',null),
('baja_lactancia.otro_motivo','baja_lactancia','event','txt','4.1.2',null);
create table edith_core.prenatal_person_v1(
 person_key text primary key check(person_key~'^PN-TEST-PER-[0-9]{3}$')
);
create table edith_core.prenatal_pregnancy_v1(
 folio text primary key check(folio~'^PN-TEST-EMB-[0-9]{3}$'), person_key text references edith_core.prenatal_person_v1,
 form_version text not null default '2025-DRAFT' check(form_version='2025-DRAFT'),
 district text not null check(district~'^DS0[1-6]$'), data jsonb not null default '{}'::jsonb check(jsonb_typeof(data)='object')
);
create table edith_core.prenatal_event_v1(
 event_key text primary key check(event_key~'^PN-TEST-EVT-[0-9]{3}$'), folio text not null references edith_core.prenatal_pregnancy_v1,
 group_id text not null, event_date date, data jsonb not null default '{}'::jsonb check(jsonb_typeof(data)='object'),
 unique(event_key,folio), check(group_id in ('detecciones','bucal','biologicos','nutricion','citas','domicilio','enfermedades','baja_embarazo','obstetricia','puerperio','lactancia','baja_lactancia'))
);
create table edith_core.prenatal_product_v1(
 product_key text primary key check(product_key~'^PN-TEST-RN-[0-9]{3}$'), event_key text not null, folio text not null,
 ordinal int not null check(ordinal>0), data jsonb not null default '{}'::jsonb check(jsonb_typeof(data)='object'),
 foreign key(event_key,folio) references edith_core.prenatal_event_v1(event_key,folio), unique(event_key,ordinal)
);
create function edith_core.prenatal_validate_v1() returns trigger
language plpgsql security invoker set search_path=pg_catalog,edith_core as $$
declare item record; f prenatal_field_v1%rowtype; wanted text; expected_group text;
begin
 wanted:=case tg_table_name when 'prenatal_pregnancy_v1' then 'baseline' when 'prenatal_event_v1' then 'event' else 'product' end;
 if wanted='event' then expected_group:=new.group_id; elsif wanted='product' then
 expected_group:='producto'; if not exists(select 1 from prenatal_event_v1 e where e.event_key=new.event_key and e.folio=new.folio and e.group_id='obstetricia') then raise exception 'Product requires obstetric event' using errcode='23514';end if;
 end if;
 for item in select * from jsonb_each(new.data) loop
  select * into f from prenatal_field_v1 where field_id=item.key;
  if not found or f.scope<>wanted or (expected_group is not null and f.group_id<>expected_group) then raise exception 'Unrecognized or misplaced field: %',item.key using errcode='23514';end if;
  if item.value='null'::jsonb then continue; end if;
  if (f.value_type in ('txt','cat','date') and jsonb_typeof(item.value)<>'string') or (f.value_type='bool' and jsonb_typeof(item.value)<>'boolean') or (f.value_type in ('int','num') and jsonb_typeof(item.value)<>'number') or (f.value_type='multi' and jsonb_typeof(item.value)<>'array') then raise exception 'Invalid type: %',item.key using errcode='23514';end if;
  if f.value_type='date' and (item.value#>>'{}' !~ '^\d{4}-\d{2}-\d{2}$' or parse_date_v1(item.value#>>'{}') is null) then raise exception 'Invalid date' using errcode='23514';end if;
  if f.value_type='int' and (item.value#>>'{}')::numeric<>trunc((item.value#>>'{}')::numeric) then raise exception 'Integer required' using errcode='23514';end if;
  if f.value_type='multi' and exists(select 1 from jsonb_array_elements(item.value) x where jsonb_typeof(x)<>'string') then raise exception 'Invalid selection' using errcode='23514';end if;
 end loop;
 return new;
end $$;
create trigger prenatal_pregnancy_validate before insert or update on edith_core.prenatal_pregnancy_v1 for each row execute function edith_core.prenatal_validate_v1();
create trigger prenatal_event_validate before insert or update on edith_core.prenatal_event_v1 for each row execute function edith_core.prenatal_validate_v1();
create trigger prenatal_product_validate before insert or update on edith_core.prenatal_product_v1 for each row execute function edith_core.prenatal_validate_v1();
alter table edith_core.prenatal_field_v1 enable row level security;
alter table edith_core.prenatal_person_v1 enable row level security;
alter table edith_core.prenatal_pregnancy_v1 enable row level security;
alter table edith_core.prenatal_event_v1 enable row level security;
alter table edith_core.prenatal_product_v1 enable row level security;
revoke all on all tables in schema edith_core from public,anon,authenticated;
revoke all on function edith_core.prenatal_validate_v1() from public,anon,authenticated;
insert into edith_core.prenatal_person_v1 values('PN-TEST-PER-001'),('PN-TEST-PER-002');
insert into edith_core.prenatal_pregnancy_v1(folio,person_key,district,data) values
('PN-TEST-EMB-001','PN-TEST-PER-001','DS01','{"gineco.gestas":2,"ingreso.fum_ignorada":true}'),
('PN-TEST-EMB-002','PN-TEST-PER-001','DS01','{}'),
('PN-TEST-EMB-003','PN-TEST-PER-002','DS02','{}');
insert into edith_core.prenatal_event_v1(event_key,folio,group_id,event_date,data) values
('PN-TEST-EVT-001','PN-TEST-EMB-001','citas','2026-01-10','{"citas.peso_kg":61.5,"citas.pa_sistolica":110}'),
('PN-TEST-EVT-002','PN-TEST-EMB-001','citas','2026-02-10','{"citas.peso_kg":63}'),
('PN-TEST-EVT-003','PN-TEST-EMB-001','detecciones',null,'{"detecciones.infeccion":"A539","detecciones.resultado_deteccion":null}'),
('PN-TEST-EVT-004','PN-TEST-EMB-001','obstetricia','2026-09-20','{"obstetricia.multiplicidad":"GEMELAR"}'),
('PN-TEST-EVT-005','PN-TEST-EMB-001','puerperio','2026-09-25','{"puerperio.plan_seguridad":false}'),
('PN-TEST-EVT-006','PN-TEST-EMB-001','lactancia',null,'{}');
insert into edith_core.prenatal_product_v1 values
('PN-TEST-RN-001','PN-TEST-EVT-004','PN-TEST-EMB-001',1,'{"producto.peso_g":2600}'),
('PN-TEST-RN-002','PN-TEST-EVT-004','PN-TEST-EMB-001',2,'{"producto.peso_g":2450}');
