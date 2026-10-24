# Contratos contrastados con el checkout local

Evidencia de lectura al 20-10-2026: backend hermano `../sra-346-servicios`, HEAD `a7637f62428009545cc5ad76226b3afed85bcc95`. Esta revisión de fuentes no acredita integración HTTP ni disponibilidad del servidor. No se enviaron credenciales reales ni registros de asistencia.

| Método / ruta | Entrada | Status/cuerpo y efectos | Fuente backend |
|---|---|---|---|
| POST `api/login` | request parameters `username`, `password` (query soportada; filtro también obtiene form parameters) | 200 mapa `token` string y `user.username` string; filtro emite JWT con `sub`, `exp`; fallo de autenticación 401 | `auth/jwt/filter/JWTAuthenticationFilter.java`, `attemptAuthentication`, `successfulAuthentication`, `unsuccessfulAuthentication`; `auth/jwt/service/JWTServiceImpl.java:createToken` |
| POST `api/rut/` | query `email`; Bearer JWT | 200 mapa `mensaje: Proceso exitoso`, `digitos` número entero; 500 mapa mensaje si no existe | `controller/RestoreRestController.java:getRutForEmail`; `auth/jwt/filter/RutService.java:getRutFromEmail` |
| GET `asistencia/estudiante/asignaturas/` | query `estRut` entero positivo; Bearer | lista de asignaturas y porcentajes; sin escritura | `controller/AsistenciaServicio.java:listarAsignaturasByMatricula` |
| GET `asistencia/estudiante/matricula/` | query `asignatura`, `estRut`; Bearer | mapa `matricula` string; sin inscripción, implementación desreferencia null (puede resultar 500, no contrato 404) | `controller/AsistenciaServicio.java:getMatricula` |
| GET `profesor/asistencias` | sin parámetros | cliente espera lista; no se encontró handler equivalente en backend local; `RegisterService.getAll` no tiene consumidores en pantallas | búsqueda de mappings backend y consumidores cliente |
| POST `asistencia/registrarCodigoQR/` | JSON `idClase` entero, `numeroMatricula` string, `token` string; Bearer | 200 texto con prefijo exacto `Alumno ingresado con exito->Alumno:` si registra; 200 texto `Error 401:` .. `Error 407:` si rechaza; modifica asistencia y rota token QR | `controller/AsistenciaServicio.java:registrarCodigoQR`; `service/RegistroAsistenciaService.java:registrar`, `registrarAsistencia`, `marcarAsistencia` |
| POST `api/enviar_token` | query `email` | mapa mensaje; puede emitir correo, no probado con usuarios reales | `controller/RestoreRestController.java:sendEmail` |
| POST `api/validar_token` | query `token` | mapa `validezToken`; valida token de recuperación | `controller/RestoreRestController.java:validateToken` |
| POST `api/recuperar` | query `token`, `nuevaClave` | mapa mensaje; cambia contraseña cuando token autorizado | `controller/RestoreRestController.java:saveNewPassword` |
| POST `api/cambio_interno` | query `claveActual`; Bearer | mapa `token` para recuperación cuando contraseña válida | `controller/RestoreRestController.java:validateActualPassword` |

Para recuperación, la app acepta como éxito de `api/enviar_token` únicamente el
mensaje exacto documentado junto al correo solicitado. `api/validar_token` debe
devolver `validezToken: true`; luego `api/recuperar` o el flujo iniciado por
`api/cambio_interno` debe terminar con `mensaje: Clave cambiada con exito`.
Respuestas 200 incompletas o con otra forma se tratan como fallo controlado. Los
campos vacíos se rechazan antes de usar HTTP y los parámetros siguen codificados
con `Uri(queryParameters: ...)`.

## Abstracción HTTP preservada y correcciones

`ApiService` devuelve JSON decodificado o texto en 200; 400 lanza `BadRequestException`, 401/403 `UnauthorisedException` con `statusCode`, otros status `FetchDataException`. No se interpretan 201/204 sin evidencia. La respuesta desconocida de asistencia sigue siendo desconocida, no éxito. Timeout de 20 segundos sin reintentos: un timeout del POST de asistencia puede esconder escritura exitosa. Los errores no incluyen cuerpos de respuesta sensibles.

Los servicios codifican parámetros con `Uri(queryParameters: ...)`. Se conserva el contrato query sobre HTTP existente; esta corrección no resuelve exposición de credenciales en transporte o infraestructura. No se habilitó HTTPS ni se migró a body sin despliegue coordinado. El body por defecto pasa de string JSON `"{}"` a objeto `{}`: los handlers afectados leen request parameters y no ese body. Los POST de asistencia siguen serializando exclusivamente los tres campos del contrato; `estadoAsistencia` no se envía.

## Postcondiciones para UI y sesión

`LoginService.signIn` resuelve únicamente tras validar `token`, `user.username`, obtener RUT entero positivo y esperar las tres escrituras. UI llama solo `await signIn`, sin segundo `fetchRut`. El RUT se solicita con Bearer explícito en memoria antes de persistir credenciales. `fetchRut` público queda como consulta sin escritura; no hay consumidores UI tras esta corrección. Fallos de red conservan su tipo; forma incompleta/expiración/persistencia lanza `SessionException`. Escrituras parciales se limpian; logout invalida respuestas pendientes mediante generación compartida y serializa limpieza con escrituras.

`JwtService.getRut` devuelve `Future<int>` con null explícito para ausencia/tipo antiguo inválido. `hasValidSession` requiere token JWT con forma/expiración y `sub` coincidente con usuario, usuario no vacío y RUT positivo. Esto **no valida firma ni revocación**: el backend mantiene esa autoridad. `removeToken` espera borrar `token`, `rut`, `username`; devuelve cadena vacía únicamente si completó la limpieza. Fallos de almacenamiento se propagan y no se presentan como logout exitoso. `getMatricula` exige sesión completa, asignatura positiva y string matrícula no vacío; ausencia de matrícula lanza `InvalidInputException`.

Registro: UI distingue únicamente prefijo de éxito confirmado, rechazos conocidos y resultado incierto; el backend decide PRESENTE/ATRASADO y vigencia del QR. Se verificó rotación de token en fuente. No existe evidencia de endpoint idempotente ni consulta autoritativa por registro para resolver un timeout; no se inventaron ni se reintenta automáticamente.

La lista de asignaturas exige una respuesta JSON de tipo lista. Cada elemento
debe ser un mapa con `asgId` entero positivo, `dasNombre` no vacío y
`asistencia`, `atraso`, `inasistencia` numéricos finitos entre 0 y 100. La lista
vacía es válida y tiene estado visible propio. Una forma distinta falla de modo
controlado sin mostrar el cuerpo o detalle interno al usuario. El caso válido
con los tres porcentajes en cero no se entrega a `fl_chart`, que en la versión
fijada calcula coordenadas `NaN`; se muestra `Sin registros de asistencia`.

## Pendientes

Integración HTTP aislada con backend y fixtures sintéticos, expiración/revocación real, permisos por rol, despliegue HTTPS y transporte de credenciales coordinado, respuestas de inscripción ausente y resolución autoritativa de registros inciertos siguen pendientes. El endpoint de profesor se caracteriza con lista sintética; su disponibilidad no se presume.
