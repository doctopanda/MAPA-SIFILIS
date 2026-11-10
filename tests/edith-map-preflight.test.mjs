import test from 'node:test';
import assert from 'node:assert/strict';
import {existsSync, readFileSync, readdirSync} from 'node:fs';
import {join, relative, dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import vm from 'node:vm';
import {gunzipSync} from 'node:zlib';

const root=join(dirname(fileURLToPath(import.meta.url)),'..');
const assets=join(root,'cloudflare-pages');
const mapRoot=join(assets,'mapa');
const read=(base,path)=>readFileSync(join(base,path));
const parse=(base,path)=>JSON.parse(read(base,path).toString('utf8'));
const rowAllowed=new Set(['program','layer_id','metric_id','cohort_id','geography_type','geography_id','geography_name','numerator','denominator','value','suppressed','display_value','source_system','source_cut_date','calculation_version','year','epidemiological_week_from','epidemiological_week_to','case_definition']);
const flowAllowed=new Set(['program','layer_id','metric_id','cohort_id','geography_type','origin_geography_id','destination_geography_id','flow_count','suppressed','source_cut_date','calculation_version','year','epidemiological_week_from','epidemiological_week_to']);

function files(dir){
 return readdirSync(dir,{withFileTypes:true}).flatMap(x=>x.isDirectory()?files(join(dir,x.name)):[join(dir,x.name)]);
}
function assertNoNewFields(obj,allowed,label){
 for(const key of Object.keys(obj))assert.ok(allowed.has(key),label+': campo no autorizado en agregados públicos: '+key);
}
test('Cloudflare incluye rutas esenciales y mapa con geometría local',()=>{
 for(const p of ['index.html','mapa/index.html','captura/index.html','biblioteca/index.html','mapa/data/sonora_municipios.geojson'])assert.ok(existsSync(join(assets,p)),p+' ausente');
 const html=read(assets,'mapa/index.html').toString('utf8');
 assert.match(html,/data\/sonora_municipios\.geojson/);
 assert.match(html,/EDITH_MAP_REVOKE/);
 const parent=read(assets,'index.html').toString('utf8');
 assert.match(parent,/edith_sc_mapa_residencia_v1/);
 assert.match(parent,/EDITH_MAP_REVOKE/);
});

test('Scripts de EDITH y MAPA-SÍFILIS tienen sintaxis válida',()=>{
 for(const path of ['index.html','mapa/index.html','captura/index.html','biblioteca/index.html']){
  const html=read(assets,path).toString('utf8');
  for(const match of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script>/gi)){
   if(/\bsrc\s*=/.test(match[1]))continue;
   if(match[2].trim())assert.doesNotThrow(()=>new vm.Script(match[2],{filename:path}),path);
  }
 }
});

test('Todos los agregados del mapa respetan supresión y contrato sin nominales',()=>{
 const m=parse(mapRoot,'data/snapshot_manifest.json');
 assert.equal(m.privacy?.nominal_data,false);
 assert.equal(m.privacy?.small_cell_suppression_applied,true);
 assert.equal(m.privacy?.small_cell_suppression_threshold,5);
 assert.equal(m.row_shards?.length,16);
 let totalRows=0;
 for(const path of m.row_shards){
  assert.match(path,/^data\/snapshot\/rows-\d{2}\.json$/);
  const shard=parse(mapRoot,path);
  for(const [i,row] of (shard.rows||[]).entries()){
   totalRows++;
   assertNoNewFields(row,rowAllowed,path+':'+i);
   assert.equal(typeof row.suppressed,'boolean');
   if(row.suppressed){
    assert.equal(row.numerator,null,'numerador suprimido');
    assert.equal(row.value,null,'valor suprimido');
    assert.equal(row.denominator,null,'denominador suprimido');
    assert.equal(row.display_value,'<5');
   }else{
    for(const key of ['numerator','value'])if(typeof row[key]==='number')assert.ok(row[key]===0||row[key]>=5,'celda pequeña expuesta: '+path);
   }
  }
 }
 assert.equal(totalRows,m.row_count);
 let totalFlows=0;
 for(const path of m.flow_shards){
  assert.match(path,/^data\/snapshot\/flows\.json$/);
  for(const [i,flow] of (parse(mapRoot,path).flows||[]).entries()){
   totalFlows++;assertNoNewFields(flow,flowAllowed,path+':'+i);
   assert.ok(flow.suppressed===true||Number.isInteger(flow.flow_count)&&flow.flow_count>=5,'flujo sin supresión');
  }
 }
 assert.equal(totalFlows,m.flow_count);
});

