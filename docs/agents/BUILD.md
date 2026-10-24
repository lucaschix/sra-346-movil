# Reproducción de build
Baseline histórico: RUNTIMES.md declara APK debug exitoso y seis infos; no revalidado al crear este kit.

## En un entorno ya fijado
Desde la raíz del repo, con Flutter 1.12.13+hotfix.9 / Dart 2.7.2 y JDK 8 confirmados:
```bash
flutter --version
dart --version
java -version
sha256sum pubspec.lock
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
sha256sum pubspec.lock
git diff -- pubspec.lock
```
Ejecutar y registrar cada comando por separado para no perder códigos de salida. `flutter test` requiere que se hayan creado pruebas; sin ellas es NOT_RUN, no PASS.

## Docker, en copia aislada
Requiere Docker funcional y acceso a los repositorios de dependencias. No se necesita instalar un SDK moderno en el checkout. Revisar `.gitlab-ci.yml` como fuente de la imagen y comprobar que sigue siendo la fijada. Desde la raíz, en Bash/Linux:
```bash
sra_build_copy="$(mktemp -d -t sra-mobile-build.XXXXXX)"
tar --exclude='./.git' --exclude='./build' --exclude='./.pub-cache' --exclude='./.gradle-home' --exclude='./.dart_tool' -cf - . | tar -xf - -C "$sra_build_copy"
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -e PUB_CACHE=/work/.pub-cache -e GRADLE_USER_HOME=/work/.gradle-home -v "$sra_build_copy:/work" -w /work --entrypoint bash cirrusci/flutter:v1.12.13-hotfix.9@sha256:b82b48daac2dba80c78f153e39d0619995322ae6a09da7068272d86f3e1a281d -lc 'flutter --version'
```
Reusar el mismo montaje para cada comando anterior, sustituyendo únicamente el argumento de `bash -lc`. No asumir que el UID del host podrá escribir en el SDK preinstalado: si falla, documentar permisos, inspeccionar UID del usuario `cirrus` y preparar una copia/volumen compatible; no dar privilegios globales ni cambiar permisos del repositorio original. Conservar outputs antes de eliminar voluntariamente la copia.

El workaround nativo fija barcodescanner 1.9.8 y zxing core 3.3.3. Un build debug no valida permisos finales de release, cleartext/TLS, firmas ni publicación. Revisar manifests fusionados de cada variante cuando ese sea el alcance. Para iOS usar entorno macOS/Xcode compatible y dispositivo: el APK no aporta evidencia iOS.
