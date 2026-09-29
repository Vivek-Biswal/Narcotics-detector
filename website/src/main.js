import { exportFile, isNative } from './platform';
import { authTransition, loginErrorMessage } from './auth-state';
import './style.css';
import QRCode from 'qrcode';
import { supabase, signIn, googleSignIn, getRecords } from './api';
import { sampleRecords, filterRecords, hashImage, csv } from './records';
import {icon,esc,refreshIcons,brand,pages,shell,overview,recordTable,badge,date,time} from './ui';
import {history,capture,verify,settings,guide,login} from './pages';
const app=document.querySelector('#app'),dialog=document.querySelector('#detail-dialog');
const state={page:location.hash.slice(1).split('?')[0]||'overview',user:null,demo:false,records:[],query:'',filter:'ALL',loading:false,error:'',capture:null,stream:null,location:null,operator:'',reference:false,theme:localStorage.getItem('narctrace-theme')||'light'};
let toastTimer;
function toast(message){const el=document.querySelector('#toast');el.textContent=message;el.classList.add('show');clearTimeout(toastTimer);toastTimer=setTimeout(()=>el.classList.remove('show'),5000);}
function setTheme(theme){state.theme=theme;localStorage.setItem('narctrace-theme',theme);document.documentElement.dataset.theme=theme;}
setTheme(state.theme);
function navigate(page){if(!pages[page]&&page!=='login')page='overview';stopCamera();state.page=page;state.query='';state.filter='ALL';location.hash=page;render();window.scrollTo(0,0);}
function render(){if(!pages[state.page]&&state.page!=='login')state.page='overview';app.innerHTML=state.page==='login'?login(state):shell(state,({overview,history,capture,verify,settings,guide})[state.page](state));refreshIcons();bind();syncNavigation();if(state.page==='history')bindSearch();if(state.page==='capture')bindCapture();if(state.page==='verify')bindVerify();if(state.page==='login')bindLogin();}
function bind(){document.querySelectorAll('[data-page]').forEach(el=>el.onclick=()=>navigate(el.dataset.page));document.querySelectorAll('[data-theme]').forEach(el=>el.onclick=()=>{stopCamera();setTheme(el.dataset.theme);render();});bindRecordButtons();document.querySelectorAll('[data-action]').forEach(el=>el.onclick=async()=>{switch(el.dataset.action){
case 'theme':stopCamera();setTheme(state.theme==='light'?'dark':'light');if(state.page==='login'){el.innerHTML=icon(state.theme==='light'?'moon':'sun');refreshIcons();}else render();break;
case 'menu':document.querySelector('.sidebar').classList.toggle('open');syncNavigation();break;
case 'account':if(state.user){const {error}=await supabase.auth.signOut();if(error){toast(error.message);break;}clearPrivateState();}navigate('login');break;
case 'samples':state.demo=!state.demo;state.records=state.demo?[...state.records.filter(r=>r.local),...sampleRecords]:state.records.filter(r=>r.local);render();break;
case 'export':{const rows=filterRecords(state.records,state.query,state.filter);if(!rows.length){toast('No records to export.');break;}download(csv(rows),'narctrace-records.csv','text/csv');break;}
case 'clear-search':state.query='';state.filter='ALL';render();break;
case 'retry':await loadRecords();break;
case 'camera':await openCamera();break;
case 'location':captureLocation();break;
}});}
function syncNavigation(){const sidebar=document.querySelector('.sidebar');if(!sidebar)return;const closed=matchMedia('(max-width:760px)').matches&&!sidebar.classList.contains('open');sidebar.inert=closed;document.querySelector('.mobile-menu')?.setAttribute('aria-expanded',String(!closed));}
window.addEventListener('resize',syncNavigation);
document.querySelector('.skip-link').onclick=e=>{e.preventDefault();document.querySelector('#main')?.focus();};
function bindRecordButtons(){document.querySelectorAll('[data-record]').forEach(el=>el.onclick=()=>openRecord(el.dataset.record));}
function bindSearch(){const search=document.querySelector('#record-search'),select=document.querySelector('#result-filter');select.value=state.filter;const update=()=>{state.query=search.value;state.filter=select.value;const rows=filterRecords(state.records,state.query,state.filter);document.querySelector('#table-content').innerHTML=recordTable(state,rows);document.querySelector('#result-count').textContent=`${rows.length} matching records`;refreshIcons();bindRecordButtons();document.querySelector('[data-action="clear-search"]')?.addEventListener('click',()=>{state.query='';state.filter='ALL';render();});};search.oninput=update;select.onchange=update;}
async function download(data,name,type){try{await exportFile(data,name,type);}catch(error){toast(error.message||'Export could not be completed.');}}
function clearPrivateState(){state.records.forEach(r=>{if(r.preview)URL.revokeObjectURL(r.preview);});if(state.capture)URL.revokeObjectURL(state.capture.url);state.user=null;state.records=[];state.capture=null;state.location=null;state.operator='';state.reference=false;state.demo=false;}
async function loadRecords(){if(!state.user)return;const userId=state.user.id;state.loading=true;state.error='';render();try{const records=await getRecords(userId);if(state.user?.id===userId)state.records=[...state.records.filter(r=>r.local),...records];}catch(error){if(state.user?.id===userId)state.error=error.message;}finally{state.loading=false;render();}}
function bindLogin(){
  const form=document.querySelector('#login-form');
  const email=form.querySelector('#email'),password=form.querySelector('#password');
  const submit=form.querySelector('button[type="submit"]'),google=document.querySelector('#google-signin');
  const errorBox=document.querySelector('#login-error');
  let busy=false;
  const setBusy=value=>{busy=value;submit.disabled=value;google.disabled=value;form.setAttribute('aria-busy',String(value));};
  form.onsubmit=async e=>{
    e.preventDefault();if(busy)return;
    if(!form.reportValidity())return;
    setBusy(true);submit.textContent='Signing in…';errorBox.textContent='';
    try{
      const {user}=await signIn(email.value.trim(),password.value);
      if(!user)throw new Error('No session was returned. Please try signing in again.');
      const changed=state.user?.id!==user.id;
      state.user=user;state.demo=false;state.records=state.records.filter(r=>r.local);
      navigate('overview');if(changed)await loadRecords();
    }catch(error){if(form.isConnected){errorBox.textContent=loginErrorMessage(error);password.value='';}}
    finally{if(form.isConnected){setBusy(false);submit.innerHTML=`Sign in${icon('arrow-right')}`;refreshIcons();}}
  };
  google.onclick=async()=>{
    if(busy)return;setBusy(true);errorBox.textContent='';
    try{if(isNative)throw new Error('Google sign-in is not configured for this Android preview. Please use your registered email account.');await googleSignIn();}
    catch(error){if(form.isConnected)errorBox.textContent=loginErrorMessage(error);}
    finally{if(form.isConnected)setBusy(false);}
  };
  document.querySelector('#show-password').onclick=()=>{
    password.type=password.type==='password'?'text':'password';
    document.querySelector('#show-password').setAttribute('aria-label',password.type==='password'?'Show password':'Hide password');
  };
}
async function openRecord(id){const record=state.records.find(r=>r.id===id);if(!record)return;dialog.innerHTML=`<div class="dialog-heading"><div><div class="eyebrow">${record.sample?'ILLUSTRATIVE SAMPLE':record.local?'UNSIGNED CAPTURE DRAFT':'DIGITAL RECORD'}</div><h2 id="dialog-title">${esc(record.test_id)}</h2></div><button class="icon-button" id="close-dialog" aria-label="Close record">${icon('x')}</button></div><div class="dialog-content"><div class="detail-status">${badge(record.result)}<span class="pill">${record.sample?'Sample · Not evidence':record.local?'Not signed':'Not independently verified'}</span></div>${record.preview?`<img class="detail-image" src="${record.preview}" alt="Original test capture">`:''}<dl class="metadata"><div><dt>Operator</dt><dd>${esc(record.operator_id)}</dd></div><div><dt>Captured</dt><dd>${date(record.captured_at)} · ${time(record.captured_at)}</dd></div><div><dt>Location</dt><dd>${record.latitude!=null?`${Number(record.latitude).toFixed(5)}, ${Number(record.longitude).toFixed(5)}`:'Not captured'}</dd></div><div><dt>Classification</dt><dd>${esc(record.classification_method||'Not performed')}</dd></div><div><dt>Digital signature</dt><dd>${record.signature?'Present · Verification required':'Not signed'}</dd></div></dl><div class="hash-block"><span>IMAGE FINGERPRINT · SHA-256</span><code>${esc(record.image_sha256||'No original image hash — illustrative sample.')}</code>${record.image_sha256?'<button class="text-link" id="copy-hash">Copy fingerprint</button>':''}</div><div class="record-qr"><canvas id="record-qr"></canvas><p>Record identifier<small>A QR code does not verify authenticity.</small></p></div><div class="notice">${icon('info')}<p>${record.sample?'This sample demonstrates the interface. It is not a real test or signed record.':'Image hashes detect file changes; they do not replace a trusted digital signature or laboratory confirmation.'}</p></div></div><div class="dialog-footer">${record.preview?`<a class="button secondary" href="${record.preview}" download="${esc(record.image_name)}">${icon('download')}Original image</a>`:''}<button class="button secondary" id="record-export">${icon('download')}Export ${record.sample?'sample':'record'} JSON</button><button class="button primary" id="record-check">Check image hash${icon('arrow-right')}</button></div>`;dialog.showModal();refreshIcons();if(isNative&&record.preview){dialog.querySelector('a[download]').onclick=async e=>{e.preventDefault();try{await download(await (await fetch(record.preview)).blob(),record.image_name,'application/octet-stream');}catch(error){toast(error.message);}};}document.querySelector('#close-dialog').onclick=()=>dialog.close();document.querySelector('#record-export').onclick=()=>{const {preview,...exportable}=record;download(JSON.stringify(exportable,null,2),`${record.test_id}.json`,'application/json');};document.querySelector('#copy-hash')?.addEventListener('click',async()=>{try{await navigator.clipboard.writeText(record.image_sha256);toast('Fingerprint copied.');}catch{toast('Copy is unavailable. Select the fingerprint to copy it manually.');}});document.querySelector('#record-check').onclick=()=>{dialog.close();navigate('verify');document.querySelector('#expected-hash').value=record.image_sha256||'';};await QRCode.toCanvas(document.querySelector('#record-qr'),`NarcTrace ${record.local?'UNSIGNED DRAFT':record.sample?'SAMPLE':'RECORD'}: ${record.test_id}`,{width:100,margin:1,color:{dark:'#123d44',light:'#ffffff'}});}
function stopCamera(){state.stream?.getTracks().forEach(track=>track.stop());state.stream=null;}
async function openCamera(){try{stopCamera();const stream=await navigator.mediaDevices.getUserMedia({video:{facingMode:'environment'},audio:false});if(state.page!=='capture'){stream.getTracks().forEach(t=>t.stop());return;}state.stream=stream;document.querySelector('#capture-stage').innerHTML=`<video id="camera-video" autoplay playsinline muted></video><button class="shutter" id="take-photo" aria-label="Take photo">${icon('camera')}</button><button class="camera-close icon-button" id="stop-camera" aria-label="Close camera">${icon('x')}</button>`;document.querySelector('#camera-video').srcObject=stream;refreshIcons();document.querySelector('#stop-camera').onclick=()=>{stopCamera();render();};document.querySelector('#take-photo').onclick=()=>{const video=document.querySelector('#camera-video');if(!video.videoWidth)return toast('The camera is still starting.');const canvas=document.createElement('canvas');canvas.width=video.videoWidth;canvas.height=video.videoHeight;canvas.getContext('2d').drawImage(video,0,0);canvas.toBlob(async blob=>{stopCamera();if(blob)await setCapture(new File([blob],'camera-capture.jpg',{type:'image/jpeg'}),'camera');},'image/jpeg',0.95);};}catch(error){toast(error.name==='NotAllowedError'?'Camera access was denied. Allow access in your browser, or upload an image.':'No camera is available. You can upload an original test image.');}}
async function setCapture(file,source='upload'){if(!file)return;if(!['image/jpeg','image/png','image/webp'].includes(file.type))return toast('Please choose a JPG, PNG or WebP image.');if(file.size>15*1024*1024)return toast('Choose an image smaller than 15 MB.');try{const bitmap=await createImageBitmap(file);bitmap.close();const hash=await hashImage(file);if(state.capture?.url)URL.revokeObjectURL(state.capture.url);state.capture={file,hash,url:URL.createObjectURL(file),timestamp:new Date().toISOString(),source};state.reference=false;stopCamera();render();}catch{toast('This image could not be read. Try a different original file.');}}
function captureLocation(){if(!navigator.geolocation)return toast('Location is unavailable on this device.');document.querySelector('#location-state').textContent='Requesting location…';navigator.geolocation.getCurrentPosition(p=>{state.location={latitude:p.coords.latitude,longitude:p.coords.longitude,accuracy:p.coords.accuracy};const el=document.querySelector('#location-state');if(el)el.innerHTML=`${p.coords.latitude.toFixed(5)}, ${p.coords.longitude.toFixed(5)}<small>Accuracy ±${Math.round(p.coords.accuracy)} m</small>`;},()=>{const el=document.querySelector('#location-state');if(el)el.textContent='Location unavailable';toast('Location could not be captured. Check permission and try again.');},{enableHighAccuracy:true,timeout:15000,maximumAge:0});}
function bindCapture(){document.querySelector('#operator').oninput=e=>state.operator=e.target.value;document.querySelector('#reference-check').onclick=e=>{state.reference=!state.reference;e.currentTarget.setAttribute('aria-checked',String(state.reference));e.currentTarget.querySelector('.confirm-mark').innerHTML=state.reference?icon('check'):'';refreshIcons();};document.querySelector('#image-upload').onchange=e=>setCapture(e.target.files[0]);document.querySelector('#save-draft').onclick=async()=>{if(!state.capture)return toast('Capture or upload an image first.');const operator=document.querySelector('#operator').value.trim();if(!operator){toast('Enter your operator identifier.');return document.querySelector('#operator').focus();}if(!state.reference)return toast('Confirm that the reference card is included.');const {hash,file,timestamp,source}=state.capture;const record={id:crypto.randomUUID(),test_id:`DRAFT-${crypto.randomUUID().slice(0,8).toUpperCase()}`,operator_id:operator,captured_at:timestamp,timestamp_source:'Device clock; upload time for uploaded images',source,image_sha256:hash,image_name:file.name,result:null,classification_method:'Not performed',verification_status:'PENDING',signature:null,local:true,latitude:state.location?.latitude??null,longitude:state.location?.longitude??null,location_accuracy:state.location?.accuracy??null,preview:state.capture.url};state.records.unshift(record);state.capture=null;state.location=null;state.reference=false;navigate('history');toast('Unsigned capture saved in this tab. Export it before closing.');await openRecord(record.id);};}
function bindVerify(){document.querySelector('#verify-form').onsubmit=async e=>{e.preventDefault();const expected=document.querySelector('#expected-hash').value.trim().toLowerCase();if(!/^[a-f0-9]{64}$/.test(expected))return toast('Enter a valid 64-character hexadecimal SHA-256 hash.');const file=document.querySelector('#verify-image').files[0];if(file.size>15*1024*1024)return toast('Choose an image smaller than 15 MB.');e.submitter.disabled=true;try{const actual=await hashImage(file),match=actual===expected;document.querySelector('#verify-result').innerHTML=`<div class="verification-outcome ${match?'match':'mismatch'}">${icon(match?'circle-check':'circle-alert')}<h3>${match?'Image fingerprint matches':'Image fingerprint does not match'}</h3><p>${match?'The file matches the supplied fingerprint. The record’s signature has not been verified.':'This file differs from the supplied fingerprint. Check that you used the unmodified original.'}</p><code>${actual}</code></div>`;refreshIcons();}catch{toast('Unable to read the image. Please try again.');}finally{e.submitter.disabled=false;}};}
window.addEventListener('hashchange',()=>{const page=location.hash.slice(1).split('?')[0]||'overview';if(page!==state.page){stopCamera();state.page=pages[page]||page==='login'?page:'overview';render();}});
window.addEventListener('beforeunload',e=>{stopCamera();if(state.records.some(r=>r.local)||state.capture){e.preventDefault();e.returnValue='';}});
document.addEventListener('keydown',e=>{if(e.key==='/'&&!['INPUT','TEXTAREA'].includes(document.activeElement.tagName)){const search=document.querySelector('#record-search');if(search){e.preventDefault();search.focus();}}});
dialog.addEventListener('click',e=>{if(e.target===dialog)dialog.close();});
render();
supabase.auth.onAuthStateChange((event,session)=>{
  const transition=authTransition(event,session,state.user);
  if(transition==='signed-out'){clearPrivateState();navigate('login');}
  else if(transition==='signed-in'){
    const userId=session.user.id;
    state.user=session.user;state.demo=false;
    // Run data requests after the synchronous auth callback releases its lock.
    setTimeout(()=>{if(state.user?.id!==userId)return;if(state.page==='login')navigate('overview');loadRecords();},0);
  }
});