test('Copias cartográficas de Cloudflare coinciden con las fuentes públicas de GitHub',()=>{
 const target=join(mapRoot,'data');
 for(const deployed of files(target)){
  const rel=relative(target,deployed);
  // Única adición: geometría local INEGI, obtenida sin datos personales.
  if(rel==='sonora_municipios.geojson'||rel==='conapo_sonora_2024_2026.json')continue;
  const original=join(root,'data',rel);
  assert.ok(existsSync(original),'Falta fuente de '+rel);
  assert.deepEqual(readFileSync(deployed),readFileSync(original),'Copia obsoleta: '+rel);
 }
});

test('El cruce operativo de 10 regiones y 6 distritos cubre 72 municipios sin duplicados',()=>{
 // Este test acredita integridad de los archivos del proyecto, NO homologación oficial de adscripción territorial.
 const regions=parse(mapRoot,'data/imss_bienestar_regions.json');
 const cross=parse(mapRoot,'data/municipality_region_crosswalk.json');
 const districts=parse(mapRoot,'data/districts.json');
 assert.equal(regions.regions.length,10);
 assert.equal(cross.rows.length,72);
 assert.equal(districts.districts.length,6);
 const regionCodes=regions.regions.flatMap(r=>r.municipalities.map(m=>m.code));
 const districtCodes=districts.districts.flatMap(d=>d.municipalities);
 assert.equal(new Set(regionCodes).size,72,'No debe haber municipios repetidos entre regiones en este cruce');
 assert.equal(new Set(districtCodes).size,72,'Los seis distritos deben cubrir el catálogo sin duplicación');
 assert.equal(new Set(cross.rows.map(r=>r.municipality_code)).size,72);
 const crossByCode=new Map(cross.rows.map(r=>[r.municipality_code,r]));
 for(const region of regions.regions){
  assert.equal(region.municipalities.length,region.municipality_count,region.id);
  for(const m of region.municipalities){
   const row=crossByCode.get(m.code);
   assert.ok(row,'Municipio sin registro cruzado: '+m.code);
   assert.equal(row.imss_bienestar_region_id,region.id,'Discrepancia región: '+m.code);
  }
 }
 for(const district of districts.districts){
  for(const code of district.municipalities){
   const row=crossByCode.get(code);
   assert.ok(row,'Municipio no registrado en cruce: '+code);
   assert.equal(row.health_district_id,district.id,'Discrepancia distrito: '+code);
  }
 }
 assert.match(regions.status,/operational_crosswalk_supplied_by_project_owner/,'El cruce no debe anunciarse como oficialmente homologado');
});

