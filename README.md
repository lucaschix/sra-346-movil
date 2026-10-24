# sra_346_movil

Registro de Asistencia móvil.

## Reproducible build

The project builds with **Flutter 1.12.13+hotfix.9**, the version that resolves `pubspec.lock`
without changes (newer Flutter releases rewrite SDK-pinned packages). It only requires Docker:

```
docker run --rm -v "$PWD":/src:ro cirrusci/flutter:v1.12.13-hotfix.9 \
  bash -c 'cp -r /src ~/app && cd ~/app && flutter pub get && flutter build apk --debug'
```

`android/build.gradle` maps `me.dm7.barcodescanner` 1.9.13 (a `barcode_scan` dependency that was
only published to JCenter) to 1.9.8 from Maven Central, which has the same scanner code.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
