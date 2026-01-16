let renderer, scene, camera, dice, dice2;
let edges, edgesGlow, edges2, edgesGlow2;
const overlay = document.getElementById('overlay');
const canvas = document.getElementById('dice-canvas');
const rollText = document.getElementById('rollText');
const dcText   = document.getElementById('dcText');
const outcome  = document.getElementById('outcome');
const darkStingEl = document.getElementById('darkSting');
const modeBadge = document.getElementById('modeBadge');
const rollsInfo = document.getElementById('rollsInfo');

let animStart=0, animDuration=3000, holdMs=2200;
let spinning=false, ready=false;
const rollQueue=[];
let targetQuat1=null, targetQuat2=null;
let faces1=null, faces2=null;

function hexToInt(hex){ try{ return parseInt(String(hex).replace('#',''),16); }catch(e){ return 0xd4af37; } }
function roman(n){
  const map = [[1000,'M'],[900,'CM'],[500,'D'],[400,'CD'],[100,'C'],[90,'XC'],[50,'L'],[40,'XL'],[10,'X'],[9,'IX'],[5,'V'],[4,'IV'],[1,'I']];
  let s=''; for(let i=0;i<map.length;i++){ const v=map[i][0], r=map[i][1]; while(n>=v){ s+=r; n-=v; } } return s;
}
function materialForSkin(name){
  const nm = (name||'obsidian').toLowerCase();
  if(nm==='gold'){   return new THREE.MeshStandardMaterial({ color: 0xffd76a, metalness: 1.0, roughness: 0.18, envMapIntensity: 1.2 }); }
  if(nm==='arcane'){ return new THREE.MeshStandardMaterial({ color: 0x3a2e55, metalness: 0.6, roughness: 0.35, emissive: 0x372b67, emissiveIntensity: 0.06, envMapIntensity: 0.9 }); }
  if(nm==='marble'){ return new THREE.MeshStandardMaterial({ color: 0xe8e6e1, metalness: 0.05, roughness: 0.35, envMapIntensity: 0.8 }); }
  return new THREE.MeshStandardMaterial({ color: 0x1a1b20, metalness: 0.8, roughness: 0.25, envMapIntensity: 1.0 });
}

function setLocale(code){ if (window.__I18N){ window.__I18N.setLanguage(code||'en'); } }
function T(key,...args){ return window.__I18N ? window.__I18N.t(key,...args) : key; }

const SFX = { roll: new Audio(), success: new Audio(), fail: new Audio(), nat20: new Audio(), nat1: new Audio() };
function pickSrc(aud, name){
  const ogg = "sfx/"+name+".ogg"; const wav = "sfx/"+name+".wav";
  aud.src = ogg; aud.loop = (name === 'roll_loop'); aud.volume = (name === 'roll_loop') ? 0.45 : 0.7;
  aud.onerror = function(){ aud.onerror=null; aud.src=wav; aud.load(); };
  aud.load();
}
pickSrc(SFX.roll,'roll_loop'); pickSrc(SFX.success,'success'); pickSrc(SFX.fail,'fail'); pickSrc(SFX.nat20,'nat20'); pickSrc(SFX.nat1,'nat1');
function sfxStartRoll(){ try{ SFX.roll.currentTime = 0; SFX.roll.play(); }catch(e){} }
function sfxStopRoll(){ try{ SFX.roll.pause(); }catch(e){} }
function sfxOutcome(ok, raw){ try{ const sp=(raw===20?SFX.nat20:(raw===1?SFX.nat1:null)); if(sp){ sp.currentTime=0; sp.play(); return;} const a=ok?SFX.success:SFX.fail; a.currentTime=0; a.play(); }catch(e){} }

function ensureThreeLoaded(cb){
  if (window.THREE){ cb && cb(); return; }
  const script = document.createElement('script');
  script.src = 'https://unpkg.com/three@0.157.0/build/three.min.js';
  script.onload = function(){ cb && cb(); };
  script.onerror = function(){ console.warn('Could not load Three.js'); };
  document.head.appendChild(script);
}

