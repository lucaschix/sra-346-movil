# Runtime and dependency record

Recorded on 2026-10-19 for the reproducible build (.gitlab-ci.yml).

## Runtimes

| Component | Version | Source | Image digest at recording |
|-----------|---------|--------|---------------------------|
| Flutter | 1.12.13+hotfix.9 | `cirrusci/flutter:v1.12.13-hotfix.9` | `sha256:b82b48daac2dba80c78f153e39d0619995322ae6a09da7068272d86f3e1a281d` |
| Dart | 2.7.2 | bundled with Flutter | — |
| JDK (Android build) | 1.8.0_222 | bundled in the image | — |
| Gradle | 5.6.2 | `android/gradle/wrapper/gradle-wrapper.properties` | — |
| Android Gradle Plugin | 3.5.0 | `android/build.gradle` | — |
| Kotlin | 1.3.50 | `android/build.gradle` | — |
| Android SDK | compile/target 28, min 16 | `android/app/build.gradle` | — |

Flutter 1.12.13+hotfix.9 is the version that resolves `pubspec.lock` without changes; Flutter 1.22.6
rewrites the SDK-pinned packages. The image runs as user `cirrus`, not root, and is pinned by digest in
`.gitlab-ci.yml` because it is no longer maintained.

## Dependency resolution

- Lockfile: `pubspec.lock`, 40 packages, SDK constraints `dart: ">=2.4.0 <3.0.0"` and
  `flutter: ">=1.12.13+hotfix.4 <2.0.0"`. SHA-256 prefix at recording: `36ad4337f91a7eeb`.
- `shared_preferences` is pinned to 0.5.6+3 in `pubspec.yaml` (formerly the dynamic constraint `any`),
  matching the version in the lockfile.
- `me.dm7.barcodescanner` 1.9.13 (needed by `barcode_scan` 2.0.1) was only published to JCenter.
  `android/build.gradle` maps it to 1.9.8 from Maven Central and keeps `com.google.zxing:core` at 3.3.3.

## Checks

- `flutter build apk --debug` succeeds.
- `flutter analyze` reports 6 info-level findings; this Flutter version treats them as fatal,
  so the CI job is allowed to fail.
- There are no tests; the template counter test was removed because it never mounted a widget.
