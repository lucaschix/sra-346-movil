---
name: sra-mobile-attendance-qr
description: Reparar escaneo QR, permisos, matrícula y confirmación de asistencia en SRA móvil; usar también para concurrencia, navegación y respuestas ambiguas al registrar.
---

# Escaneo y registro
1. Leer `docs/agents/QR_CONTRACT.md`, `QRLectorComponent.dart`, `ConfirmationAttendance.dart`, modelos y servicios. Verificar la API instalada de barcode_scan 2.0.1, no copiar ejemplos modernos.
2. Modelar estados separados: idle, scanning, canceled, permissionDenied, invalid, resolvingEnrollment, ready, submitting, success, rejected, unknownOutcome. Pueden implementarse con enum/clases compatibles, sin exigir una biblioteca de estado.
3. Reiniciar datos previos antes de escanear. Retornar inmediatamente en cancelación/permisos/error. No invocar next, matrícula ni confirmación sin lectura validada. No mostrar QR crudo en errores/logs.
4. Validar JSON Map, campos y tipos antes de consultar matrícula. Tratar estadoActivo=false de forma visible; no atribuirle validez autoritativa al QR offline.
5. Consultar matrícula usando asignaturaId y RUT; no confundir nombre de usuario, RUT e inscripción. Si falta matrícula, no registrar asistencia.
6. Bloquear dobles taps de escaneo y confirmación. En State comprobar mounted tras await antes de setState/navegar. Capturar excepciones y liberar loading de forma controlada.
7. Interpretar éxito solo mediante contrato confirmado o fixtures documentados; jamás por ausencia del substring Error. Texto/cuerpo desconocido es resultado no confirmado.
8. Tras timeout de POST no reenviar automáticamente. El servidor puede haber escrito y rotado el token; usar consulta autoritativa si existe o informar incertidumbre y pedir verificación antes de nuevo intento. No prometer exactly-once mediante deshabilitar un botón.
9. Eliminar rutas obsoletas tras éxito/logout según alcance, sin apilar AttendancePage por cada cancelar. Probar atrás, reingreso y salida durante operaciones.
10. Validar cámara real en Android y, si se modifica iOS, permisos en Info.plist y dispositivo/macOS. Registrar limitación si no están disponibles.