test('Históricos 2024–2026 contienen series municipales publicables sin nominales',()=>{
 const manifest=parse(mapRoot,'data/history/history_manifest.json');
 assert.deepEqual(manifest.visible_years,[2024,2025,2026]);
 for(const year of manifest.visible_years){
  const gzFile=join(mapRoot,manifest.files[String(year)].replace(/^data\//,'data/'));
  assert.ok(existsSync(gzFile),'Histórico ausente '+year);
  const data=JSON.parse(gunzipSync(readFileSync(gzFile)).toString('utf8'));
  assert.ok(Array.isArray(data.rows),'Histórico sin filas '+year);
  const municipal=data.rows.filter(r=>r.program==='SC'&&r.layer_id==='maternal_residence'&&r.metric_id==='cases'&&
    (r.cohort_id||'year_total')==='year_total'&&r.geography_type==='municipality');
  assert.ok(municipal.length>=60,'Sin serie municipal suficiente para '+year);
  const example=municipal.find(r=>String(r.geography_id).replace(/^26/,'').padStart(3,'0')==='030');
  assert.ok(example,'Hermosillo no presente en histórico '+year);
  for(const row of municipal){
   assertNoNewFields(row,new Set([...rowAllowed,'study_period','population_year','cut_date','suppression_threshold']),String(year));
   if(row.suppressed){
    assert.equal(row.numerator,null,'Celda pequeña en '+year);
    assert.equal(row.value,null,'Valor pequeño en '+year);
   }else if(row.numerator!=null){
    assert.ok(Number.isInteger(row.numerator)&&row.numerator>=0&&(row.numerator===0||row.numerator>=5),'Conteo 1–4 publicado '+year);
   }
  }
 }
});

test('Panorama distrital sólo publica datos distritales directos',()=>{
 const manifest=parse(mapRoot,'data/history/history_manifest.json');
 for(const year of manifest.visible_years){
  const doc=JSON.parse(gunzipSync(readFileSync(join(mapRoot,manifest.files[String(year)]))).toString('utf8'));
  const district=doc.rows.filter(r=>r.program==='SC'&&r.layer_id==='maternal_residence'&&r.metric_id==='cases'&&
    (r.cohort_id||'year_total')==='year_total'&&r.geography_type==='health_district');
  assert.equal(district.length,6,'El histórico '+year+' debe ofrecer los seis totales distritales publicados');
  assert.deepEqual(district.map(r=>r.geography_id).sort(),['DS01','DS02','DS03','DS04','DS05','DS06']);
  for(const row of district){
   if(row.suppressed)assert.equal(row.numerator,null,'Distrito suprimido no permite cálculo desde municipios');
   else assert.ok(Number.isInteger(row.numerator)&&row.numerator>=0&&(row.numerator===0||row.numerator>=5),'Conteo distrital menor a cinco publicado');
  }
 }
});

test('Históricos regionales sólo utilizan agregados directos de las 10 regiones',()=>{
 const regions=parse(mapRoot,'data/imss_bienestar_regions.json');
 const allowed=new Set(regions.regions.map(r=>r.id));
 assert.equal(allowed.size,10);
 const manifest=parse(mapRoot,'data/history/history_manifest.json');
 for(const year of manifest.visible_years){
  const doc=JSON.parse(gunzipSync(readFileSync(join(mapRoot,manifest.files[String(year)]))).toString('utf8'));
  const rows=doc.rows.filter(r=>r.program==='SC'&&r.layer_id==='maternal_residence'&&r.metric_id==='cases'&&
   (r.cohort_id||'year_total')==='year_total'&&r.geography_type==='imss_bienestar_region');
  assert.equal(rows.length,10,'El año '+year+' debe disponer de diez agregados regionales independientes');
  assert.deepEqual(new Set(rows.map(r=>r.geography_id)),allowed);
  for(const row of rows){
   if(row.suppressed)assert.equal(row.numerator,null,'Región suprimida no debe revelar numerador');
   else assert.ok(Number.isInteger(row.numerator)&&row.numerator>=0&&(row.numerator===0||row.numerator>=5),'Valor regional 1–4 no publicable');
  }
 }
});

test('CONAPO Sonora: 72 municipios y desglose por sexo 2024–2026',()=>{
 const data=parse(mapRoot,'data/conapo_sonora_2024_2026.json');
 assert.equal(data.schema,'EDITH_CONAPO_SONORA_MUNICIPAL_MIDYEAR_V1');
 assert.equal(data.geographies,72);
 assert.equal(data.rows.length,72);
 const codes=data.rows.map(r=>r.code);
 assert.equal(new Set(codes).size,72);
 const cw=parse(mapRoot,'data/municipality_region_crosswalk.json');
 assert.deepEqual(codes.slice().sort(),cw.rows.map(r=>r.municipality_code).sort());
 for(const year of [2024,2025,2026]){
  let total=0;
  for(const row of data.rows){
   const v=row.values[year];
   assert.ok(Number.isSafeInteger(v.total)&&v.total>0);
   assert.ok(Number.isSafeInteger(v.male)&&Number.isSafeInteger(v.female));
   assert.equal(v.male+v.female,v.total,'Sexos de '+row.code+'/'+year);
   total+=v.total;
  }
  assert.equal(total,({2024:3111704,2025:3140762,2026:3168624})[year]);
 }
});
