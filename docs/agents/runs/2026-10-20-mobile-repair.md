# Ejecución SRA
- ID / fecha / solicitud: 2026-10-20-mobile-repair; reparación de seis prioridades, solicitada por usuario.
- Rama / commit / git status inicial: develop / 193fccbe365d6d25fda892cd1ed4642b14f0e6ef; M .gitignore, ?? AGENTS.md, ?? README-AGENTES.md (cambios ajenos preservados). Documentación y configuración local ignoradas por Git; siguen disponibles en disco.
- Objetivo y alcance autorizado: diagnóstico, reparación mínima, pruebas e inspección backend solo lectura; sin commit/push/merge/APK publicado.
- Entorno disponible y faltante: Docker 29.8.2 disponible; flutter/dart no están en PATH. Se está obteniendo imagen CI fijada. Sin cámara/dispositivo/macOS confirmados.
- Baseline, lock y contratos: copia anterior a ediciones en /tmp/sra-mobile-baseline-culg2772/app. SHA256 pubspec.lock 36ad4337f91a7eebfcf5eb52c3818d44a98d3d6f30c61c4cec250d8107136a35. Hallazgos históricos requieren contraste actual. Backend ../sra-346-servicios presente, no incluido en fotografía ZIP.

| Tarea | Estado | Rol | Paths reservados | Depende de | Criterio / evidencia |
|---|---|---|---|---|---|
| Mapa / contratos | DONE (fuente) | maintainer | ninguno; lectura | — | interfaces y evidencia backend |
| API / sesión | DONE local | mobile-api-auth | ninguno; lectura | — | caracterización servicios |
| UI / QR | DONE local / dispositivo pendiente | mobile-ui-qr | ninguno; lectura | — | estados y pruebas |
| Baseline / coordinación | DONE | orchestrator | este RUN | — | copia aislada y controles separados |

## Decisiones y contrato entre capas
Se cargaron AGENTS.md, RUNTIMES.md, PROJECT_CONTEXT, WORKFLOW, BACKLOG, plantillas y cinco skills locales solicitadas. Roles genéricos con instrucciones TOML locales; coordinación directa, sin subdelegación. Tres slots hijos; verifier se inicia al congelar diff y liberar especialistas.

## Delegaciones y liberación de archivos
Diagnósticos paralelos solo lectura. Implementación pendiente de contratos y asignación exacta. Orquestador no edita aplicación.

## Cambios integrados y diff final
Pendiente.

## Verificación
| Criterio | Comando o escenario | Entorno | Código de salida | PASS/FAIL/BLOCKED/NOT_RUN | Evidencia redactada |
|---|---|---|---|---|---|
| Docker | docker info --format '{{.ServerVersion}}' | host | 0 | PASS | 29.8.2 |
| Lock inicial | sha256sum pubspec.lock | host | 0 | PASS | hash arriba |
| Tests baseline | sin directorio test en checkout inicial | lectura | — | NOT_RUN | ausencia confirmada |

## Riesgos y bloqueos externos
Cámara e integración no se acreditan con inspección estática. No datos reales, no peticiones productivas. Credenciales body/HTTPS requieren soporte confirmado. No reintento automático de asistencia incierta.

## Resultado: PARCIAL
Ejecución en curso.

## Propuesta de MR/PR y trabajo pendiente
Pendiente de implementación y revisión.

