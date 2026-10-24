---
name: sra-mobile-build
description: Reproducir y verificar el entorno Flutter legado de SRA móvil; usar para compilación, cambios nativos, dependencias, CI o problemas de compatibilidad.
---

# Compilar conservando el entorno
1. Leer `RUNTIMES.md`, `.gitlab-ci.yml`, `pubspec.yaml`, `pubspec.lock`, Gradle y `docs/agents/BUILD.md`.
2. Registrar versiones reales. Si Flutter/Dart difieren de 1.12.13+hotfix.9 / 2.7.2, no ejecutar pub get con ese SDK. Usar la imagen fijada del CI en una copia aislada.
3. Registrar SHA-256 del lockfile antes y después; ejecutar pub get, analyze, tests y build por separado conservando códigos de salida. No ejecutar pub upgrade.
4. Inspeccionar el workaround de barcode_scan y conservarlo. No asumir disponibilidad actual de repositorios históricos; un fallo de descarga es un bloqueo de entorno y no prueba de regresión del código.
5. Comparar análisis con baseline real: los seis infos solo están documentados históricamente. No agregar `|| true`, excluir código ni cambiar CI para maquillar resultados.
6. Ejecutar `flutter test` cuando existan pruebas; si no hay, informar NOT_RUN y abrir la tarea de caracterización. No reportar "0 tests" como suite aprobada.
7. Ejecutar `flutter build apk --debug`; inspeccionar el archivo producido. No declarar release, firma, tienda ni iOS validados.
8. Devolver versiones, comandos, códigos, hash del lock, warnings y bloqueos. Los cambios involuntarios del lock se investigan antes de integrarlos; no restaurar un lock ajeno por fuerza.
