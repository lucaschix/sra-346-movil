# Revisión independiente SRA móvil — 21-10-2026

Rol: mobile-verifier ejecutado secuencialmente, sin subdelegación y sin editar
aplicación, pruebas o configuración durante la revisión. Se revisó el diff
congelado, los contratos del backend vecino en lectura y una copia nueva del
checkout. Dictamen: APTO para el alcance local comprobable; no se identificaron
defectos bloqueantes nuevos. Cámara, dispositivo, iOS e integración HTTP real
con backend permanecen BLOCKED/NOT_RUN.

## Entorno y comparación

Imagen exacta
`cirrusci/flutter:v1.12.13-hotfix.9@sha256:b82b48daac2dba80c78f153e39d0619995322ae6a09da7068272d86f3e1a281d`,
Flutter 1.12.13+hotfix.9, Dart 2.7.2 y OpenJDK 1.8.0_222. Copia final
`/tmp/sra-mobile-final.Xvbx8x`, contenedor `sra-mobile-final`.

Baseline reproducido antes de la edición: 43 pruebas PASS; análisis exit 1 con
dos infos (`must_be_immutable` y `camel_case_types`). Final: 66 pruebas PASS;
análisis exit 0 sin hallazgos. El lock conserva SHA-256
`36ad4337f91a7eebfcf5eb52c3818d44a98d3d6f30c61c4cec250d8107136a35`.

## Revisión del cambio

- Los flujos de recuperación y cambio interno verifican las postcondiciones
  exactas observadas en `RestoreRestController`, codifican parámetros y rechazan
  entradas vacías antes de HTTP. La UI espera cada Future, bloquea doble
  pulsación, conserva errores recuperables y limpia sesión/rutas después de un
  cambio interno confirmado.
- La carga de asignaturas exige RUT positivo, lista de mapas y campos de dominio
  válidos. La UI distingue carga, vacío y error redactado, conserva el Future
  entre reconstrucciones y navega a detalle sin consultas duplicadas.
- El modelo acepta límites 0/100 y rechaza campos ausentes, tipos incorrectos,
  negativos, valores mayores a 100, NaN e infinito. El gráfico evita entregar
  suma cero a `fl_chart`, caso que producía coordenadas NaN en esta versión.
- El analizador quedó limpio al hacer inmutable la referencia del widget,
  tipar su State y corregir el nombre de clase. No cambió la salida numérica
  visible ni el contrato de porcentajes.
- CI tiene gates bloqueantes separados para análisis y 66 pruebas antes del APK.
  No contiene `allow_failure`. Dependencias, Gradle y workaround de
  `barcode_scan` no tienen diff.
- La búsqueda `rg -n --glob '*.dart' '\b(print|debugPrint|log)\s*\(' lib`
  no encontró llamadas. No se observaron logs de JWT, RUT, QR o contraseñas.

## Checks independientes

| Control | Resultado | Evidencia |
|---|---|---|
| `git diff --check` | PASS, exit 0 | checkout final |
| `flutter pub get` | PASS, exit 0 | `final-pub-get.log` |
| `flutter test` | PASS, exit 0 | 66 pruebas; `final-test.log` |
| `flutter analyze` | PASS, exit 0 | sin hallazgos; `final-analyze.log` |
| `flutter build apk --debug` | PASS, exit 0 | 138,7 s; `final-build.log` |
| `unzip -t app-debug.apk` | PASS, exit 0 | sin errores de datos comprimidos |
| lock antes/después | PASS | mismo SHA-256 en host y copia después de pub/build |
| diff dependencias/runtime | PASS | vacío para pubspec, lock, Gradle, wrapper y Podfile |
| búsqueda de logs sensibles | PASS | cero llamadas de logging en `lib/**/*.dart` |

APK debug inspeccionado: 59.693.891 bytes, SHA-256
`d7f238e88ffe990a41d0eb952c80d03e49d400e2516215bb5def49fbfbab252a`.
No se publicó ni se copió como artefacto de distribución.

## Límites

Pruebas con dobles acreditan comportamiento local, no disponibilidad del
backend, permisos ni ciclo de vida de cámara. Cámara Android, background,
reingreso, iOS/Xcode, revocación JWT, token QR vigente/rotado y reconciliación
de un POST incierto requieren infraestructura o dispositivo. No se usaron datos
reales, no se llamó una red productiva y no se registró asistencia.
