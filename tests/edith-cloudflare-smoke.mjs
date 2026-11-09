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
 // Se intercepta exclusivamente el HTML servido a este navegador CI para
 // habilitar una sesión sintética; el repositorio y Cloudflare no cambian.
 await page.route(origin+'/',async route=>{
   const response=await route.fetch();
   const raw=await response.text();
   const needle='wireCore();renderHeader();renderMain();';
   assert.ok(raw.includes(needle),'El shell EDITH conserva inicialización');
   const inject=`window.__edithTestActivate=()=>{
     state.demo=false;
     state.user={id:'synthetic-ci-user'};
     state.client={
       rpc:async(name)=>{
         if(name==='edith_sc_mapa_residencia_v1'){
           window.__mapRpcCalls++;
           return {data:{schema:'EDITH_SC_MAPA_RLS_V1',
             rows:[{year:2026,municipality_code:'030',cases:6,suppressed:false},
                   {year:2026,municipality_code:'001',cases:null,suppressed:true}],
             generated_at:'2026-11-09T12:00:00Z',scope:'ADMINISTRADOR_ESTATAL'},error:null};
         }
         return {data:null,error:null};
       },
       auth:{signOut:async()=>({error:null})}
     };
   };
   `+needle;
   await route.fulfill({response,body:raw.replace(needle,inject)});
 });
 await page.goto(origin+'/',{waitUntil:'domcontentloaded'});
 assert.equal(await page.locator('dialog#login-dialog[open]').count(),1,'EDITH debe mostrar login institucional');
 const hidden=await page.evaluate(()=>!document.body.classList.contains('edith-authenticated'));
 assert.equal(hidden,true,'Interfaz clínica no debe abrirse sin login');
 log('Shell institucional protegido sin sesión');

 // Aislamiento de la sesión: stub sintético exclusivamente dentro del navegador CI.
 // Nunca se consultan datos nominales, usuarios, contraseñas ni tokens reales.
 await page.evaluate(()=>{
   document.getElementById('login-dialog').close();
   document.body.classList.add('edith-authenticated');
   window.__mapRpcCalls=0;
   window.__edithTestActivate();
 });
 await page.locator('[data-view="mapa"]').click();
 assert.equal(await page.locator('#edith-map-frame').count(),0,'EDITH no debe mostrar iframe incrustado');
 assert.equal(await page.locator('#edith-map-workspace').count(),0,'EDITH no debe abrir visor modal');
 assert.equal(await page.evaluate(()=>window.__mapRpcCalls),0,'No consultar agregados antes de abrir el mapa');
 const opened=page.waitForEvent('popup');
 await page.locator('#edith-map-open-workspace').click();
 const popup=await opened;
 await popup.waitForLoadState('domcontentloaded');
 assert.equal(new URL(popup.url()).pathname,'/mapa/','El mapa debe estar en ruta independiente');
 assert.equal(new URL(popup.url()).searchParams.get('institucional'),'1','Permitir puente institucional en pestaña separada');
 assert.equal(await popup.locator('header .brand h1').innerText(),'MAPA-SIFILIS','El mapa tiene cabecera propia');
 await popup.waitForFunction(()=>/Cartografía cargada: 72 municipios/.test(document.getElementById('detail')?.textContent||''),{timeout:45000});
 await popup.waitForFunction(()=>document.getElementById('edithLiveToggle')?.textContent==='Volver al corte público',{timeout:20000});
 assert.ok(await page.evaluate(()=>window.__mapRpcCalls)>=1,'La ventana verificada debe solicitar agregados al opener EDITH');
 assert.equal(await popup.locator('#edithLiveToggle').isDisabled(),false,'Se reciben datos agregados con permiso');
 log('MAPA-SÍFILIS en pestaña propia, 72 municipios y puente RLS sin credenciales');

 // Una ventana o pestaña distinta no debe disparar RPC institucional por sí sola.
 const beforeSpoof=await page.evaluate(()=>window.__mapRpcCalls);
 await page.evaluate(()=>window.postMessage({type:'EDITH_MAP_READY'},location.origin));
 await page.waitForTimeout(150);
 assert.equal(await page.evaluate(()=>window.__mapRpcCalls),beforeSpoof,'El opener ignora mensajes externos que no vienen del mapa');

 // Enlace público directo, sin opener institucional: sólo el corte público.
 const standalone=await browser.newPage({viewport:{width:1250,height:800}});
 await standalone.goto(origin+'/mapa/',{waitUntil:'domcontentloaded'});
 await standalone.waitForFunction(()=>/Cartografía cargada: 72 municipios/.test(document.getElementById('detail')?.textContent||''),{timeout:45000});
 assert.equal(await standalone.locator('#edithLiveToggle').isDisabled(),true,'La ruta pública no hereda sesión ni datos');
 await standalone.close();
 log('Mapa público separado y protegido del modo institucional');

 // Logout desde EDITH revoca datos en la otra pestaña.
 await page.evaluate(async()=>await document.getElementById('logout-btn').onclick());
 await popup.waitForFunction(()=>document.getElementById('edithLiveToggle')?.disabled===true,{timeout:10000});
 assert.match(await popup.locator('#edithLiveNotice').innerText(),/desconectada/i);
 log('La sesión revoca la información institucional en la ventana independiente');

 // La vista móvil es una página real, no un iframe con scroll duplicado.
 await popup.setViewportSize({width:390,height:844});
 assert.equal(await popup.locator('#map.leaflet-container').count(),1,'Mapa móvil sigue activo');
 const mobileWidth=await popup.evaluate(()=>({width:innerWidth,scroll:document.documentElement.scrollWidth}));
 assert.ok(mobileWidth.scroll<=mobileWidth.width+18,'No debe haber desbordamiento horizontal del mapa móvil');
 log('Mapa móvil en página propia');
 const returned=popup.waitForEvent('close',{timeout:10000});
 await popup.locator('#edithReturnLink').click();
 await returned;
 assert.equal(await page.locator('#edith-map-frame').count(),0,'EDITH sigue libre de mapas incrustados');
 log('Regreso a EDITH sin mapa embebido ni segundo login');
 await page.close();
} finally {
 await browser.close();
}
console.log('✅ Pruebas de rutas, mapa, móvil y revocación concluidas');
