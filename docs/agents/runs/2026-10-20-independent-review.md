# Revisión independiente SRA móvil — 20-10-2026

Rol: mobile-verifier; sin subdelegación ni edición de aplicación, pruebas o configuración. Alcance: diff estable entregado por autores, seis prioridades del usuario, contratos del backend vecino en lectura y checks en Docker legado aislado. Dictamen final: PARCIAL. APTO para los criterios comprobados de reparación, pruebas sintéticas y compilación Android debug; cámara física e integración backend siguen sin verificar. No quedan defectos nuevos bloqueantes identificados en el diff final.

## Entorno y baseline contrastados

Imagen CI fijada `cirrusci/flutter:v1.12.13-hotfix.9@sha256:b82b48daac2dba80c78f153e39d0619995322ae6a09da7068272d86f3e1a281d`; versión ejecutada Flutter 1.12.13+hotfix.9 / Dart 2.7.2 / OpenJDK 1.8.0_222. Copia baseline `/work/app` y final `/work/final` en contenedor `sra-mobile-verify-20261020`. Logs host `/tmp/sra-mobile-baseline-culg2772/`.

Baseline real `analyze.log`: exit 1, seis infos (cuatro imports/campo sin usar, must_be_immutable y camel_case_types), cero errores. Sin directorio test inicial: NOT_RUN. Build baseline comunicado por orquestador: exit 0. Hash lock baseline/final inspeccionado: `36ad4337f91a7eebfcf5eb52c3818d44a98d3d6f30c61c4cec250d8107136a35`.

## Hallazgos enviados y resueltos por autores

- P1 / FAIL: `test/widgets/confirmation_attendance_test.dart:45,56,66,67` usa `find.textContaining`, inexistente en Flutter 1.12. El analizador reporta cuatro errores nuevos y el archivo no compila. Sustituir por finder compatible manteniendo aserciones de comportamiento.
- P2 / FAIL de calidad nuevo: `ConfirmationAttendance.dart:84,85` introduce collection-if pese al mínimo Dart >=2.1 del pubspec. Funciona con runtime fijado Dart 2.7.2, pero genera dos infos sdk_version_ui_as_code. Evitar sintaxis sin ampliar restricciones.
- P3: `test/services/login_service_test.dart:73` contiene return posterior a fail, genera dead_code nuevo. No afecta comportamiento; limpiar manteniendo fallo ante petición inesperada.

## Revisión de las seis prioridades

1. `RegisterService.getAll` consume lista decodificada y rechaza mapa/texto/miembros no mapa; no usa statusCode/body. Tests de listas vacías y respuesta inválida. El endpoint profesor no existe en fuente backend inspeccionada: su disponibilidad real queda NOT_RUN.
2. Búsqueda `rg -n 'print\(|debugPrint\(' lib` sin coincidencias; los errores HTTP no incorporan body sensible. Se mantienen query y HTTP del contrato, riesgo de transporte documentado, sin declararlo solucionado.
3. Inicio exige JWT con forma, sub/exp y RUT positivo; no verifica firma local. Login obtiene RUT antes de persistir y espera escrituras, rollback y logout serializados; generación invalida respuesta tardía. Logout elimina tres claves y navegación limpia stack. Pruebas de RUT antiguo/ausente, token vencido, persistencia fallida, login tardío y escritura concurrente con logout.
4. Login espera Future, bloquea taps y mantiene indicador; comprobación mounted tras await. Pruebas controlan una llamada y ausencia de navegación prematura.
5. Captura distingue cancelación FormatException/UserCanceled y permiso denegado, rechaza QR malformado/inactivo antes de matrícula; exige los cinco campos contrastados con `AsistenciaServicio.qrJson`. Guarda exclusión mientras consulta y descarta resultados tras invalidación de sesión. Cámara física no validada.
6. Confirmación bloquea envío doble y back mientras POST pendiente; solo prefijo verificado confirma. Rechazos 401–407 de dominio se separan de desconocido/timeout, que bloquea reenvío y solicita verificación docente. POST conserva tres campos, sin estado local. Fuente `RegistroAsistenciaService` conserva autoridad de PRESENTE/ATRASADO y rotación. No se enviaron peticiones productivas ni datos reales.

