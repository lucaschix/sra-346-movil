# Evidencia T11 — sesión y manejo de errores móvil

Fecha de ejecución: 2026-10-26 (America/Santiago).

## Referencias

- Rama móvil: `fix/t11-mobile-session-errors`.
- Base y `HEAD` sin commit T11: `419e60c73c31681f6473da6f2e3d669012d88093`.
- La base actual desciende de la migración iOS 26 `d9f6441c2c69028071407bd71e07bc19115bb7f4` y ya contiene su integración en `develop`.
- Servicios, solo lectura: `develop` en `ca1c285e6f4f861d8285c51f05baea176db5bccc`.
- Web, solo lectura: `develop` en `b6f7b21085720d2b16fb8f86403e1604aacfae9c`.
- Flutter 3.38.10; Dart 3.10.9.
- `pubspec.lock`: `71880186a2ef70d21f9ffff65aa473d2e1c2740bf713eb03c609d4c9f0e6d1e4`, sin cambios.

No se ejecutó Docker, HTTP de negocio, cambio de contraseña real, registro de
asistencia, build iOS ni prueba sobre dispositivo durante T11.

## Reproducción previa

- Sobre el árbol limpio `419e60c`, una prueba temporal de arranque con token
  aislado y sin RUT/usuario falló con exit 1: la aplicación abrió
  `AttendancePage` en vez de `LoginPage`. La prueba temporal se eliminó y el
  worktree de `develop` quedó limpio.
- Una prueba temporal de API demostró con exit 1 que un 403 se colapsaba en
  `UnauthorisedException`, igual que 401; el especialista eliminó el temporal.
- La prueba widget del diálogo reprodujo el fallo de layout
  `RenderShrinkWrappingViewport does not support returning intrinsic dimensions`
  causado por un `ListView` dentro de `rflutter_alert`. Después del cambio a
  contenido acotado, el caso queda verde.
- El código inicial usaba `Navigator.push` al salir y persistía token/usuario
  antes de obtener el RUT. Las pruebas permanentes caracterizan ahora la pila y
  el rollback completo.

## Cambios implementados

- La raíz valida una sesión local completa (`token`, RUT y usuario), rechaza JWT
  estructuralmente inválidos o vencidos y limpia estados parciales. Esta
  comprobación no valida la firma del JWT; los tokens opacos siguen dependiendo
  de la autorización del servidor.
- Login valida el esquema 200, obtiene RUT con el token recién emitido y guarda
  la sesión solo al final. Un fallo o una respuesta tardía no conserva una
  sesión parcial.
- Solo `ROLE_ESTUD` puede entrar al flujo estudiantil existente. Profesor,
  administrador y roles desconocidos no son redirigidos a endpoints de
  estudiante; su UX definitiva sigue bloqueada por D07.
- Logout elimina token/RUT/usuario y reemplaza toda la pila con Login.
- Los formularios preservan exactamente las contraseñas; los parámetros Servlet
  se codifican con `Uri.queryParameters` sin cambiar el contrato a JSON.
- API distingue 400, 401, 403, 5xx, timeout y red mediante excepciones
  sanitizadas. El timeout es configurable y por defecto es 15 segundos.
- Login público no hereda un Bearer antiguo. Los cuerpos, URI, correos, tokens y
  contraseñas no se imprimen ni forman parte de las excepciones.
- Recuperación y cambios de contraseña validan respuestas contractuales, evitan
  doble envío y no cierran/navegan como éxito ante una excepción. Las respuestas
  tardías quedan asociadas a la generación del formulario/modal que las originó:
  cerrar con X no permite que un resultado posterior cierre la ruta Login.
- Los diálogos afectados usan contenido acotado, evitando el fallo de layout.

## Archivos de aplicación editados

- `lib/main.dart`
- `lib/src/errors/appException.dart`
- `lib/src/screens/DrawerWidget.dart`
- `lib/src/screens/ErrorNotification.dart`
- `lib/src/screens/LoginPage.dart`
- `lib/src/services/apiService.dart`
- `lib/src/services/jwtService.dart`
- `lib/src/services/loginService.dart`

Pruebas nuevas:

- `test/t11/session_navigation_test.dart`
- `test/t11/api_errors_test.dart`

Los cambios locales anteriores en `.gitignore`, `AGENTS.md`,
`README-AGENTES.md` y `docs/agent-workflow/` fueron preservados; no se atribuyen
automáticamente al código T11.

## Resultado por criterio

| Criterio | Resultado | Evidencia y límite |
| --- | --- | --- |
| C03 | PARCIAL / BLOCKED | PASS local para token ausente, sesión parcial, JWT vencido/corrupto y rollback. 401/403 quedan tipados. La redirección automática ante un 403 protegido sigue bloqueada por D03 porque servicios usa 403 tanto para token inválido como rol prohibido. |
| C05 | PASS en widget | Preferencias eliminadas y pila vaciada; retroceso lógico no recupera contenido. Gesto/reinicio en iPhone actual: NOT_RUN. |
| C17 | PASS controlado | Red, timeout, 5xx, respuestas 200 desconocidas, doble envío, dispose y rechazo de contraseña cubiertos con fakes. Efectos reales de correo/clave: NOT_RUN. |
| C20 | PASS parcial / BLOCKED | Configuración y timeout reproducibles, parámetros exactos y ausencia de marcadores sensibles en logs: PASS. TLS/default HTTP sigue bloqueado por D01/D02/D06. |
| C21 móvil | BLOCKED / NOT_RUN | No hubo backend desechable, cuenta y operación de asistencia autorizados. Los mocks no acreditan integración. |

## Hallazgos relacionados

| ID | Estado T11 |
| --- | --- |
| M02 | CORREGIDO con prueba widget; prueba nativa pendiente. |
| M04 | CORREGIDO localmente; señal remota definitiva bloqueada por D03. |
| M06 | MITIGADO: valores exactos y query codificada; transporte seguro bloqueado por D01/D02. |
| M07 | CORREGIDO en flujos afectados: `finally`, `mounted` y doble envío. |
| M08 | PARCIAL: timeout tipado y sin confirmación falsa; idempotencia/resultado de escrituras pertenece a D04/T10. |
| M11 | BLOQUEADO por D07; se impide abrir el flujo de estudiante con otro rol. |
| M12 | PARCIAL: categorías separadas y mensajes seguros; semántica de 403 bloqueada por D03. |
| M13 | PARCIAL: contrato y UI con fakes; efecto real bloqueado por D05 y falta de entorno desechable. |
| M14 | CORREGIDO en widget para el fallo de layout; cierre con X en iPhone pendiente. |
| M16 | CORREGIDO en los paths T11 y cubierto con marcador sintético. |

## Validación ejecutada

```text
flutter pub get --offline --enforce-lockfile       PASS, exit 0
flutter analyze                                    PASS, exit 0, 0 issues
flutter test --no-pub --reporter expanded          PASS, exit 0, 38/38
git diff --check                                   PASS, exit 0
sha256sum pubspec.lock                             PASS, hash intacto
```

La suite contiene 14 pruebas de migración previas y 24 pruebas T11 nuevas. Las
pruebas T11 usan únicamente HTTP y almacenamiento falsos.

## Bloqueos y siguiente paso

- D03: acordar señal que distingue token inválido de rol sin permiso.
- D05: acordar postcondición y revocación de sesión después de cambios de clave.
- D07: decidir roles soportados y sus pantallas móviles.
- D01/D02/D06: definir endpoint por ambiente y transporte seguro sin alterar el
  contrato Servlet unilateralmente.
- D08: no se añadieron reglas de complejidad de contraseña.

La primera revisión independiente devolvió NO APTO por dos carreras de
operaciones tardías. Tras corregirlas y ampliar la cobertura, la segunda
revisión independiente obtuvo 38/38, análisis y diff PASS, y emitió veredicto
APTO para entregar con los bloqueos externos anteriores documentados.

El siguiente paso es revisar este diff y, solo con autorización explícita,
crear commits T11 pequeños. Después se debe compilar un artefacto nuevo y
probarlo en iPhone; C21 se ejecuta únicamente con backend y datos de ensayo
autorizados. No hay commit, push ni merge en esta entrega.
