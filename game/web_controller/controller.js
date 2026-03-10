'use strict';

// ─── State ────────────────────────────────────────────────────────────────────
let ws = null;
let steering = 0;
let throttle = 0;
let brake = 0;
let drsActive = false;
let ersActive = false;
let gyroEnabled = false;
let sendInterval = null;

const STEERING_DEAD_ZONE = 2.0;  // degrees
const STEERING_MAX_DEG = 30.0;   // map to ±1

// ─── DOM refs ─────────────────────────────────────────────────────────────────
const statusDot    = document.getElementById('status-dot');
const statusText   = document.getElementById('status-text');
const steeringFill = document.getElementById('steering-fill');
const connectPanel = document.getElementById('connect-panel');
const gyroPrompt   = document.getElementById('gyro-prompt');
const serverInput  = document.getElementById('server-input');
const connectError = document.getElementById('connect-error');
const throttleBtn  = document.getElementById('throttle-btn');
const brakeBtn     = document.getElementById('brake-btn');
const drsBtn       = document.getElementById('drs-btn');
const ersBtn       = document.getElementById('ers-btn');
const speedDisplay = document.getElementById('speed-display');
const posDisplay   = document.getElementById('pos-display');

// ─── Gyroscope permission (iOS 13+) ──────────────────────────────────────────
document.getElementById('gyro-allow-btn').addEventListener('click', () => {
  if (typeof DeviceOrientationEvent !== 'undefined' &&
      typeof DeviceOrientationEvent.requestPermission === 'function') {
    DeviceOrientationEvent.requestPermission()
      .then(state => {
        if (state === 'granted') {
          enableGyro();
          gyroPrompt.classList.add('hidden');
        } else {
          alert('Motion permission denied. Steering won\'t work.');
          gyroPrompt.classList.add('hidden');
        }
      }).catch(console.error);
  } else {
    enableGyro();
    gyroPrompt.classList.add('hidden');
  }
});

function enableGyro() {
  window.addEventListener('deviceorientation', onDeviceOrientation);
  gyroEnabled = true;
}

function onDeviceOrientation(evt) {
  // gamma = left/right tilt (-90..90 degrees)
  const gamma = evt.gamma || 0;
  if (Math.abs(gamma) < STEERING_DEAD_ZONE) {
    steering = 0;
  } else {
    steering = Math.max(-1, Math.min(1, gamma / STEERING_MAX_DEG));
  }
  // Update steering bar visual
  const pct = 50 + steering * 45;
  steeringFill.style.left = pct + '%';
}

// ─── WebSocket ────────────────────────────────────────────────────────────────
function connectToServer() {
  const ip = serverInput.value.trim();
  if (!ip) { connectError.textContent = 'Enter an IP address.'; return; }

  const url = `ws://${ip}:8080`;
  connectError.textContent = 'Connecting…';

  ws = new WebSocket(url);
  ws.binaryType = 'arraybuffer';

  ws.onopen = () => {
    connectPanel.classList.add('hidden');
    statusDot.classList.add('connected');
    statusText.textContent = 'Connected';
    // Send input at 30 Hz
    sendInterval = setInterval(sendInput, 33);
    // Keep-alive ping
    setInterval(() => ws && ws.readyState === 1 && ws.send(JSON.stringify({type:'ping'})), 2000);
  };

  ws.onmessage = (evt) => {
    try {
      const msg = JSON.parse(evt.data);
      if (msg.type === 'telemetry') {
        speedDisplay.textContent = Math.round(msg.speed_kmh || 0) + ' km/h';
        posDisplay.textContent   = 'P' + (msg.position || '—');
      }
    } catch(e) {}
  };

  ws.onclose = () => {
    statusDot.classList.remove('connected');
    statusText.textContent = 'Disconnected';
    clearInterval(sendInterval);
    connectPanel.classList.remove('hidden');
  };

  ws.onerror = () => {
    connectError.textContent = 'Connection failed. Check IP and try again.';
  };
}

function sendInput() {
  if (!ws || ws.readyState !== 1) return;
  ws.send(JSON.stringify({
    type:     'input',
    steering: steering,
    throttle: throttle,
    brake:    brake,
    drs:      drsActive,
    ers:      ersActive
  }));
}

// ─── Touch controls ───────────────────────────────────────────────────────────
function addPedalListeners(el, onStart, onEnd) {
  el.addEventListener('touchstart', (e) => { e.preventDefault(); onStart(); }, { passive: false });
  el.addEventListener('touchend',   (e) => { e.preventDefault(); onEnd();   }, { passive: false });
  el.addEventListener('touchcancel',(e) => { e.preventDefault(); onEnd();   }, { passive: false });
  // Mouse fallback for desktop testing
  el.addEventListener('mousedown', onStart);
  el.addEventListener('mouseup',   onEnd);
  el.addEventListener('mouseleave',onEnd);
}

addPedalListeners(throttleBtn,
  () => { throttle = 1; throttleBtn.classList.add('active'); },
  () => { throttle = 0; throttleBtn.classList.remove('active'); }
);

addPedalListeners(brakeBtn,
  () => { brake = 1; brakeBtn.classList.add('active'); },
  () => { brake = 0; brakeBtn.classList.remove('active'); }
);

// DRS/ERS toggle on touch
drsBtn.addEventListener('touchstart', (e) => {
  e.preventDefault();
  drsActive = !drsActive;
  drsBtn.classList.toggle('active', drsActive);
}, { passive: false });

ersBtn.addEventListener('touchstart', (e) => {
  e.preventDefault();
  ersActive = !ersActive;
  ersBtn.classList.toggle('active', ersActive);
}, { passive: false });

// ─── Check if on iOS (needs permission dialog) ────────────────────────────────
if (typeof DeviceOrientationEvent !== 'undefined' &&
    typeof DeviceOrientationEvent.requestPermission === 'function') {
  // iOS 13+: show permission prompt
  gyroPrompt.classList.remove('hidden');
} else {
  // Android / desktop: just enable
  enableGyro();
  gyroPrompt.classList.add('hidden');
}

// ─── Saved IP ─────────────────────────────────────────────────────────────────
const savedIP = localStorage.getItem('funracing_ip');
if (savedIP) serverInput.value = savedIP;
serverInput.addEventListener('input', () => localStorage.setItem('funracing_ip', serverInput.value));