Los tres hallazgos anteriores quedaron RESUELTOS: finder compatible, lista de widgets sin collection-if y doble HTTP sin código inalcanzable. La revisión posterior confirmó también clasificación HTTP 400/401/403 de confirmación y distinción 401/403 al consultar matrícula; 500/transporte siguen inciertos. Los errores de login visible y logout fallido tienen ahora pruebas de widget.

## Checks propios

| Control | Comando | Exit / resultado | Evidencia |
|---|---|---|---|
| Análisis primera revisión | `docker exec -w /work/final sra-mobile-verify-20261020 sh -c 'flutter --version; java -version; sha256sum pubspec.lock; flutter analyze'` | 1 / FAIL: 4 errores, 5 infos | independent-analyze.log |
| APK debug snapshot previo al rework | `docker exec -w /work/final sra-mobile-verify-20261020 sh -c 'flutter build apk --debug'` | 0 / PASS: 19.8s; superado por build2 | independent-build.log |
| Whitespace diff | `git diff --check` | 0 / PASS | checkout host |
| Lock/config nativos | `sha256sum pubspec.lock`; `git diff -- pubspec.lock pubspec.yaml android ios .gitlab-ci.yml` | 0 / PASS: hash idéntico, sin diff | checkout host y copia aislada |

| Análisis final tras rework | `docker exec -w /work/final sra-mobile-verify-20261020 sh -c 'flutter analyze'` | 1 / FAIL: solo 2 infos previos, 0 errores; mejora frente 6 infos baseline | independent-analyze2.log |
| APK debug final tras rework | `docker exec -w /work/final sra-mobile-verify-20261020 sh -c 'flutter build apk --debug'` | 0 / PASS: 8.6s; archivo generado | independent-build2.log |
| Suite final ejecutada por orquestador, log inspeccionado por verifier | `docker exec -w /work/final sra-mobile-tests-20261020 flutter test` | 0 / PASS: 43 pruebas | final-test.log |

Se inspeccionó el APK generado como archivo ZIP íntegro (`unzip -t`, exit 0), SHA-256 `6960f7859f365a76b1b6066811f8acc2649e6e43acb2a48bb664c9b86fe344c0`. Los dos infos finales son los previos `PieChartSample2.asignatura` must_be_immutable y `parseDouble` camel_case_types; no se maquilló el exit 1. El gate global de análisis permanece FAIL, aunque no introduce regresiones. Dependencias, Gradle y workaround barcode_scan permanecen sin diff. El lock conserva hash antes/después en copia final y host.

## Cobertura y límites materiales

Pruebas nuevas cubren los riesgos principales sin cámara ni red productiva. La aserción de error visible login y liberación de loading quedó agregada y ejecutada. Logout fallido se verifica con servicio falso en widget; no se caracteriza un fallo por clave individual en SharedPreferences nativo ni su semántica de persistencia tras reinicio. No se convierten esas inspecciones en PASS dinámico. Integración HTTP aislada contra backend, permisos/cámara/background Android, iOS (sin entorno macOS/dispositivo y con NSCameraUsageDescription pendiente), revocación JWT real, vigencia/rotación QR y reconciliación de escritura incierta: BLOCKED/NOT_RUN. Un APK debug acredita compilación Android, no estas capacidades ni release.

Los documentos de agentes y este informe están ignorados por la configuración local existente (`git check-ignore` confirmado). Existen en disco, pero una futura entrega por Git debe incluirlos intencionalmente dentro de una tarea autorizada; este trabajo no hace commit/push ni modifica ignore ajeno.
