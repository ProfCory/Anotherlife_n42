let moveMode = false;
let drag = { active: false, offsetX: 0, offsetY: 0 };
let state = { status: {}, show: {}, severity: { warn: 50, danger: 75 }, pos: { x: 0.86, y: 0.08 } };

const root = document.getElementById('root');
const controls = document.getElementById('move-controls');

const pills = {
  fatigue: document.getElementById('pill-fatigue'),
  drunk: document.getElementById('pill-drunk'),
  stoned: document.getElementById('pill-stoned'),
};

const vals = {
  fatigue: document.getElementById('val-fatigue'),
  drunk: document.getElementById('val-drunk'),
  stoned: document.getElementById('val-stoned'),
};

function applyPos() {
  root.style.left = `${state.pos.x * 100}vw`;
  root.style.top = `${state.pos.y * 100}vh`;
}

function setSeverity(el, v) {
  el.classList.remove('warn', 'danger');
  if (v >= state.severity.danger) el.classList.add('danger');
  else if (v >= state.severity.warn) el.classList.add('warn');
}

function render() {
  applyPos();

  let anyVisible = false;
  for (const k of Object.keys(pills)) {
    const v = Number(state.status[k] ?? 0);
    vals[k].textContent = `${Math.floor(v)}%`;

    const threshold = Number(state.show[k] ?? 999);
    const shouldShow = v >= threshold;

    pills[k].style.display = shouldShow ? 'flex' : 'none';
    if (shouldShow) {
      anyVisible = true;
      setSeverity(pills[k], v);
    }
  }

  // Show the row if any pill visible, or in move mode
  if (anyVisible || moveMode) root.classList.remove('hidden');
  else root.classList.add('hidden');

  controls.classList.toggle('hidden', !moveMode);
  root.style.cursor = moveMode ? 'move' : 'default';
}

function postNui(name, data) {
  fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data || {}),
  });
}

window.addEventListener('message', (event) => {
  const msg = event.data || {};
  if (msg.action === 'hide') {
    root.classList.add('hidden');
    return;
  }

  if (msg.action === 'update') {
    state.status = msg.status || {};
    state.show = msg.show || {};
    state.severity = msg.severity || state.severity;
    state.pos = msg.pos || state.pos;
    render();
    return;
  }

  if (msg.action === 'moveMode') {
    moveMode = !!msg.enabled;
    render();
    return;
  }
});

root.addEventListener('mousedown', (e) => {
  if (!moveMode) return;
  drag.active = true;
  const rect = root.getBoundingClientRect();
  drag.offsetX = e.clientX - rect.left;
  drag.offsetY = e.clientY - rect.top;
});

window.addEventListener('mousemove', (e) => {
  if (!moveMode || !drag.active) return;

  const vw = window.innerWidth;
  const vh = window.innerHeight;

  let x = (e.clientX - drag.offsetX) / vw;
  let y = (e.clientY - drag.offsetY) / vh;

  // clamp
  x = Math.max(0, Math.min(1, x));
  y = Math.max(0, Math.min(1, y));

  state.pos = { x, y };
  applyPos();
});

window.addEventListener('mouseup', () => {
  drag.active = false;
});

document.getElementById('btn-save').addEventListener('click', () => {
  postNui('savePos', state.pos);
});

document.getElementById('btn-exit').addEventListener('click', () => {
  postNui('exitMove', {});
});