## Asignaciones READY → IMPLEMENTING (contratos acordados)
- mobile-api-auth: lib/src/services/{apiService,jwtService,loginService,registerService,asignaturaService}.dart; lib/src/errors/appException.dart; test/services/{api_service,jwt_service,login_service,register_service}_test.dart y session_fixtures.dart; docs/agents/API_CONTRACTS.md.
- mobile-ui-qr: lib/src/screens/{LoginPage,DrawerWidget,QRLectorComponent,ConfirmationAttendance}.dart; lib/src/models/qr.dart; test/widgets/{login_page,qr_scan,confirmation_attendance,drawer}_test.dart; docs/agents/QR_CONTRACT.md.
- maintainer: lib/main.dart; lib/src/screens/AttendancePage.dart; test/app_test.dart; docs/agents/{PROJECT_CONTEXT,BACKLOG}.md.
- Estas asignaciones concretan campos de DELEGATION: checkout/base arriba, modo implementación, solo paths listados, consulta otros archivos permitida, sin subdelegación ni producción; aceptación skills API/QR y regresión con fixtures sintéticos. Informe con causa, evidencia, comandos/códigos y liberación.
- Interfaz: JwtService.hasValidSession Future<bool>; getRut Future<int> devuelve null ausente; removeToken espera limpiar token/rut/username; signIn resuelve solo con sesión y RUT persistidos. UI elimina fetchRut redundante. RegisterService.add conserva respuesta dinámica.
- Backend consultado en lectura commit a7637f62428009545cc5ad76226b3afed85bcc95: QR cinco campos, éxito prefijo exacto, errores conocidos; sin endpoint autoritativo de reconciliación confirmado. No modifica protocolo/body/TLS.
- `rg -n 'print\(|debugPrint\(' lib` baseline: 19 ubicaciones de logs (JWT, RUT, QR, respuestas y excepciones). Registro redactado, sin datos reales.

## Baseline medido y primera verificación
- Imagen CI obtenida por digest (docker pull exit0). Contenedor sra-mobile-verify-20261020, usuario cirrus UID1000. `flutter --version`, `dart --version`, `java -version` exit0: 1.12.13+hotfix.9 / 2.7.2 / 1.8.0_222.
- `flutter pub get` baseline exit0, 7.0s; lock intacto.
- `flutter analyze` baseline exit1, 6 infos: unused_import main; unused_field Login; must_be_immutable PieChart; 2 unused_import QR; camel_case_types parseDouble.
- `flutter build apk --debug` baseline exit0, 113.1s, APK producido en copia aislada. No publicación.
- Entorno de pruebas separado sra-mobile-tests-20261020; copia staging previa a congelación. Primera suite FAIL compilación apiService case200: Dart2.7 no considera el try/catch retorno terminal. API corrigió return fuera de try/catch y liberó. Ejecución staging terminó exit1.
- Todos autores liberaron; snapshot /work/final; revisión independiente mobile-verifier y lectura de integración maintainer. `flutter pub get` final exit0; `flutter test --reporter expanded` exit64 (flag no soportado; corregido comando, no código).
- `flutter test` final exit1: 30 pruebas PASS y archivo confirmation test no compila por find.textContaining ausente en Flutter1.12. Devuelto a autor UI y sustituido finder compatible. Analizador independiente detectó además 2 infos collection-if y 1 dead_code nuevos: rework acotado.
- Revisión integración: distinguir403 autorización de401 sesión; distinguir rechazo HTTP explícito de red incierta en confirmación. Rework UI con pruebas.
- Reservas REWORK: UI pantallas/tests originales; API solo test/services/login_service_test.dart. Verifier no modifica implementación.
- Logs de entorno temporales: /tmp/sra-mobile-baseline-culg2772/{analyze,build,staging-test,final-test,independent-analyze}.log. Al cierre se conservará evidencia seleccionada dentro de docs/agents/runs.

## Cierre de implementación y revisión independiente
Todos los propietarios liberaron los archivos. Rework acotado corrigió compatibilidad Dart/Flutter legado, limpió nuevos avisos y distinguió autorización/rechazo HTTP de incertidumbre. No cambios activos en fuentes/tests al ejecutar controles finales. Copia final y checkout coinciden byte a byte en lib, test, pubspec, lock y workaround Gradle.

