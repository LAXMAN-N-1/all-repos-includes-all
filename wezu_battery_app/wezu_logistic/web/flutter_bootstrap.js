{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Avoid dependency on gstatic for local/dev runs where external fetches
    // can fail and cause a white screen before app startup.
    useLocalCanvasKit: true,
  },
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
});
