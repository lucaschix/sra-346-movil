---
name: sra-mobile-verify
description: Verificar cambios SRA móvil con pruebas compatibles, regresión de sesión/QR y evidencia; usar antes de cerrar una corrección o preparar una MR/PR.
---

# Verificación independiente
1. Leer AGENTS.md, diff final, `docs/agents/REGRESSION.md` y reporte de baseline. No revisar un árbol que otros siguen editando.
2. Seleccionar escenarios por riesgo y archivo; cubrir el bug corregido y sus rutas de error. Ejecutar servicios con dobles HTTP/storage y widgets con Futures controlados; no usar red productiva ni datos reales de asistencia.
3. Confirmar compatibilidad sintáctica/SDK y ausencia de cambios involuntarios de lock, Gradle y dependencias. Usar sra-mobile-build para comandos y aislamiento.
4. Registrar comando exacto, entorno, código de salida y resultado por escenario. Distinguir PASS, FAIL, BLOCKED, NOT_RUN; adjuntar logs redactados. Una inspección estática no valida una cámara ni una integración.
5. Si una prueba falla, describir entrada, resultado esperado/real y ubicación al orquestador; no editar test/fuente para hacerlo pasar. Comparar con baseline cuando el fallo pueda ser previo.
6. Revisar seguridad práctica: ninguna credencial/token en logs, ausencia de reintento ciego de escritura, logout sin datos residuales ni rutas protegidas accesibles.
7. Emitir APTO para criterios comprobados; PARCIAL cuando falten pruebas materiales; NO APTO por regresión/criterio fallido. Exponer gates de dispositivo/backend/release por separado.
