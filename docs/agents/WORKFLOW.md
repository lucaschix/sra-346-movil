# Flujo de trabajo
## Responsabilidades
| Rol | Decisión / entrega | Escritura |
|---|---|---|
| sra-mobile-orchestrator | Prioridad, dependencias, reservas, gates y cierre | Solo registro de coordinación |
| sra-mobile-maintainer | Diseño mínimo e integración | Archivos exactos asignados y compartidos liberados |
| mobile-api-auth | Servicios, sesión y contratos | Servicios/errores/tests asignados |
| mobile-ui-qr | Formularios, cámara y navegación | Pantallas/tests asignados |
| mobile-verifier | Evidencia independiente | Informe; no corrige implementación |

La jerarquía es lógica: orquestador coordina directamente al principal técnico y a los tres especialistas. El maintainer no crea otro equipo. Reservar hasta cuatro hilos hijos, pero usar solo los necesarios; API y UI solo trabajan simultáneamente tras acordar interfaces y con paths disjuntos.

## Estados y condiciones
1. **DISCOVERY**: leer checkout, baseline, contratos y riesgos. Salida: causas y alcance comprobables.
2. **READY**: aceptar tarea con paths exactos, criterios, dependencia satisfecha y pruebas seleccionadas. Salida: propietario único.
3. **IMPLEMENTING**: editar y probar lo asignado. Cambiar alcance requiere reasignación del orquestador, no invadir otro archivo.
4. **INTEGRATING**: especialistas liberan paths; maintainer revisa diff y contratos entre capas.
5. **VERIFYING**: congelar ediciones; verifier reproduce y registra evidencia independiente.
6. **DONE**: criterios cumplidos con evidencia. **REWORK** devuelve problemas al autor y luego a VERIFYING. **BLOCKED** registra dependencia externa y continúa lo independiente.

No hay límite artificial de intentos que convierta un fallo en éxito; si se repite sin nueva evidencia, investigar causa o declarar bloqueo concreto.

## Gates
- G0: runtime y baseline identificados; si falta build, se permite diagnóstico/corrección local demostrable, pero no se afirma validación de compilación.
- G1: contratos que cambian tienen fuente y fixtures. Ausencia de backend bloquea cambios de protocolo, no retiro de logs o cancelación local.
- G2: regresión del bug cubierta con prueba significativa cuando haya entorno; cambios sin ejecución quedan explícitamente parciales.
- G3: integración sin solapamientos, diff acotado, lock intacto o cambio expresamente justificado.
- G4: análisis, tests, APK y escenarios manuales aplicables con estado explícito. Un fallo previo se registra, no se oculta.
- G5: revisión humana de MR/PR; publicación/merge fuera del flujo automático.

## Reanudación
Leer la última ejecución, verificar git status/diff y que el registro coincide con archivos reales. No confiar en reservas de un proceso ya terminado: reconciliar y reasignar antes de editar. Preservar cambios del usuario y nunca simular evidencia perdida.
