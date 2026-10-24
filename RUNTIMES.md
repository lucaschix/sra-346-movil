# Entorno de la migración iOS 26

| Componente | Versión |
| --- | --- |
| Flutter | 3.38.10, commit c6f67dede3d4aa1aa7a69dd56a3494a5cde6cc80 |
| Dart | 3.10.9 |
| Xcode del flujo remoto | 26.3 |
| Deployment target | iOS 15.0 |
| Dispositivo previsto | iPhone 11, iOS 26.5.2 |

Las dependencias de pubspec.yaml están fijadas; pubspec.lock conserva hashes
SHA-256. Ejecutar `flutter pub get --enforce-lockfile`.

Verificación local en Linux: `flutter analyze` PASS; `flutter test` PASS (14).
Build release iOS, firma, cámara y dispositivo: NOT_RUN.

Los runtimes de Android (JDK/Gradle/AGP) de esta copia siguen siendo los del
proyecto legado y no se validan con el SDK moderno. La migración Android es
una tarea separada. No usar el antiguo Docker Flutter 1.12 para esta rama.

El entorno reproducible de Flutter 1.12.13 / Dart 2.7.2 queda registrado en main,
commit 9cc8968, incluyendo el flujo debug con Xcode 16.0 y el workaround bitcode.