function buildFaces(geo){
  const faces=[]; const pos=geo.attributes.position;
  for(let i=0;i<pos.count;i+=3){
    const a=new THREE.Vector3().fromBufferAttribute(pos,i);
    const b=new THREE.Vector3().fromBufferAttribute(pos,i+1);
    const c=new THREE.Vector3().fromBufferAttribute(pos,i+2);
    const centroid=new THREE.Vector3().addVectors(a,b).add(c).multiplyScalar(1/3);
    const normal=new THREE.Vector3().subVectors(b,a).cross(new THREE.Vector3().subVectors(c,a)).normalize();
    if(normal.dot(centroid)<0) normal.multiplyScalar(-1);
    faces.push({number:i/3+1, centroid, normal});
  }
  return faces;
}
function faceLabelMaterial(n){
  const size=128, cnv=document.createElement('canvas'); cnv.width=cnv.height=size;
  const ctx=cnv.getContext('2d'); ctx.clearRect(0,0,size,size);
  ctx.font='900 86px serif'; ctx.textAlign='center'; ctx.textBaseline='middle';
  ctx.fillStyle='#ffffff'; ctx.shadowColor='rgba(0,0,0,0.55)'; ctx.shadowBlur=10; ctx.shadowOffsetY=4;
  const label = (window.__DICE_NUMERALS==='roman') ? roman(n) : String(n);
  ctx.fillText(label, size/2, size/2+3);
  const tex=new THREE.CanvasTexture(cnv); tex.anisotropy=8;
  return new THREE.MeshBasicMaterial({ map: tex, transparent:true, side:THREE.DoubleSide });
}
function makeDie(radius, opts){
  radius = radius || 0.6; opts = opts || {};
  const geo = new THREE.IcosahedronGeometry(radius, 0);
  const mat = materialForSkin(opts.skin || 'obsidian');
  const m = new THREE.Mesh(geo, mat);
  const e = new THREE.LineSegments(new THREE.EdgesGeometry(geo), new THREE.LineBasicMaterial({ color: hexToInt(opts.edgeColor || '#d4af37') }));
  m.add(e);
  const eg = new THREE.LineSegments(new THREE.EdgesGeometry(geo), new THREE.LineBasicMaterial({ color: 0xffffcc, transparent:true, opacity:0, blending:THREE.AdditiveBlending }));
  eg.scale.multiplyScalar(1.004);
  m.add(eg);
  const fcs = buildFaces(geo);
  for(let k=0;k<fcs.length;k++){
    const f = fcs[k];
    const matTxt = faceLabelMaterial(f.number);
    const plane = new THREE.Mesh(new THREE.PlaneGeometry(0.3,0.3), matTxt);
    const offset = f.normal.clone().multiplyScalar(0.055);
    plane.position.copy(f.centroid.clone().add(offset));
    const faceUp=new THREE.Vector3(0,0,1);
    const q=new THREE.Quaternion().setFromUnitVectors(faceUp, f.normal.clone().normalize());
    plane.setRotationFromQuaternion(q);
    m.add(plane);
  }
  return {mesh:m, edges:e, glow:eg, faces:fcs};
}

function init(){
  if (!window.THREE){ console.warn('THREE not found'); return; }
  renderer = new THREE.WebGLRenderer({canvas, antialias:true, alpha:true});
  renderer.setClearColor(0x000000, 0);
  scene = new THREE.Scene();
  camera = new THREE.PerspectiveCamera(35, 1, 0.1, 100);
  camera.position.set(0, 1.1, 5.2); camera.lookAt(0,0,0);
  scene.add(new THREE.HemisphereLight(0xffffff, 0x222244, 0.95));
  const dir1 = new THREE.DirectionalLight(0xffffff, 0.85); dir1.position.set(2.6,3.4,2.4); scene.add(dir1);
  const rim = new THREE.DirectionalLight(0x96a8ff, 0.35); rim.position.set(-2,1,-2); scene.add(rim);
  onResize(); window.addEventListener('resize', onResize);
  ready=true; requestAnimationFrame(tick);
  while(rollQueue.length){ startRoll(rollQueue.shift()); }
}
function onResize(){
  if(!renderer) return;
  const rect=canvas.parentElement.getBoundingClientRect();
  const w=Math.max(1,rect.width), h=Math.max(1,rect.height);
  renderer.setPixelRatio(window.devicePixelRatio||1); renderer.setSize(w,h,false);
  if(camera){ camera.aspect=w/h; camera.updateProjectionMatrix(); }
}
function showOverlay(){ overlay.style.display='flex'; onResize(); }
function hideOverlay(){ overlay.style.display='none'; }

