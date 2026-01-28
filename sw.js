const CACHE_NAME = "daily-motivation-v1";
const STATIC_ASSETS = [
    ".",
    "index.html",
    "styles.css",
    "script.js",
    "manifest.json",
    "icon.svg"
];

self.addEventListener("install", (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS))
    );
});

self.addEventListener("activate", (event) => {
    event.waitUntil(
        caches.keys().then((keys) =>
            Promise.all(
                keys.map((key) => (key === CACHE_NAME ? null : caches.delete(key)))
            )
        )
    );
});

self.addEventListener("fetch", (event) => {
    const { request } = event;

    if (request.mode === "navigate") {
        event.respondWith(
            fetch(request).catch(() => caches.match("index.html"))
        );
        return;
    }

    event.respondWith(
        caches.match(request).then((cached) =>
            cached || fetch(request).then((response) => {
                const cloned = response.clone();
                caches.open(CACHE_NAME).then((cache) => cache.put(request, cloned));
                return response;
            })
        )
    );
});
