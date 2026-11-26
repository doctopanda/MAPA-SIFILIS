// Real Fetch/crypto in Node; mock only the Durable Object storage/runtime.
// Sequential synthetic contract tests; not a Cloudflare or browser integration test.
import assert from 'node:assert/strict';
import worker,{SyncHub} from '../lab/skynet_stable_v06.mjs';
const records=new Map();
let alarm=null;
const storage={
 async transaction(fn){return fn(this)},
 async get(k){return structuredClone(records.get(k))},
 async put(k,v){records.set(k,structuredClone(v))},
 async getAlarm(){return alarm},
 async setAlarm(t){alarm=t},
};
const hub=new SyncHub({storage});
const env={SYNC:{idFromName:n=>n,get:()=>({fetch:r=>hub.fetch(r)})}};
const origin='https://synthetic.example';
let now=Date.parse('2026-11-26T15:00:00Z');
const actualNow=Date.now;
Date.now=()=>now;
let checks=0;
const eq=(a,b)=>{assert.deepEqual(a,b);checks++};
async function api(cmd,extra={},opts={}){
 const req=new Request(origin+'/api',{method:'POST',headers:{Origin:origin,'Content-Type':'application/json',...opts},body:JSON.stringify({cmd,...extra})});
 const res=await worker.fetch(req,env);
 return {status:res.status,body:await res.json()};
}
try{
 const app=await (await worker.fetch(new Request(origin+'/gestapp'),env)).text();
 const platform=await (await worker.fetch(new Request(origin+'/gestason'),env)).text();
 eq(app.includes("location.pathname==='/gestapp'?'patient':location.pathname==='/gestason'?'doctor'"),true);
 eq(platform.includes("location.origin+'/gestason#'+session.room"),true);
 eq((await api('new',{synthetic:true},{Origin:'https://foreign.example'})).status,403);
 eq((await api('new',{synthetic:false})).status,400);
 const p=(await api('new',{synthetic:true})).body;
 eq(p.ok,true);eq(p.expires,now+8*60*60000);
 eq(/^[a-f0-9]{32}$/.test(p.room),true);eq(/^[a-f0-9]{64}$/.test(p.token),true);
 const patient={room:p.room,token:p.token};
 const declaration={curp:'CURP-DEMO-A',nombres:'Paciente DEMO A',peso_previo_kg:60,talla_m:1.62};
 eq((await api('profile',{...patient,expectedRev:0,profile:declaration})).body.profileRev,1);
 eq((await api('profile',{...patient,expectedRev:1,profile:{nombres:'arbitrary'}})).status,409);
 const diary={day:1,weight:68.2,sys:120,dia:75,headache:true,edema:false,nausea:null,visual:null};
 eq((await api('diary',{...patient,record:diary})).status,200);
 eq((await api('diary',{...patient,record:diary})).status,409);
 now+=31*60000;
 eq((await api('patient',patient)).body.profile.nombres,declaration.nombres);
 eq((await api('request',{room:p.room,synthetic:true,code:p.code})).status,403);
 const renewed=(await api('issue',patient)).body;
 eq(renewed.profileRev,1);
 eq(renewed.diary[0].weight,68.2);
 const request=(await api('request',{room:p.room,synthetic:true,code:renewed.code})).body;
 eq(request.state,'PENDING');
 const doctor={room:p.room,token:request.token};
 eq((await api('doctor',doctor)).body.profile,undefined);
 eq((await api('approve',{...patient,challenge:request.challenge,diary:true,profile:true})).body.grantUntil,now+30*60000);
 const linked=(await api('doctor',doctor)).body;
 eq(linked.profile.nombres,declaration.nombres);
 eq(linked.diary[0].weight,68.2);
 eq((await api('profile',{...doctor,expectedRev:1,profile:{}})).status,403);
 const clinical={day:1,weight:68.9,sys:116,dia:74,glucose:89,fundal:25,fhr:145,details:{hemoglobina:11.8,plan_seguridad:false}};
 const visit=(await api('clinical',{...doctor,record:clinical})).body;
 eq(visit.clinical[0].weight,68.9);eq(visit.diary[0].weight,68.2);
 eq((await api('clinical_profile',{...doctor,expectedRev:0,patientRev:1,profile:{nombres:'Paciente DEMO B'}})).body.clinicalProfile.nombres,'Paciente DEMO B');
 eq((await api('patient',patient)).body.profile.nombres,declaration.nombres);
 const note=(await api('note',{...doctor,day:1,text:'Completar campos pendientes del tarjetón',author:'MEDICO_DEMO'})).body;
 eq(note.notes.length,1);
 now+=30*60000;
 eq((await api('doctor',doctor)).status,403);
 eq((await api('patient',patient)).body.diary[0].weight,68.2);
 const another=(await api('issue',patient)).body;
 const req2=(await api('request',{room:p.room,synthetic:true,code:another.code})).body;
 const doctor2={room:p.room,token:req2.token};
 eq(req2.state,'PENDING');
 eq((await api('approve',{...patient,challenge:req2.challenge,diary:false,profile:false})).status,200);
 const limited=(await api('doctor',doctor2)).body;
 eq(limited.profile,null);eq(limited.diary,[]);eq(limited.notes.length,1);
 eq((await api('doctor',doctor)).status,403);
 eq((await api('revoke',patient)).status,200);
 eq((await api('doctor',doctor2)).status,403);
 eq((await api('patient',patient)).body.clinical[0].weight,68.9);
 now=p.expires;
 eq((await api('patient',patient)).status,404);
 console.log('SKYNET v0.6 mock-storage Fetch/crypto checks: '+checks+' PASS');
}finally{Date.now=actualNow}
