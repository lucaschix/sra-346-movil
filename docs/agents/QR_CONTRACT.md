# QR y dominio
## Payload consumido
| Campo | Uso en el cliente | Validación a caracterizar |
|---|---|---|
| idClase | Register.idClase int | Identificador de clase válido según backend |
| asignatura | Texto mostrado | Cadena y límites de UI |
| asignaturaId | getMatricula(int) | ID de asignatura; falta en QR.fromJson actual |
| estadoActivo | Condición de entrada | Bool; false requiere rechazo visible |
| token | Registro | Cadena no vacía; no registrar ni persistir innecesariamente |

Fixture sintético de estructura, NO QR real ni prueba de validez backend:
```json
{"idClase":101,"asignatura":"Asignatura de prueba","asignaturaId":12,"estadoActivo":true,"token":"TOKEN_SINTETICO"}
```
RUT identifica estudiante; matrícula se consulta por estudiante/asignatura; clase identifica la sesión; registro materializa asistencia. La relación exacta de inscripción y matrícula debe confirmarse en backend. `ConfirmationAttendance.username` contiene una matrícula, no el username de login. No intercambiar identificadores por semejanza de nombres.

`Register.toJson` envía idClase, numeroMatricula y token; estadoAsistencia está comentado. El ATRASADO local en la pantalla no prueba que el cliente tenga autoridad. Preservar decisión backend y rotación tras éxito conforme al análisis aportado.

## Reglas ante incertidumbre
Cancelar escaneo es una salida normal, no QR inválido. Permiso denegado no consulta matrícula. QR malformado no llega a red. Matrícula ausente no confirma. La validación local no garantiza vigencia del token al confirmar. Un timeout de escritura es resultado desconocido: consultar si existe mecanismo confirmado, o informar al usuario; no repetir automáticamente el POST ni sugerir que escanear otra vez garantiza que no habrá duplicado.

## Contraste con checkout backend local (20-10-2026)
Fuente: `sra-346-servicios/src/main/java/cl/ufro/dci/sra346servicios/controller/AsistenciaServicio.java`, `qrJson`, `registrarCodigoQR`; `service/RegistroAsistenciaService.java`, `registrar`, `validarCodigo`, `registrarAsistencia`, `marcarAsistencia`.

- El QR emitido tiene los cinco campos anteriores; ids numéricos, estado booleano, nombre/token cadena. El cliente ahora rechaza estructura o tipos incorrectos antes de red.
- POST JSON mantiene `idClase`, `numeroMatricula`, `token`; la respuesta textual de éxito empieza exactamente por `Alumno ingresado con exito->Alumno:`. `Error 401:` a `Error 407:` son rechazos de dominio definidos por ese servicio; no son status HTTP.
- El backend verifica código activo y token, matrícula/inscripción/asistencia; decide PRESENTE/ATRASADO, cambia token y guarda. No se envía estado calculado localmente.
- HTTP 400/401/403 se muestran como rechazos conocidos, diferenciando sesión inválida de acceso denegado. Texto/mapa desconocido, HTTP no caracterizado y excepción de transporte quedan como resultado incierto; la confirmación no permite repetir. Se pide verificar con el docente antes de intentar otro registro. Cancelar/volver hace pop y no agrega pantallas de cursos.
- Captura inyectable y Futures controlados permiten probar cancelación, permiso, tipos, matrícula y concurrencia sin cámara ni asistencia real. Esto no valida permisos/cámara del dispositivo ni integración con un backend desplegado.
