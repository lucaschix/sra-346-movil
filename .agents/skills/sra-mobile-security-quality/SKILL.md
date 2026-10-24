---
name: sra-mobile-security-quality
description: Auditar seguridad, diseñar pruebas unitarias y evaluar calidad, cobertura y dependencias de SRA móvil con SonarQube, Graphify, Grype y herramientas compatibles; usar para revisiones de riesgo, quality gates o ampliación de tests.
---

# Seguridad, pruebas y calidad de SRA móvil

## Preparación

1. Leer `AGENTS.md`, `RUNTIMES.md`, `docs/agents/PROJECT_CONTEXT.md`, el diff y los contratos afectados. Confirmar si la asignación es auditoría independiente o autoría de tests/correcciones; no mezclar ambos roles en la misma revisión.
2. Registrar baseline, archivos reservados, herramientas disponibles y criterios. Conservar Flutter 1.12.13+hotfix.9, Dart 2.7.2, JDK 8, lock y workaround de `barcode_scan`.
3. Leer [references/tooling.md](references/tooling.md) solo para las familias de herramientas necesarias.
4. Para priorizar hallazgos, leer [references/moscow.md](references/moscow.md).

## Selección del análisis

- Para arquitectura, flujo de datos, superficies de ataque o impacto, usar Graphify. Consultar primero `graphify-out/graph.json` si existe; reconstruir o actualizar solo cuando el grafo falte o esté desactualizado.
- Para quality gate, bugs, vulnerabilidades, hotspots, cobertura o duplicación, usar la skill SonarQube específica. No convertir ausencia de proyecto, análisis o credenciales en PASS.
- Para paquetes vulnerables, usar primero el resultado de dependencias de SonarQube si existe y Grype sobre un filesystem, imagen o SBOM adecuado. Validar paquete, versión, alcance y corrección disponible antes de recomendar cambios.
- Para Dart/Flutter, ejecutar los controles definidos por `sra-mobile-build` y `sra-mobile-verify`. Para Swift/iOS, separar revisión estática de compilación con Xcode; Linux sin `swift`/`xcodebuild` es NOT_RUN para build.
- Detectar Semgrep, Trivy u otras herramientas antes de usarlas. No instalarlas, cambiar reglas remotas ni descargar bases de datos grandes sin que el alcance lo justifique.

## Pruebas unitarias y de comportamiento

Diseñar una matriz desde riesgos y contratos: camino válido, valores límite,
campos ausentes o de tipo erróneo, permisos/autorización, fallos de transporte,
persistencia parcial, concurrencia, doble pulsación, cancelación y resultado
incierto. Usar fixtures sintéticos y dobles mínimos. En Flutter legado, evitar
APIs modernas y comprobar cantidad de llamadas, estado visible y efectos
persistentes. Una métrica de cobertura orienta la búsqueda; no sustituye una
aserción significativa.

Cuando se autorice implementar, editar solo tests y paths expresamente
asignados. Ejecutar primero la prueba dirigida y luego la regresión aplicable.
No cambiar producción solo para facilitar un mock ni debilitar una aserción para
obtener verde.

## Triage y cierre

Para cada hallazgo registrar:

- severidad y confianza;
- prioridad MoSCoW y justificación;
- herramienta/regla y CWE/CVE cuando corresponda;
- archivo, símbolo y evidencia reproducible;
- entrada o flujo afectado, impacto y alcance real;
- corrección mínima compatible y prueba que demostraría el cierre;
- estado `PASS`, `FAIL`, `BLOCKED` o `NOT_RUN`.

Revisar falsos positivos contra el código y contrato. No afirmar explotación por
una coincidencia de patrón ni seguridad por ausencia de hallazgos automáticos.
Mantener severidad y prioridad como campos distintos: la severidad describe el
daño técnico; MoSCoW decide cuándo debe atenderse dentro del alcance evaluado.
Comparar con el baseline, comprobar lock/configuración y redactar cualquier dato
sensible. Si se modificó código o tests, pedir revisión independiente después de
liberar los archivos.
