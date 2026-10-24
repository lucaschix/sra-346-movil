---
name: sra-mobile-api-auth
description: Diagnosticar y reparar servicios HTTP, respuestas JSON/texto, JWT, RUT y persistencia de SRA móvil; usar en login, logout, contraseñas o integración backend.
---

# Contratos y sesión
1. Leer `docs/agents/API_CONTRACTS.md`, servicios afectados, `appException.dart` y consumidores en pantallas. Identificar qué viene del código y qué está pendiente de backend.
2. Caracterizar `ApiService`: 200 se decodifica como JSON o conserva texto, 400/401/403 lanzan excepciones, otros status van a FetchDataException. Probar 200 lista/mapa/texto, JSON inválido, 400/401/403/500 y timeout sin convertir un cuerpo desconocido en éxito.
3. Corregir consumidores contra la abstracción acordada. Para `RegisterService.getAll`, validar lista decodificada; no volver a acceder a statusCode/body ni decodificar dos veces. Determinar antes si este endpoint de profesor corresponde al flujo móvil actual.
4. Definir postcondiciones de sesión: token y usuario válidos según contrato, RUT disponible antes de flujos que lo exijan; await de escrituras; rollback de sesión parcial. No interpretar JWT decodificado como firma validada; backend sigue siendo autoridad. No inventar refresh.
5. Resolver tipo y ausencia de RUT explícitamente; no mezclar int y cadena vacía. Probar claves ausentes, datos antiguos y almacenamiento fallido.
6. Logout debe esperar limpieza de token/rut/username y coordinar eliminación de rutas protegidas. Protegerse de respuestas en vuelo que restauren datos después del logout.
7. Retirar logs sensibles. Construir parámetros con codificación de URI compatible con Dart 2.7; distinguir este arreglo de la migración segura de credenciales a body/HTTPS que necesita backend.
8. Agregar dobles inyectables mínimos: cliente HTTP disponible en la versión fijada, almacenamiento falso o canal simulado compatible. No incorporar frameworks modernos de mocking sin justificar compatibilidad.
9. Actualizar contrato y pruebas del cambio. Devolver qué no se pudo confirmar por ausencia del backend.
