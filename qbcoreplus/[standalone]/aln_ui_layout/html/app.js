const root=document.getElementById('root')
const overlay=document.getElementById('overlay')
let anchors=[]
let positions={}
let drag=null

function post(name,data){fetch(`https://${GetParentResourceName()}/${name}`,{method:'POST',body:JSON.stringify(data||{})})}

window.addEventListener('message',e=>{
 const d=e.data
 if(d.action==='setEditing'){
  if(d.enabled){
   anchors=d.anchors
   root.classList.remove('hidden')
   overlay.innerHTML=''
   anchors.forEach(a=>{
    const el=document.createElement('div')
    el.className='anchor'
    el.textContent=a.label
    el.style.left=(a.x*window.innerWidth)+'px'
    el.style.top=(a.y*window.innerHeight)+'px'
    el.onpointerdown=ev=>drag={id:a.id,el,ox:ev.offsetX,oy:ev.offsetY}
    overlay.appendChild(el)
   })
  } else {
   root.classList.add('hidden')
   overlay.innerHTML=''
  }
 }
})

window.onpointermove=e=>{
 if(!drag)return
 let x=e.clientX-drag.ox
 let y=e.clientY-drag.oy
 drag.el.style.left=x+'px'
 drag.el.style.top=y+'px'
 positions[drag.id]={x:x/window.innerWidth,y:y/window.innerHeight}
 post('setPos',{id:drag.id,x:positions[drag.id].x,y:positions[drag.id].y})
}

window.onpointerup=()=>drag=null

function save(){post('save',{positions})}
function closeUI(){post('close')}