function quatFaceTowardCamera(normal){
  const camPos = new THREE.Vector3(); camera.getWorldPosition(camPos);
  const toCam = camPos.clone().normalize();
  const from = normal.clone().normalize();
  const q = new THREE.Quaternion().setFromUnitVectors(from, toCam);
  const twist = new THREE.Quaternion().setFromAxisAngle(toCam, (Math.random()-0.5)*0.4);
  return q.multiply(twist);
}

let celebLight = null;
function ensureCelebLight(){
  if (!celebLight){ celebLight = new THREE.PointLight(0xffffff, 0, 6); celebLight.position.set(0,1.2,1.2); scene.add(celebLight); }
}
function pulseLight(colorHex, maxI, dur){
  ensureCelebLight(); maxI=maxI||2.2; dur=dur||500;
  celebLight.color.setHex(colorHex); celebLight.intensity = 0;
  const start = performance.now();
  (function step(){
    const t = performance.now() - start; const k = Math.min(1, t/dur);
    const val = (k<0.5 ? (k/0.5) : (1-(k-0.5)/0.5));
    celebLight.intensity = val * maxI;
    if (k < 1){ requestAnimationFrame(step); } else { celebLight.intensity = 0; }
  })();
}
function pulseGlint(targetGlow, duration, maxO){
  if(!targetGlow) return; duration=duration||1400; maxO=maxO||0.9;
  const start = performance.now(); targetGlow.material.opacity = 0;
  (function step(){
    const t = (performance.now()-start)/duration;
    if (t>=1){ targetGlow.material.opacity = 0; return; }
    const wave = Math.sin(Math.PI * (t*2)) * (t<0.5 ? (t/0.5) : (1 - (t-0.5)/0.5));
    targetGlow.material.opacity = Math.max(0, wave) * maxO;
    requestAnimationFrame(step);
  })();
}

function clearDice(){
  if(dice){ scene.remove(dice); } if(dice2){ scene.remove(dice2); }
  dice=dice2=edges=edgesGlow=edges2=edgesGlow2=null; faces1=faces2=null; targetQuat1=targetQuat2=null;
}

window.addEventListener('message', function(e){
  const data = e.data || {}; const action=data.action; const payload=data.payload;
  if(action==='roll3d'){
    if(payload && payload.locale){ setLocale(payload.locale); }
    if(!ready){ ensureThreeLoaded(function(){ init(); }); rollQueue.push(payload); }
    else { startRoll(payload); }
  } else if(action==='close'){ hideOverlay(); }
});

