# SRA móvil — migración iOS 26

Rama `migration/ios-26`, preparada para probar un iPhone 11 con iOS 26.5.2.
`main` conserva el baseline Flutter 1.12.13 que compiló debug sin firma en
Codemagic (commit `9cc8968`, ejecución 7). La carpeta del proyecto original
no se modifica.

## Entorno de esta rama

- Flutter **3.38.10**, commit `c6f67dede3d4aa1aa7a69dd56a3494a5cde6cc80`.
- Dart **3.10.9**, null safety y dependencias fijadas en `pubspec.lock`.
- iOS **15.0+**, Xcode **26.3** en Mac mini M2.
- Bundle ID provisional: `cl.lucaschix.sra346Movil` (registrar en Apple antes de firmar).
- `mobile_scanner` reemplaza a `barcode_scan`; conserva lectura QR y confirmación
  posterior. No registra asistencia al detectar un código.
- Lifecycle UIScene, permisos de cámara y acceso a red local declarados.
- El proyecto Android sigue siendo legado; esta rama no acredita build Android.

## Validación local

Con Flutter 3.38.10 en PATH:

```sh
flutter pub get --enforce-lockfile
flutter analyze
flutter test --reporter expanded
```

El baseline de esta migración pasa análisis y 14 pruebas con datos sintéticos.
Incluyen transporte JSON/texto, rechazo HTTP 401, payload de registro, QR malformado,
inactivo o sin token/asignatura, preferencias y login a 414 × 896 puntos.
No representan cámara real, backend real ni ejecución iOS.

## Prueba remota en Codemagic

1. **Build branch** → `migration/ios-26`.
2. Actualizar con **↻** y seleccionar **SRA - iOS 26 release sin firma**.
3. Iniciar y descargar los artefactos y registros.

El flujo descarga el SDK desde la etiqueta oficial y comprueba su commit;
no depende del catálogo de versiones de Flutter del instalador de Codemagic.
Ejecuta análisis y tests antes del build release. No usa el parche de bitcode
ni el Podfile de Flutter 1.12.

La salida `Runner.app.zip` de este flujo no tiene firma ni perfil de Apple:
no se instala directamente en un iPhone y no se sube aún a TestFlight.
La compilación release iOS de esta rama está **NOT_RUN** hasta ejecutar el flujo.
Después harán falta membresía Apple Developer Program, registro del Bundle ID,
certificados/perfil y un flujo firmado para TestFlight.

## Backend durante la prueba

La URL se configura sin editar Dart:

```sh
flutter build ios --release --no-codesign \
  --dart-define=SRA_API_BASE_URL=http://192.168.1.82:8080
```

Codemagic expone la misma variable `SRA_API_BASE_URL`. El valor por defecto sigue
siendo el servidor local original. El iPhone debe poder alcanzarlo en su Wi-Fi
y aceptar el permiso de red local. `NSAllowsLocalNetworking` permite ese acceso
sin habilitar cargas HTTP arbitrarias a Internet. Para un backend público,
configurar una URL HTTPS disponible; no se modificaron contratos del servidor.
No incluir credenciales en esta variable.

## Evidencia y límites

Ver `MIGRACION_IOS26.md` y `RUNTIMES.md`. Los documentos bajo `docs/agents/` y la
configuración antigua de GitLab describen el proyecto legado; no acreditan
validaciones de esta rama. La cámara, registro de asistencia real, firma,
TestFlight y ejecución en el iPhone siguen pendientes.
