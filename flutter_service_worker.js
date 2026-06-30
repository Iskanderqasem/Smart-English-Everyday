// Self-destruct: clear all caches then unregister so users always
// get fresh files. Replaces the Flutter-generated version.
self.addEventListener('install', function(e) {
  self.skipWaiting(); // Activate immediately, don't wait for tabs to close
});
self.addEventListener('activate', function(e) {
  e.waitUntil(
    caches.keys().then(function(names) {
      return Promise.all(names.map(function(n) { return caches.delete(n); }));
    }).then(function() {
      return self.registration.unregister();
    })
  );
});
