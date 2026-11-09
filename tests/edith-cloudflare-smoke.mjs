import assert from 'node:assert/strict';
import { chromium } from 'playwright';

const origin=process.env.EDITH_SMOKE_URL||'http://127.0.0.1:8787';
const routes=[
  '/','/mapa/','/captura/','/biblioteca/',
  '/mapa/data/snapshot_manifest.json',
  '/mapa/data/snapshot/rows-01.json',
  '/mapa/data/sonora_municipios.geojson',
  '/mapa/data/history/history_manifest.json',
  '/mapa/data/history/sc_2026_v04.json.gz'
];
const protectedPaths=['/docs/EDITH_MAPA_RPC_RLS_v1.sql','/wrangler.jsonc','/data/snapshot_manifest.json'];
const log=(name)=>console.log('✓ '+name);

for(const path of routes){
 const response=await fetch(origin+path,{redirect:'manual'});
 assert.equal(response.status,200,path+' => '+response.status);
 const bytes=new Uint8Array(await response.arrayBuffer());
 assert.ok(bytes.byteLength>50,'Recurso vacío '+path);
 if(path.endsWith('.json'))assert.doesNotThrow(()=>JSON.parse(new TextDecoder().decode(bytes)),path);
 if(path.endsWith('sonora_municipios.geojson')){
  const geo=JSON.parse(new TextDecoder().decode(bytes));
  assert.equal(geo.features?.length,72,'Debe mostrar 72 municipios');
 }
 log('HTTP 200 '+path+' ('+bytes.byteLength+' bytes)');
}
for(const path of protectedPaths){
 const response=await fetch(origin+path,{redirect:'manual'});
 assert.equal(response.status,404,'No publicar '+path+': '+response.status);
 log('HTTP 404, recurso protegido '+path);
}
const root=await fetch(origin+'/');
assert.equal(root.headers.get('x-content-type-options'),'nosniff','Falta cabecera de seguridad');
log('Cabeceras de seguridad');

const browser=await chromium.launch({headless:true,args:['--disable-dev-shm-usage']});
try {
 for(const size of [{width:1400,height:900},{width:390,height:844}]){
  const mobile=size.width<500;
  const page=await browser.newPage({viewport:size,isMobile:mobile,hasTouch:mobile});
  const issues=[];
  page.on('pageerror',error=>issues.push(error.message));
  await page.goto(origin+'/mapa/',{waitUntil:'domcontentloaded',timeout:30000});
  await page.waitForFunction(()=>/Cartografía cargada: 72 municipios/.test(document.getElementById('detail')?.textContent||''),{timeout:45000}).catch(async()=>{
   const status=await page.locator('#status').innerText();
   throw new Error('Mapa no inicializado '+size.width+'px: '+status+'; errores '+issues.join(' | '));
  });
  assert.equal(await page.locator('#map.leaflet-container').count(),1,'Leaflet no inicializó');
  const widths=await page.evaluate(()=>({viewport:innerWidth,scroll:document.documentElement.scrollWidth}));
  assert.ok(widths.scroll<=widths.viewport+18,'Desbordamiento horizontal en '+size.width+'px: '+JSON.stringify(widths));
  log('Mapa interactivo '+size.width+'px, 72 polígonos');
  await page.close();
 }
 const page=await browser.newPage({viewport:{width:1280,height:850}});
 await page.goto(origin+'/',{waitUntil:'domcontentloaded'});
 assert.equal(await page.locator('dialog#login-dialog[open]').count(),1,'EDITH debe mostrar login institucional');
 const hidden=await page.evaluate(()=>!document.body.classList.contains('edith-authenticated'));
 assert.equal(hidden,true,'Interfaz clínica no debe abrirse sin login');
 log('Shell institucional protegido sin sesión');

 // El iframe solo recibe datos sintéticos: NO se consultan pacientes ni credenciales.
 await page.evaluate(()=>{
  const frame=document.createElement('iframe');
  frame.id='edith-map-frame';frame.src='/mapa/';
  frame.style.width='900px';frame.style.height='700px';
  document.body.appendChild(frame);
 });
 const iframe=page.frameLocator('#edith-map-frame');
 await iframe.locator('#edithLiveToggle').waitFor({timeout:45000});
 await page.waitForFunction(()=>/Cartografía cargada: 72 municipios/.test(document.querySelector('#edith-map-frame')?.contentDocument?.getElementById('detail')?.textContent||''),{timeout:45000});
 await page.evaluate(()=>document.getElementById('edith-map-frame').contentWindow.postMessage({
  type:'EDITH_MAP_DATA',
  rows:[{year:2026,municipality_code:'030',cases:6,suppressed:false}],
  generated_at:'2026-11-09T12:00:00Z',scope:'ADMINISTRADOR_ESTATAL'
 },location.origin));
 await page.waitForFunction(()=>document.querySelector('#edith-map-frame')?.contentDocument?.getElementById('edithLiveToggle')?.textContent==='Volver al corte público',{timeout:10000});
 await page.evaluate(()=>document.getElementById('edith-map-frame').contentWindow.postMessage({type:'EDITH_MAP_REVOKE'},location.origin));
 await page.waitForFunction(()=>document.querySelector('#edith-map-frame')?.contentDocument?.getElementById('edithLiveToggle')?.disabled===true,{timeout:10000});
 const message=await iframe.locator('#edithLiveNotice').innerText();
 assert.match(message,/desconectada/i);
 log('Puente de mensajes de mismo origen y revocación de datos institucionales');
 await page.close();
} finally {
 await browser.close();
}
console.log('✅ Pruebas de rutas, mapa, móvil y revocación concluidas');
