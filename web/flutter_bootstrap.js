{{flutter_js}}
{{flutter_build_config}}

const appBuildVersion = {{flutter_service_worker_version}};
const appArtifactKeys = [
  "mainJsPath",
  "mainWasmPath",
  "jsSupportRuntimePath",
];

for (const build of _flutter.buildConfig.builds) {
  for (const artifactKey of appArtifactKeys) {
    const artifactPath = build[artifactKey];
    if (!artifactPath) continue;

    const separator = artifactPath.includes("?") ? "&" : "?";
    build[artifactKey] =
      `${artifactPath}${separator}v=${encodeURIComponent(appBuildVersion)}`;
  }
}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: appBuildVersion,
  },
});
