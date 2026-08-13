import "dart:io";

import "package:flutter_test/flutter_test.dart";

void main() {
  test("web entrypoints share one build-version cache key", () {
    final bootstrap = File("web/flutter_bootstrap.js").readAsStringSync();

    expect(bootstrap, contains("{{flutter_js}}"));
    expect(bootstrap, contains("{{flutter_build_config}}"));
    expect(bootstrap, contains("{{flutter_service_worker_version}}"));
    expect(bootstrap, contains('"mainJsPath"'));
    expect(bootstrap, contains('"mainWasmPath"'));
    expect(bootstrap, contains('"jsSupportRuntimePath"'));
    expect(bootstrap, contains("v=\${encodeURIComponent(appBuildVersion)}"));
    expect(
      bootstrap.indexOf("build[artifactKey] ="),
      lessThan(bootstrap.indexOf("_flutter.loader.load")),
    );
  });
}
