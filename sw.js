/* SimpleSugar · service worker
   - la page : réseau d'abord (toujours la dernière version), copie de secours hors ligne
   - icônes, polices, supabase-js : cache
   - photos des recettes : cache (elles ne changent jamais d'adresse)
   - données Supabase : jamais mises en cache ici (l'application garde sa propre copie) */
const VERSION = 'simplesugar-v1';
const SHELL = VERSION + '-shell';
const IMAGES = 'simplesugar-images';
const PRECACHE = ['./', './index.html', './manifest.webmanifest', './favicon.svg', './icon-180.png', './icon-192.png', './icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(SHELL).then(c => c.addAll(PRECACHE)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k.startsWith('simplesugar-') && k !== SHELL && k !== IMAGES).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

async function networkFirst(req) {
  const cache = await caches.open(SHELL);
  try {
    const res = await fetch(req, { cache: 'no-store' });
    if (res && res.ok) cache.put('./index.html', res.clone());
    return res;
  } catch {
    return (await cache.match('./index.html')) || (await cache.match('./')) || Response.error();
  }
}
async function cacheFirst(req, name, max) {
  const cache = await caches.open(name);
  const hit = await cache.match(req);
  if (hit) return hit;
  const res = await fetch(req);
  if (res && (res.ok || res.type === 'opaque')) {
    cache.put(req, res.clone());
    if (max) cache.keys().then(keys => { if (keys.length > max) keys.slice(0, keys.length - max).forEach(k => cache.delete(k)); });
  }
  return res;
}
async function staleWhileRevalidate(req) {
  const cache = await caches.open(SHELL);
  const hit = await cache.match(req);
  const net = fetch(req).then(res => { if (res && res.ok) cache.put(req, res.clone()); return res; }).catch(() => hit);
  return hit || net;
}

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (req.mode === 'navigate') { e.respondWith(networkFirst(req)); return; }
  if (url.origin === self.location.origin) { e.respondWith(staleWhileRevalidate(req)); return; }
  if (url.hostname === 'cdn.jsdelivr.net' || url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com') { e.respondWith(cacheFirst(req, SHELL)); return; }
  if (url.pathname.includes('/storage/v1/object/public/')) { e.respondWith(cacheFirst(req, IMAGES, 400)); return; }
});
