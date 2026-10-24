# Evidencia del proyecto
Revisión estática del ZIP `sra_346_movil-develop.zip`, 20-10-2026. No se ejecutó Flutter, cámara ni backend al crear este paquete. No se modificó código de la app. El archivo incluye 24 Dart bajo lib y no contiene backend ni pruebas móviles.

| Evidencia | Fuente / símbolo | Consecuencia |
|---|---|---|
| Flutter/Dart y build histórico documentados | RUNTIMES.md, .gitlab-ci.yml | Revalidar en entorno fijado |
| URL HTTP local, JSON o texto en 200 | lib/src/services/apiService.dart, _returnResponse | Contrato no es http.Response |
| Consumidor usa statusCode/body | lib/src/services/registerService.dart, getAll | Incompatibilidad estática confirmada |
| RUT int con fallback cadena | lib/src/services/jwtService.dart, getRut | Ausencia puede fallar por tipo |
| Solo remove(token), sin await de remove | jwtService.dart, removeToken | Sesión incompleta al salir |
| Tokens impresos y sesión inicial por token no vacío | lib/main.dart; LoginPage.dart, loginIn | Corregir logs y validar sesión |
| Contraseñas en query | loginService.dart | Migración requiere coordinación backend |
| scan seguido siempre de next | QRLectorComponent.dart, onTap | Cancelar puede procesar texto de error |
| asignaturaId consumido pero no está en modelo QR | QRLectorComponent.dart; models/qr.dart | Alinear modelo y payload real |
| ATRASADO local pero no serializado | ConfirmationAttendance.dart; Register.toJson | No agregar estado al POST |
| Éxito por ausencia de Error; sin guard de envío | ConfirmationAttendance.dart, _rowBtn | Falsos éxitos y solicitudes múltiples |
| loginIn async void no esperado | LoginPage.dart, _validateAndSubmit | Indicador se retira antes de terminar |
| Logout agrega LoginPage | DrawerWidget.dart | Back puede recuperar pantalla anterior |
| Analyze allow_failure; solo APK debug | .gitlab-ci.yml | CI verde no acredita calidad/release |
| Sin NSCameraUsageDescription en Info.plist incluido | ios/Runner/Info.plist | Investigar soporte cámara iOS antes de afirmarlo |

La decisión presente/atrasado y la rotación del token vienen del análisis del usuario. No existe fuente backend en este ZIP para verificarlas. Preservarlas como restricciones; pedir fuente/fixtures antes de modificar semántica o diseñar reintentos.

## Contraste con checkout local — 20-10-2026

La fotografía del ZIP anterior sigue siendo histórica. En esta sesión existe el
backend vecino `../sra-346-servicios`, consultado solo en lectura. Las afirmaciones
anteriores sobre su ausencia y contrato de asistencia sin verificar quedan
superadas por estas evidencias de fuente; no constituyen integración ejecutada:

- `auth/jwt/filter/JWTAuthenticationFilter.java`: login por parámetros
  username/password; respuesta token y user.username.
- `auth/jwt/service/JWTServiceImpl.java#createToken`: sub, iat y exp; no RUT.
- `controller/RestoreRestController.java#getRutForEmail`: POST /api/rut con
  email; éxito digitos, dv y mensaje "Proceso exitoso".
- `controller/AsistenciaServicio.java#qrJson`: idClase, token, estadoActivo,
  asignatura y asignaturaId. `getMatricula` devuelve matrícula por asignatura/RUT;
  ausencia puede producir 500 por dereferencia nula.
- `service/RegistroAsistenciaService.java`: éxito comienza exactamente por
  "Alumno ingresado con exito->Alumno:"; rechazos Error 401–407. Calcula
  PRESENTE/ATRASADO en servidor y rota el token. El cliente conserva el POST
  idClase, numeroMatricula, token; no agrega estadoAsistencia.

Corrección de integración preparada: inicio espera comprobación de sesión completa,
fallos abren login y cursos no consulta sin sesión/RUT. La carga se conserva en un
Future de State y comprueba mounted después de esperas. Se retiraron logs de JWT
al iniciar y de RUT al cargar cursos. Cinco pruebas sintéticas cubren esas rutas.
La ejecución detallada de pruebas, análisis, APK y revisión independiente se
registra en el RUN de esta sesión. Evidencia comunicada por el orquestador al
cerrar esta actualización documental:

| Control | Baseline reproducido | Checkout corregido |
|---|---|---|
| `flutter test` | Sin suite móvil previa | PASS: 43 pruebas, exit 0 |
| `flutter analyze` | FAIL: seis infos, exit 1 | FAIL: dos infos previos en PieChart/parseDouble, exit 1; sin nuevos |
| `flutter build apk --debug` | PASS: exit 0 | PASS: diff exacto final, exit 0, 8,6 s; `unzip -t` exit 0, lock intacto |

Las correcciones SRA-01 a SRA-07 están implementadas y sus pruebas locales
sintéticas pasan. Esto no acredita cámara física, iOS ni integración backend:
permanecen NOT_RUN y requieren evidencia propia. El análisis conserva dos infos
previos y su código de salida no se oculta. El verificador confirmó compilación
local del APK debug exacto final, integridad ZIP y lock intacto; véase el
[informe independiente](runs/2026-10-20-independent-review.md). Esto no acredita
release, distribución ni publicación.

## Complemento del checkout — 21-10-2026

La revisión del checkout confirmó que las correcciones anteriores seguían
presentes. La ampliación local agregó validación estricta de respuestas y campos
de asignatura, estados explícitos de carga/vacío/error y un estado seguro para
porcentajes todos cero. También completó los flujos de recuperación y cambio
interno de contraseña: espera, exclusión de doble pulsación, validación de
entrada, postcondición exacta y limpieza de sesión al éxito.

La suite pasó de 43 a 66 pruebas. En la imagen fijada de Flutter
1.12.13+hotfix.9, `flutter test` y `flutter analyze` pasan; los dos avisos previos
de `PieChart.dart` y `parseDouble.dart` fueron eliminados sin cambiar
dependencias. `.gitlab-ci.yml` ejecuta análisis y tests como gates bloqueantes
antes del APK. La evidencia definitiva de APK, lock y revisión se conserva en
el RUN del 21-10-2026; cámara/dispositivo, iOS y backend real siguen sin ejecución.
