# Equipo de reparación SRA móvil
Paquete de configuración para el repositorio Flutter entregado. Incluye orquestador, principal técnico, tres especialistas, cinco skills, contexto real, contratos por confirmar, backlog, matriz de regresión y plantillas. No contiene correcciones de la aplicación ni un SDK Flutter.

## Instalación en tu repositorio
1. Extraer esta carpeta fuera del proyecto y revisar su contenido.
2. Copiar **el contenido** de `sra-mobile-agents` a la raíz donde está `pubspec.yaml`, incluyendo `.codex` y `.agents`. No dejarlo dentro de una subcarpeta, porque AGENTS.md debe aplicar al código de la app.
3. Si ya existen AGENTS.md o .codex/config.toml, fusionar las instrucciones y la tabla [agents]; no sobrescribir configuración personal/equipo. Para una copia protegida de archivos nuevos en Linux: `cp -an /ruta/sra-mobile-agents/. /ruta/sra_346_movil/` y después revisar manualmente los archivos que ya existían.
4. Versionar estos archivos con el repositorio y abrir una sesión nueva de Codex desde su raíz. No instala skills globales en ChatGPT ni cambia configuración de usuario.
5. Pedir a Codex que compruebe descubrimiento de los cinco perfiles TOML y cinco skills. Si la versión/cliente no los descubre, usar los archivos como instrucciones explícitas y ejecutar roles secuencialmente. No cambiar permisos para forzar activación.

## Comenzar
Pegar en Codex, abierto en el repositorio:
```text
Usa $sra-mobile-orchestrate y actúa como sra-mobile-orchestrator.
Lee AGENTS.md, docs/agents/PROJECT_CONTEXT.md y docs/agents/BACKLOG.md.
Inicia la reparación de SRA móvil por SRA-00 y SRA-01, y continúa con
las correcciones independientes que tengan evidencia suficiente.
Coordina al maintainer, mobile-api-auth, mobile-ui-qr y mobile-verifier
según necesidad. Un editor por archivo. Conserva Flutter 1.12.13+hotfix.9
y Dart 2.7.2. No inventes contratos del backend. Registra el trabajo en
docs/agents/runs/ y entrega cambios verificables con resultados reales.
No hagas merge ni publiques un APK.
```
Para comenzar solo con diagnóstico, cambiar "Inicia la reparación" por "Realiza únicamente el diagnóstico, sin editar código de aplicación".

## Qué contiene
| Ubicación | Función |
|---|---|
| AGENTS.md | Reglas compartidas y entrada del flujo |
| .codex/agents/*.toml | Perfiles de los cinco roles |
| .codex/config.toml | Habilitación y hasta cuatro agentes hijos |
| .agents/skills/*/SKILL.md | Procedimientos de orquestación, build, API/auth, QR y verificación |
| docs/agents/WORKFLOW.md | Estados, responsabilidades y condiciones de avance |
| docs/agents/BACKLOG.md | Orden de reparación y criterios por tarea |
| docs/agents/API_CONTRACTS.md y QR_CONTRACT.md | Contratos observados, semántica y dudas de backend |
| docs/agents/REGRESSION.md y BUILD.md | Validación y reproducción |
| docs/agents/templates/ | Plantillas para delegar y registrar ejecución |

Los perfiles usan nombre, descripción e instrucciones TOML y heredan modelo/permisos de la sesión. Las instrucciones de "solo lectura" de un rol son una política de trabajo, no una sandbox distinta. El orquestador es un rol ejecutado por Codex, no un servicio autónomo ni un scheduler. No inicia trabajo por copiar archivos.

## Fuentes de configuración
Consultadas el 20-10-2026:
- https://learn.chatgpt.com/docs/agent-configuration/subagents
- https://learn.chatgpt.com/docs/agent-configuration/agents-md
- https://learn.chatgpt.com/docs/build-skills

## Validación del paquete
Ver `docs/agents/PACKAGE_VALIDATION.md` para controles realmente realizados y limitaciones. El código Flutter original permanece intacto. El backend no se incluyó; la rotación del token y la clasificación de asistencia provienen del análisis aportado y requieren contraste antes de cambiar el protocolo.
