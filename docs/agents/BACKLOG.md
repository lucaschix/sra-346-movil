# Plan inicial de reparación
La tabla inicial describe la planificación del paquete. El estado actualizado de esta sesión se detalla al final y en su RUN; no confundir implementación con validación ejecutada.

| ID | Prioridad | Tarea | Responsable | Dependencia | Aceptación |
|---|---|---|---|---|---|
| SRA-00 | P0 | Reproducir baseline y runtime | verifier | Ninguna | Versiones, lock y comandos con resultado real |
| SRA-01 | P0 | Caracterizar API y crear dobles mínimos | api-auth + maintainer | SRA-00 o bloqueo registrado | Lista/mapa/texto/errores sin red real; contratos separados de supuestos |
| SRA-02 | P0 | Quitar logs sensibles | api-auth y ui-qr, paths separados | Diagnóstico | JWT, QR y claves ausentes en logs de escenarios afectados |
| SRA-03 | P1 | Corregir getAll y consumo HTTP | api-auth | SRA-01 | Lista válida funciona; forma inesperada falla controladamente |
| SRA-04 | P1 | Sesión íntegra, RUT y logout | api-auth, luego ui-qr | SRA-01 | Sin sesión parcial; limpia tres claves; back no abre pantalla protegida |
| SRA-05 | P1 | Await, carga y navegación login | ui-qr | Contrato SRA-04 | Doble tap genera una petición; error libera carga; salida no usa State muerto |
| SRA-06 | P1 | Cancelación, permisos y esquema QR | ui-qr | SRA-01 | Cancelar/denegar no llama matrícula; inválido/inactivo visibles; no reutiliza QR viejo |
| SRA-07 | P1 | Confirmación y resultados ambiguos | ui-qr + api-auth | SRA-06, contrato backend | Una petición por acción; éxito explícito; timeout sin reintento ciego |
| SRA-08 | P1 | Credenciales en body y HTTPS | api-auth + dueño backend | Backend disponible | Cliente/servidor compatibles; secretos fuera de URL; TLS verificado |
| SRA-09 | P2 | CI con tests y baseline controlado | maintainer + verifier | Tests disponibles | Fallos nuevos bloquean; no esconder análisis; debug etiquetado como debug |
| SRA-10 | P2 | Cámara y ciclo de vida en dispositivo | verifier | SRA-06/07 | Permisos, cancelar, escanear, background y reingreso documentados |

Cada fila se divide si toca paths de dos autores. La migración a Flutter moderno y preparación de distribución son proyectos separados.

## Avance de esta sesión — 20-10-2026

- SRA-00: baseline reproducido en entorno compatible aislado: pub get PASS exit 0;
  analyze FAIL exit 1 con seis infos; APK debug PASS exit 0. Detalle en RUN.
- SRA-01 a SRA-07: implementadas mediante archivos disjuntos. Pruebas locales
  sintéticas PASS: `flutter test`, 43 pruebas, exit 0. Esto cubre contrato HTTP,
  sesión/persistencia, navegación, concurrencia, QR y resultados inciertos mediante
  dobles; integración backend y cámara real quedan pendientes.
- SRA-02/04: inicio y cursos eliminan logs JWT/RUT; exigen sesión completa/RUT,
  controlan State después de esperas y limpian rutas al salir. La suite contiene
  las cinco pruebas de `test/app_test.dart` además de las de servicios/UI.
- SRA-07: fuente backend confirma éxito textual explícito, cálculo servidor de
  estado y rotación. Sin consulta autoritativa confirmada para resultado incierto;
  se bloquea reenvío automático y se informa incertidumbre.
- SRA-08: PENDIENTE. HTTPS y eliminación coordinada de secretos de URL necesitan
  contrato/despliegue verificados. Retirar logs no resuelve transporte HTTP/query.
- SRA-09: PARCIAL. Analyze final FAIL exit 1 conserva dos infos previos
  (`PieChart.dart` y `parseDouble.dart`), frente a seis del baseline, sin nuevos.
  APK debug del diff exacto final PASS exit 0, 8,6 s; `unzip -t` exit 0 y lock
  intacto, confirmados en el [informe independiente](runs/2026-10-20-independent-review.md).
  CI permanece sin job de
  tests y requiere tarea posterior; no se editó CI ni migraron dependencias.
- SRA-10: NOT_RUN hasta disponer de dispositivo/cámara. Integración backend e iOS
  requieren validación propia; no se registró asistencia real.

## Avance local complementario — 21-10-2026

- SRA-01/03: `AsignaturaService` valida RUT, lista y elementos antes de
  entregarlos a UI. Se añadieron casos de lista válida/vacía, forma inválida y
  categorías HTTP.
- SRA-04/05: recuperación y cambio interno de contraseña ahora esperan toda la
  secuencia, bloquean doble pulsación, validan entradas y exigen postcondiciones
  exactas antes de informar éxito. Al completar el cambio interno se espera la
  limpieza de sesión y se eliminan rutas protegidas.
- SRA-09: IMPLEMENTADO localmente. CI contiene jobs bloqueantes separados para
  `flutter analyze`, `flutter test` y APK. En la imagen fijada, la suite ampliada
  pasa 66 pruebas y el analizador pasa con cero hallazgos. El build y la revisión
  independiente deben ejecutarse sobre el diff final antes de cerrar el RUN.
- Cobertura de asignaturas: límites 0/100, campos ausentes, tipos erróneos,
  negativos, mayores a 100, NaN/infinito, lista vacía, error redactado,
  navegación y reconstrucción sin duplicar la consulta están automatizados. El
  gráfico presenta un estado seguro cuando todos los porcentajes son cero.
- SRA-08 y SRA-10 permanecen pendientes por dependencias externas. Cámara real,
  iOS e integración HTTP con backend no se sustituyen por pruebas con dobles.
