# SRA móvil — instrucciones del repositorio

## Entrada y alcance
Actuar como `sra-mobile-orchestrator` para solicitudes de reparación de varios componentes; cargar `.agents/skills/sra-mobile-orchestrate/SKILL.md`. Para una tarea pequeña, usar solo la especialidad pertinente y verificar el resultado. Estas instrucciones autorizan delegar tareas delimitadas cuando las herramientas de la sesión lo permitan. Si no hay subagentes, ejecutar los mismos roles secuencialmente sin afirmar que se crearon agentes.

Leer `docs/agents/PROJECT_CONTEXT.md`, `RUNTIMES.md` y el código afectado antes de editar. El contexto es una fotografía, no sustituye la inspección del checkout actual. Todos los paths de esta documentación son relativos a la raíz del repositorio.

## Restricciones técnicas
- Conservar Flutter 1.12.13+hotfix.9, Dart 2.7.2 sin null safety, JDK 8, Gradle 5.6.2, AGP 3.5.0, Kotlin 1.3.50. No introducir `late`, `required`, tipos nullable de null safety, `context.mounted`, records ni APIs de Flutter moderno. En State usar `mounted` cuando corresponda.
- Mantener `pubspec.lock`, versiones fijadas y workaround `barcode_scan` en `android/build.gradle`. Actualizar SDK, dependencias o arquitectura exige una tarea de migración explícita, separada de la reparación.
- Comandos y entorno: `.agents/skills/sra-mobile-build/SKILL.md`. No atribuirse el build histórico de RUNTIMES.md como validación actual.
- Priorizar correcciones pequeñas y pruebas de comportamiento. No reformatear todo el repositorio.

## Integración y asistencia
- `ApiService` devuelve JSON decodificado o texto; no devuelve `http.Response`. Revisar todos sus consumidores si cambia la abstracción.
- No inventar contratos backend. Registrar método, path, entrada, status, cuerpo, efectos y fuente de evidencia en `docs/agents/API_CONTRACTS.md`.
- El backend decide presente/atrasado y rota el token tras registrar exitosamente, según el análisis entregado. Son restricciones del trabajo; el backend no vino en este ZIP y falta verificarlas en fuente o ambiente de pruebas.
- No calcular asistencia local ni enviar `estadoAsistencia` sin contrato explícito. Un timeout de registro puede ocultar una escritura exitosa: no repetir automáticamente ni asumir fracaso confirmado. Resolver con consulta autoritativa disponible o informar resultado incierto.
- Diferenciar cancelación, permiso denegado, QR malformado/inactivo, matrícula ausente, sesión inválida, fallo de red y rechazo del servidor.
- Nunca registrar tokens JWT/QR, contraseñas, URLs con credenciales o cuerpos de respuesta sensibles. Usar fixtures sintéticos y logs redactados.
- Migrar credenciales de query a body y HTTP a HTTPS requiere un contrato/endpoint disponible y verificado. No cambiar solo el cliente y declarar resuelta la exposición.

## Propiedad y Git
- Un editor por archivo. El orquestador asigna paths exactos, incluyendo tests y fixtures compartidos; liberar la asignación antes del siguiente editor. Lecturas paralelas permitidas.
- El maintainer integra y resuelve conflictos; especialistas no delegan de nuevo. El verificador no corrige su propia revisión.
- Inspeccionar `git status --short` y rama actual; preservar cambios ajenos. Usar la rama de integración existente; si el equipo usa Git Flow, partir de `develop` y usar `fix/<tema>`. No asumir que el nombre del ZIP demuestra una rama o un remoto.
- No hacer reset destructivo, force push, merge, release, publicación ni registro real de asistencia sin autorización específica. Las reparaciones y pruebas aisladas solicitadas sí están autorizadas.

## Cierre
Reportar causa, archivos, contrato, pruebas/comandos con códigos de salida, diferencia frente a baseline, riesgos y pendientes. Usar PASS, FAIL, BLOCKED o NOT_RUN. Un APK debug no acredita distribución; cámara real, integración backend e iOS requieren evidencia propia. No declarar terminado un criterio bloqueado.
