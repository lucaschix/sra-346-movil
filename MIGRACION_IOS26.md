# Migración para iPhone 11 / iOS 26.5.2

## Evidencia recibida

La ejecución 7 de Codemagic (commit `9cc8968`) generó una app debug sin firma
con Flutter 1.12.13+hotfix.9, Dart 2.7.2, Xcode 16.0 y SDK iphoneos18.0.
Su bundle es `com.example.sra346Movil`; no incluye perfil de aprovisionamiento,
NSCameraUsageDescription ni NSLocalNetworkUsageDescription. El framework Flutter
tiene MinimumOSVersion 8.0 y el host 12.0. El lockfile antes y después coincide:
`36ad4337f91a7eebfcf5eb52c3818d44a98d3d6f30c61c4cec250d8107136a35`.

La evidencia demuestra compilación debug; no demuestra funcionamiento en iOS 26,
firma, cámara, red local ni distribución por TestFlight. No se subieron los ZIP
recibidos a GitHub.

## Cambio preparado en rama separada

- Flutter 3.38.10 / Dart 3.10.9, con null safety y APIs actuales de widgets/HTTP.
- Paquetes directos fijados y lockfile resuelto con el SDK nuevo.
- `mobile_scanner` 7.4.2 en lugar de `barcode_scan` 2.0.1; cancelación sin continuar
  a matrícula y detección única por apertura del scanner. QR inactivo/malformado
  se informa antes de consultar matrícula. El registro sigue requiriendo confirmación.
- Nuevo host iOS de la plantilla oficial, lifecycle UIScene y registro de plugins
  en el callback del motor implícito. Identificador provisional cl.lucaschix.sra346Movil.
- Deployment target 15.0 para app, framework y Pods; declaraciones de cámara/red local.
- Backend configurable por SRA_API_BASE_URL. Se mantiene el valor local anterior y
  el contrato HTTP del backend. Los logs de arranque/login/respuesta no imprimen JWT.
- Corregida la inversión del callback de expansión de cursos, cuya semántica cambió
  en Flutter moderno; las pruebas ejercitan apertura y cierre.
- Flujo remoto con Xcode 26.3, análisis, pruebas y build **release sin firma**.
  El SDK se instala desde el commit oficial verificado. No usa el parche legado.
- main queda en el baseline debug; el proyecto Android no está migrado.

## Verificación

| Verificación | Resultado |
| --- | --- |
| Flutter/Dart reales en Linux | PASS: 3.38.10 / 3.10.9 |
| pub get --enforce-lockfile | PASS |
| flutter analyze | PASS: sin issues |
| flutter test | PASS: 14 pruebas sintéticas |
| Sintaxis Podfile / YAML / Bash y plists | PASS |
| Build release con Xcode 26.3 | NOT_RUN: ejecutar Codemagic en esta rama |
| Cámara, backend y ejecución en el iPhone | NOT_RUN |
| Firma y TestFlight | NOT_RUN: falta membresía y configuración de Apple |
| Build Android | NOT_RUN: proyecto nativo legado |

Las pruebas cubren payload de asistencia sin estado calculado localmente,
JSON/texto HTTP, autorización/401, QR válido/inactivo/malformado, sesión,
login al tamaño del iPhone 11, expansión de cursos y gráficos normales/en cero.
No se realizaron operaciones reales de asistencia ni peticiones al backend.

## Continuación

En Codemagic: Build branch → migration/ios-26 → actualizar ↻ →
SRA - iOS 26 release sin firma. Mantener los registros ante cualquier fallo.
No contratar servicios nuevos por el solo resultado de estas pruebas locales:
primero confirmar el build remoto. Después, configurar membresía, Bundle ID,
certificado y perfil de distribución para obtener un IPA firmado y usar TestFlight.

## Referencias técnicas

- Soporte iOS 26: https://flutter.dev/blog/whats-new-in-flutter-3-38
- Lifecycle: https://docs.flutter.dev/release/breaking-changes/uiscenedelegate
- Xcode: https://developer.apple.com/xcode/system-requirements
- Imagen remota: https://docs.codemagic.io/specs-macos/xcode-26-3/
- Cámara: https://pub.dev/packages/mobile_scanner
- Red local: https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking
