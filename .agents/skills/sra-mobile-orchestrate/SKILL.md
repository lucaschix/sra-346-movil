---
name: sra-mobile-orchestrate
description: Coordinar reparaciones de SRA móvil con orquestador, maintainer y especialistas; usar para arreglar el proyecto, planificar fases o integrar cambios de API, sesión y QR.
---

# Orquestar la reparación
1. Leer AGENTS.md, `docs/agents/WORKFLOW.md` y `docs/agents/BACKLOG.md`. Confirmar objetivo y checkout; distinguir configuración de agentes, diagnóstico y reparación. No reparar la app si solo se pidió configurar agentes.
2. Crear `docs/agents/runs/<id>.md` desde `docs/agents/templates/RUN.md`; registrar estado inicial, baseline y qué validaciones son posibles.
3. Pedir al maintainer un mapa de dependencias y contratos. Delegar investigaciones independientes a API y UI en modo lectura cuando haga falta. Obtener evidencia antes de ordenar ediciones.
4. Fijar contratos entre capas y criterios; reservar archivos exactos para cada tarea. Usar `docs/agents/templates/DELEGATION.md`. No delegar tareas vagas como "arregla todo".
5. Implementar por fases del backlog con especialistas. Solo paralelizar paths disjuntos y contratos estables. Coordinar cualquier modelo o fixture compartido mediante maintainer.
6. Liberar reservas, integrar, congelar el diff y pedir revisión independiente a mobile-verifier. Devolver FAIL a su autor, volver a verificar únicamente lo afectado y sus dependencias.
7. Ante bloqueo externo, documentar evidencia faltante y continuar lo independiente. No sustituir contrato real por suposición ni ocultar controles no ejecutados.
8. Cerrar con resultados por criterio y diff, pruebas y riesgos. Entregar propuesta de MR/PR y próximos pasos; no publicar ni hacer merge automáticamente.

La sesión principal puede desempeñar este rol; no hace falta crear un orquestador hijo y luego otro árbol. Los especialistas no crean subagentes. Si el entorno no descubre los TOML, cargar su `developer_instructions` como guía del rol genérico disponible, indicando el modo degradado.
