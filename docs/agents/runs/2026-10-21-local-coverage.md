# Ejecución SRA
- ID / fecha / solicitud: 2026-10-21-local-coverage; completar cobertura y controles realizables localmente.
- Rama / commit / git status inicial: `develop` / `193fccbe365d6d25fda892cd1ed4642b14f0e6ef`; se preservan los cambios de la reparación anterior y los cambios ajenos en `.gitignore`, `AGENTS.md` y `README-AGENTES.md`.
- Objetivo y alcance autorizado: eliminar los dos avisos restantes, ampliar pruebas de contraseñas/asignaturas/pantallas/campos y añadir tests bloqueantes a CI. Sin backend real, dispositivos, iOS, commit, push, merge ni publicación.
- Entorno disponible y faltante: Docker e imagen CI exacta disponibles. Sin Flutter/Dart host, cámara/dispositivo Android, macOS/Xcode ni backend de pruebas preparado.
- Baseline, lock y contratos: copia aislada `/tmp/sra-mobile-stage2.Faqnma`; lock inicial `36ad4337f91a7eebfcf5eb52c3818d44a98d3d6f30c61c4cec250d8107136a35`. Contratos documentados y backend vecino solo lectura.

| Tarea | Estado | Rol | Paths reservados | Depende de | Criterio / evidencia |
|---|---|---|---|---|---|
| Reproducir baseline actual | DONE | mobile-verifier secuencial | copia aislada; este RUN | — | 43 tests, analyze 2 infos y lock |
| Mapa y solución mínima | DONE | sra-mobile-maintainer secuencial | liberados | baseline | archivos y contratos estables |
| Contraseñas y servicios | DONE local | mobile-api-auth secuencial | liberados | mapa | 14 pruebas dirigidas PASS |
| Formularios y navegación | DONE local | mobile-ui-qr secuencial | liberados | contrato API | 10 pruebas widget dirigidas PASS |
| Integración y CI | DONE local | sra-mobile-maintainer secuencial | liberados | especialistas liberados | 66 tests, analyze 0, CI test bloqueante |
| Revisión independiente | DONE | mobile-verifier secuencial | informe final | liberación total | checks finales completos |

## Decisiones y contrato entre capas
Los subagentes anteriores no están activos y la solicitud prohíbe crear otros. Los roles se ejecutarán secuencialmente según el modo degradado de `AGENTS.md`, con un único editor por archivo y liberación explícita entre fases.

## Delegaciones y liberación de archivos
Baseline reproducido antes de editar: `flutter test` exit 0 con 43 pruebas;
`flutter analyze` exit 1 con los dos infos esperados; lock intacto. La fase API
liberó sus cuatro paths tras 14 pruebas dirigidas PASS. La fase UI liberó sus
cuatro paths con 10 pruebas widget dirigidas PASS. Maintainer liberó los paths de
integración tras 13 pruebas dirigidas, la suite completa de 66 pruebas y análisis
sin hallazgos. El diff queda congelado para verificación.

## Cambios integrados y diff final
Servicios de contraseña y asignaturas validan entradas y postcondiciones. Los
diálogos esperan, bloquean duplicados y mantienen errores recuperables; el cambio
interno espera limpieza de sesión y elimina rutas protegidas. Las asignaturas
validan forma y dominio, muestran carga/vacío/error redactado, conservan su Future
entre reconstrucciones y evitan el cálculo NaN del gráfico cuando todos los
porcentajes son cero. Los dos avisos del analizador fueron corregidos. CI ahora
ejecuta análisis y tests bloqueantes antes del build.

## Verificación
| Criterio | Comando o escenario | Entorno | Código de salida | PASS/FAIL/BLOCKED/NOT_RUN | Evidencia redactada |
|---|---|---|---|---|---|
| Lock inicial | `sha256sum pubspec.lock` | host | 0 | PASS | hash documentado arriba |
| Pruebas dirigidas API | `flutter test test/services/login_service_test.dart test/services/asignatura_service_test.dart` | imagen fijada | 0 | PASS | 14 pruebas |
| Pruebas dirigidas UI | `flutter test test/widgets/login_page_test.dart test/widgets/drawer_test.dart` | imagen fijada | 0 | PASS | 10 pruebas |
| Pruebas dirigidas asignaturas | `flutter test test/models/asignatura_test.dart test/widgets/subjects_test.dart test/app_test.dart` | imagen fijada | 0 | PASS | 13 pruebas |
| Suite previa a congelar | `flutter test` | imagen fijada | 0 | PASS | 66 pruebas |
| Análisis previo a congelar | `flutter analyze` | imagen fijada | 0 | PASS | sin hallazgos |
| Whitespace final | `git diff --check` | host | 0 | PASS | sin errores |
| Resolución final | `flutter pub get` | copia aislada nueva | 0 | PASS | lock sin cambios |
| Suite final independiente | `flutter test` | copia aislada nueva | 0 | PASS | 66 pruebas |
| Análisis final independiente | `flutter analyze` | copia aislada nueva | 0 | PASS | sin hallazgos |
| APK debug final | `flutter build apk --debug` | copia aislada nueva | 0 | PASS | 138,7 s; 59.693.891 bytes |
| Integridad APK | `unzip -t app-debug.apk`; `sha256sum` | copia aislada nueva | 0 | PASS | ZIP íntegro; `d7f238e8…252a` |
| Lock/configuración | hashes y `git diff -- pubspec* android/*gradle* ios/Podfile` | host/copia | 0 | PASS | hash idéntico; sin diff |
| Logs sensibles | `rg` de llamadas `print`, `debugPrint`, `log` | checkout final | 1 sin coincidencias | PASS | cero llamadas en `lib/**/*.dart` |
| Captura inicial de pub get | wrapper zsh con variable reservada `status` | host + contenedor | 1 | FAIL de harness | se repitió con `cmd_status`; pub get PASS |
| Cámara Android física | permisos, cancelar, escanear, background y reingreso | sin dispositivo | — | NOT_RUN | pruebas widget no sustituyen dispositivo |
| iOS/cámara | Xcode, permisos y dispositivo | sin macOS/Xcode | — | BLOCKED | entorno externo ausente |
| Backend real | login, contraseñas, asignaturas, QR y asistencia | no preparado | — | NOT_RUN | sin red ni datos reales |

## Riesgos y bloqueos externos
Cámara Android, iOS, backend real, revocación JWT, rotación QR, reconciliación tras timeout, HTTPS y endpoint profesor permanecen fuera de aceptación como BLOCKED/NOT_RUN. El FAIL de harness fue un error de captura del shell host y quedó resuelto al repetir el mismo gate; no corresponde a un fallo de Flutter ni del producto.

## Resultado: APTO local / PARCIAL integral
Todos los criterios ejecutables localmente pasan y no quedan hallazgos
bloqueantes en el diff revisado. Los escenarios que exigen infraestructura o
dispositivo conservan su estado explícito.

## Propuesta de MR/PR y trabajo pendiente
Propuesta: MR centrado en robustez de servicios/formularios/asignaturas y gates
de CI, adjuntando este RUN y la revisión independiente. Pendientes concretos:
backend de pruebas con fixtures sintéticos, dispositivo Android con cámara,
macOS/Xcode para iOS, HTTPS/credenciales coordinados y mecanismo autoritativo de
reconciliación para asistencia incierta. No se hizo commit, push, merge ni APK
publicado.