### Correcciones integradas por archivo
- lib/src/services/registerService.dart: getAll consume lista decodificada y rechaza forma inesperada; constructor permite doble. Endpoint profesor conservado, disponibilidad sin confirmar.
- lib/src/services/apiService.dart: cliente/timeout inyectables, sin logs de respuestas ni cuerpos sensibles en errores; Bearer omitido si vacío; JSON/texto preservado, sin reintentos. Body vacío objeto sustentado en handlers que leen parámetros.
- lib/src/errors/appException.dart: SessionException y statusCode HTTP para distinguir401/403 sin exponer cuerpos.
- lib/src/services/jwtService.dart: RUT null explícito; comprobación local forma/exp/sub; escrituras serializadas, token al final, rollback y generación contra respuesta tardía; logout espera tres eliminaciones.
- lib/src/services/loginService.dart: signIn espera RUT y sesión completa; parámetros URI codificados; consultas de matrícula exigen sesión/RUT válidos; sin logs sensibles.
- lib/src/services/asignaturaService.dart: rechaza RUT ausente/inválido antes de HTTP.
- lib/main.dart: inicio espera sesión completa y muestra carga; elimina JWT del log.
- lib/src/screens/AttendancePage.dart: elimina RUT de log, cachea consulta y deriva con stack limpio si falta sesión/RUT; mounted tras await.
- lib/src/screens/LoginPage.dart: await de ingreso, carga hasta resolución, exclusión de taps, errores seguros y mounted; sin fetchRut redundante.
- lib/src/screens/DrawerWidget.dart: espera logout, evita duplicados, error visible si limpieza falla y elimina rutas protegidas; cambio de clave captura errores sin datos sensibles.
- lib/src/models/qr.dart: cinco campos backend con tipos y parse estricto.
- lib/src/screens/QRLectorComponent.dart: cancelar/denegar no consulta matrícula; excluye escaneos simultáneos, no conserva lectura anterior, distingue inválido/inactivo/sesión/autorización/matrícula/red; generación impide navegar tras logout.
- lib/src/screens/ConfirmationAttendance.dart: estado de envío, una solicitud concurrente, éxito solo por contrato, rechazo explícito y unknownOutcome bloqueado sin retry; cancelación pop; no calcula presente/atrasado ni envía estado.
- test/app_test.dart, test/services/* y test/widgets/*: 43 pruebas sintéticas de comportamiento. session_fixtures.dart contiene dobles locales sin red productiva.
- docs/agents/{PROJECT_CONTEXT,API_CONTRACTS,QR_CONTRACT,BACKLOG}.md: contraste checkout/backend y aceptación parcial; RUN y revisión independiente detallan evidencia.

### Comandos y resultados finales frente al baseline
La imagen es la fijada en CI, sin instalar SDK moderno. Los comandos Flutter se ejecutaron con `docker exec -w /work/final sra-mobile-tests-20261020 bash -c '<comando>'` para pub get/test y `docker exec -w /work/final sra-mobile-verify-20261020 sh -c '<comando>'` para analyze/build. Baseline mismo segundo contenedor en /work/app. Docker creado sobre copia aislada, sin credenciales de aplicación ni conexión backend.

| Criterio | Comando o escenario | Entorno | Código de salida | PASS/FAIL/BLOCKED/NOT_RUN | Evidencia |
|---|---|---|---|---|---|
| Versiones | flutter --version; dart --version; java -version (individuales) | imagen CI exacta | 0 cada uno | PASS | Flutter1.12.13+hotfix.9 / Dart2.7.2 / JDK1.8.0_222 |
| Resolver dependencias | flutter pub get | baseline/final aislados | 0/0 | PASS | lock idéntico antes/después |
| Pruebas baseline | no había test/ | copia inicial | — | NOT_RUN | no suite previa |
| Pruebas finales | flutter test | final aislado | 0 | PASS | 43 pruebas, final-test.log |
| Análisis baseline | flutter analyze | baseline aislado | 1 | FAIL | seis infos, cero errores |
| Análisis final | flutter analyze | final aislado | 1 | FAIL | dos infos PREVIOS: PieChart must_be_immutable, parseDouble camel_case_types; cero errores/nuevos avisos |
| APK baseline | flutter build apk --debug | baseline aislado | 0 | PASS | 113.1s build.log |
| APK final | flutter build apk --debug | final estable aislado | 0 | PASS | 8.6s independent-build2.log |
| Integridad APK | unzip -t build/app/outputs/apk/debug/app-debug.apk | final aislado | 0 | PASS | revisión independiente; no distribución |
| Lock | sha256sum pubspec.lock; git diff -- pubspec.lock pubspec.yaml android ios .gitlab-ci.yml | host/final | 0 | PASS | SHA25636ad4337f91a7eebfcf5eb52c3818d44a98d3d6f30c61c4cec250d8107136a35; sin cambios config/deps/workaround |
| Diff | git diff --check | host | 0 | PASS | whitespace sin errores |
| Logs | rg -n 'print\(|debugPrint\(' lib | host | 1 (sin coincidencias) | PASS estático | 19 sitios baseline ->0; no acredita dispositivo |
| API/sesión/UI/QR | dobles HTTP/storage/scanner y Futures controlados | flutter_test legado | 0 | PASS local | 43 pruebas, sin producción |
| Integración backend | HTTP real en entorno sintético | no preparado | — | NOT_RUN | solo contratos contrastados en fuente |
| Cámara Android/background | dispositivo y permisos reales | dispositivo ausente | — | BLOCKED | scanner simulado no valida cámara |
| iOS | build/permisos/cámara | sin macOS/dispositivo | — | BLOCKED | NSCameraUsageDescription pendiente de soporte iOS |
| Presente/atrasado, vigencia/rotación QR | integración real | backend sin ejecución en esta tarea | — | NOT_RUN | autoridad confirmada en fuente, no prueba dinámica |

### Evidencia conservada
Carpeta `docs/agents/runs/2026-10-20-evidence/`: logs baseline/final/rework y manifest source-sha256.json. Revisión independiente en `2026-10-20-independent-review.md`. APK queda solo en copia temporal; SHA256 final 6960f7859f365a76b1b6066811f8acc2649e6e43acb2a48bb664c9b86fe344c0. No se publica ni se copia al repo.

### Riesgos y pendientes concretos
- Análisis sigue exit1 por dos infos existentes, sin ocultar con allow_failure ni exclusiones. Pendiente limpieza separada de PieChart/parseDouble.
- Endpoint profesor/asistencias no hallado: getAll validado con fixture; confirmar ruta/rol con dueño backend antes de integración.
- Preparar backend y base sintética para login/RUT/matrícula, rechazos, expiración, presente/atrasado y rotación. No se usaron datos reales ni registros productivos.
- Mantener query/HTTP hasta tarea coordinada de transporte; codificación y retirada de logs no resuelven TLS ni secretos en infraestructura.
- Confirmar mecanismo autoritativo/idempotente antes de resolver automáticamente timeout. No existe retry automático.
- Probar cámara Android y ciclo background/reingreso en dispositivo. iOS requiere entorno y permiso de cámara verificados; no se modificó iOS.
- CI aún no ejecuta estos tests; tarea SRA09 pendiente. No se alteró CI para maquillar análisis.
- Documentación/skills/runs están ignorados por configuración local existente (.gitignore ajeno preservado); están en disco y pueden revisarse, pero no aparecerán automáticamente en un futuro commit. Revisar política de inclusión al preparar MR, sin modificarla aquí.

## Resultado final: PARCIAL
APTO para correcciones y escenarios locales comprobados; FAIL explícito del gate de analyze heredado, BLOCKED/NOT_RUN para dispositivo e integración. No defectos nuevos bloqueantes en revisión independiente. No commit, push, merge ni publicación de APK.

## Propuesta de MR/PR
Título: Corregir sesión, consumo API y registro QR en SRA móvil legado.
Descripción: El ingreso espera persistencia íntegra y RUT; logout elimina datos/rutas y descarta respuestas tardías. La captura y confirmación QR validan entradas, evitan concurrencia y conservan resultados inciertos sin reenvío. Contratos contrastados con backend local; Flutter/dependencias/workaround intactos. Validación: 43 tests PASS, APK debug PASS, analyze6->2 infos previos con exit1. Cámara/integración/iOS y TLS pendientes. Solo propuesta documental; no se creó ni publicó MR.

Todas las reservas quedan liberadas al cierre. Contenedores de verificación detenidos tras conservar logs; copias temporales retenidas para auditoría.
