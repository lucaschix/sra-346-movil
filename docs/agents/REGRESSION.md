# Matriz de regresión
Ejecutar casos relevantes al cambio y flujos dependientes. La tabla prescribe resultados deseados, no afirma que hoy se cumplan.

| Caso | Resultado / evidencia | Nivel |
|---|---|---|
| API 200 lista/mapa/texto | Tipo correcto y consumidor sin doble decode | Unitario |
| API 200 forma inesperada / JSON inválido | No falso éxito de asistencia; error controlado | Unitario |
| 400,401,403,500; timeout/conexión | Error tipado; distinguir permisos/sesión/red | Unitario |
| GET registros | Lista de Register; sin acceso statusCode/body al dato | Unitario |
| Login correcto/incompleto, storage falla | Sesión íntegra o rollback; sin logs secretos | Unitario/widget |
| RUT ausente o tipo legado incorrecto | Sin TypeError; ruta de sesión incompleta | Unitario |
| Login doble tap / Future pendiente | Una solicitud; loading hasta finalizar | Widget con Future controlado |
| Salida de pantalla durante await | Sin setState/navegación tras dispose | Widget |
| Logout y back/reinicio | Token/RUT/username borrados; sin ruta autenticada | Widget/manual |
| Respuesta tardía tras logout | No restaura sesión ni navega protegido | Unitario/widget |
| Recuperar clave: email vacío, 200 incompleto y doble tap | Sin HTTP para vacío; sin falso éxito; una secuencia pendiente | Unitario/widget |
| Cambio interno: clave vacía, token inválido y doble tap | Sin HTTP inválido; error visible; una secuencia y sesión limpiada al éxito | Unitario/widget |
| Asignaturas vacías, respuesta no lista o elemento mal formado | Estado vacío explícito o fallo controlado sin filtrar detalle | Unitario/widget |
| Campos de asignatura ausentes/tipo erróneo/límites 0 y 100 | Rechazo de forma inválida; límites aceptados | Unitario |
| Porcentajes negativos, sobre 100, NaN o infinito | Rechazo antes de construir gráfico | Unitario |
| Porcentajes todos cero | Estado sin registros; sin coordenadas NaN ni excepción | Widget |
| Reconstrucción del padre durante carga de asignaturas | Conserva el mismo Future y realiza una consulta | Widget |
| Cancelar y denegar cámara | Cero consulta de matrícula y cero POST | Widget con escáner falso/dispositivo |
| QR vacío, texto, lista, campos faltantes/tipos erróneos | Rechazo local legible, sin red | Unitario |
| QR inactivo y token obsoleto | Mensaje adecuado; autoridad backend | Unitario/integración |
| Matrícula ausente/rechazada y RUT ausente | No permite confirmación | Unitario/widget |
| Doble confirmación | Una petición concurrente y botón protegido | Widget |
| Éxito/error/texto desconocido al registrar | Clasificación según contrato real | Unitario/integración |
| Timeout tras commit servidor | Resultado incierto, no reenvío automático | Integración simulada |
| Presente/atrasado y token rotado | Decisión backend, no cálculo móvil | Integración backend |
| Cámara Android/iOS y background | Permisos/ciclo de vida comprobados | Dispositivo |
| Runtime/lock/analizador/APK | Versiones fijadas, hash intacto y resultados | Build |
| Pipeline con regresión o análisis nuevo | Jobs `test` y `analyze` bloquean antes del APK | CI/configuración |

Para pruebas nuevas usar `flutter_test` existente, fakes simples e inyección mínima. Confirmar APIs de mocks/canales en versiones fijadas antes de utilizarlas. No agregar APIs null-safe. Verificar cantidad de invocaciones y estado visible, no solo existencia de widgets. Separar fixtures sintéticos de respuestas backend verificadas. Si backend/dispositivo no está disponible, marcar casos NOT_RUN/BLOCKED, no reemplazarlos por una inspección estática aprobada.