function startRoll(p){
  animDuration = (typeof p.rollMs==='number')? p.rollMs : 3000;
  holdMs = (typeof p.holdMs==='number')? p.holdMs : 2200;
  window.__DICE_NUMERALS = (p.numerals || 'arabic');
  const skin = p.skin || 'obsidian';
  const edgeColor = p.edgeColor || '#d4af37';

  rollText.textContent = T('dash');
  dcText.textContent = (p.dc!==null && p.dc!==undefined) ? T('dc', p.dc) : '';
  outcome.textContent = T('rolling'); outcome.style.color = '#f2e6c9';
  document.querySelector('.title').textContent = T('title');
  if(p.mode && p.mode!=='normal'){ modeBadge.style.display='inline-block'; modeBadge.textContent = (p.mode==='adv'?T('advantage'):T('disadvantage')); } else { modeBadge.style.display='none'; }
  if(rollsInfo){ rollsInfo.style.display='none'; rollsInfo.textContent=''; }

  showOverlay(); clearDice();

  const d1 = makeDie(0.56, {skin, edgeColor}); dice = d1.mesh; scene.add(dice); edges = d1.edges; edgesGlow = d1.glow; faces1 = d1.faces;
  let q1=null, q2=null; const isDual = (p.mode==='adv' || p.mode==='dis');
  if(isDual){
    const d2 = makeDie(0.56, {skin, edgeColor}); dice2 = d2.mesh; scene.add(dice2); edges2 = d2.edges; edgesGlow2 = d2.glow; faces2 = d2.faces;
    dice.position.x = -0.65; dice2.position.x = 0.65;
    const f1 = faces1.find(function(ff){ return ff.number===p.r1; });
    const f2 = faces2.find(function(ff){ return ff.number===p.r2; });
    q1 = f1 ? quatFaceTowardCamera(f1.normal) : new THREE.Quaternion();
    q2 = f2 ? quatFaceTowardCamera(f2.normal) : new THREE.Quaternion();
  } else {
    const f = faces1.find(function(ff){ return ff.number===p.raw; });
    q1 = f ? quatFaceTowardCamera(f.normal) : new THREE.Quaternion();
  }
  targetQuat1 = q1; targetQuat2 = q2;

  sfxStartRoll();
  animStart = performance.now(); spinning = true;

  setTimeout(function(){
    spinning = false; sfxStopRoll();
    if(isDual){
      dice.setRotationFromQuaternion(targetQuat1); dice2.setRotationFromQuaternion(targetQuat2);
      const winnerIsD1 = ( (p.mode==='adv' && p.r1>=p.r2) || (p.mode==='dis' && p.r1<=p.r2) );
      if(winnerIsD1){ pulseGlint(edgesGlow,1400,1.0); if(edges2) edges2.material.opacity = 0.1; }
      else { pulseGlint(edgesGlow2,1400,1.0); if(edges) edges.material.opacity = 0.1; }
      if(rollsInfo){ rollsInfo.style.display='block'; rollsInfo.textContent = T('rolls', p.r1, p.r2) + "  " + T('picked', p.raw); }
    } else {
      dice.setRotationFromQuaternion(targetQuat1);
      if(rollsInfo){ rollsInfo.style.display='none'; }
    }

    rollText.textContent = String(p.raw) + (p.modifier ? (p.modifier>0? " +" + p.modifier : " " + p.modifier) : "") + " = " + String(p.total);
    if (p.dc !== null && p.dc !== undefined){
      const ok = (p.dc!=null && p.dc>20) ? (p.raw===20) : (p.total >= p.dc);
      outcome.textContent = ok ? T('success') : T('fail');
      outcome.style.color = ok ? 'var(--pass)' : 'var(--fail)';
      if (p.raw===20){ pulseLight(0x8cffb2, 3.0, 700); pulseGlint(edgesGlow,1400); }
      else if (p.raw===1){ if(darkStingEl){ darkStingEl.style.transition='opacity 140ms ease-out'; darkStingEl.style.opacity='1'; setTimeout(function(){ darkStingEl.style.transition='opacity 380ms ease-in'; darkStingEl.style.opacity='0'; }, 420); } pulseLight(0xff6a6a, 2.8, 700); }
      sfxOutcome(ok, p.raw);
    } else { outcome.textContent = T('title'); }
    try { fetch('https://bg3_dice/finished', {method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ success: (p.dc!=null? ((p.dc>20)? (p.raw===20) : (p.total>=p.dc)) : true), total: p.total, raw: p.raw })}); } catch(e) {}
    setTimeout(function(){ hideOverlay(); }, holdMs);
  }, animDuration);
}

function tick(){
  if(!renderer){ return; }
  requestAnimationFrame(tick);
  if(spinning){
    const t=Math.min(1,(performance.now()-animStart)/animDuration);
    const phase=t<0.72?(t/0.72):((t-0.72)/0.28);
    const axis=new THREE.Vector3(0.22,1,0.18).normalize();
    const ang=(Math.PI*10)*(t<0.72?phase:1);
    const qTmp=new THREE.Quaternion().setFromAxisAngle(axis,ang);
    if(dice){ dice.setRotationFromQuaternion(qTmp); }
    if(dice2){ dice2.setRotationFromQuaternion(qTmp); }
    if(t>=0.72){
      const e=1-Math.pow(1 - ((t-0.72)/0.28), 3);
      if(targetQuat1 && dice) dice.quaternion.slerp(targetQuat1, e);
      if(targetQuat2 && dice2) dice2.quaternion.slerp(targetQuat2, e);
    }
  }
  renderer.render(scene,camera);
}
