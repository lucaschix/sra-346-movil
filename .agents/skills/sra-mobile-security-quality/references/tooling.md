# Herramientas y evidencia

## SonarQube

Usar la skill mínima que responda la pregunta:

- `sonarqube:sonar-quality-gate`: estado global y condiciones fallidas.
- `sonarqube:sonar-list-issues`: bugs, vulnerabilidades, hotspots y code smells.
- `sonarqube:sonar-analyze`: análisis de un archivo solicitado.
- `sonarqube:sonar-coverage`: líneas sin cobertura y archivos prioritarios.
- `sonarqube:sonar-duplication`: bloques duplicados.
- `sonarqube:sonar-dependency-risks`: SCA y riesgos de dependencias.
- `sonarqube:sonar-fix-issue`: solo cuando se autorice corregir un issue concreto.

Resolver el project key desde `sonar-project.properties` o la integración. Si no
existe análisis reciente, reportar la fecha/branch disponible o BLOCKED; no
presentar resultados históricos como estado actual.

## Graphify

Aplicar la skill `graphify`. Si existe `graphify-out/graph.json`, comenzar con
`graphify query`, `path`, `affected` o `explain`. Para código nuevo sin grafo,
preferir extracción estructural y excluir secretos, caches, artefactos y
directorios generados. Etiquetar relaciones inferidas como tales; confirmar en
fuente antes de emitir un hallazgo.

## Grype

`grype` analiza paquetes presentes en filesystem, imagen o SBOM. Elegir la fuente
de forma explícita, por ejemplo `grype dir:.`, y generar JSON o SARIF cuando el
reporte vaya a revisarse automáticamente. Registrar versión de Grype y fecha o
estado de su base de vulnerabilidades. Un match requiere validar:

1. que el paquete y versión estén realmente incluidos en el artefacto;
2. que la ruta sea de runtime, build/test o un falso positivo generado;
3. que el CVE afecte la configuración y plataforma usadas;
4. que exista una versión compatible corregida.

No actualizar dependencias legacy automáticamente. Proponer migración separada
cuando la corrección rompa Flutter/Dart/Gradle fijados. No usar `--fail-on` como
único criterio de aceptación sin política de severidad acordada.

## Swift e iOS

Revisar `.swift`, `Info.plist`, entitlements, Podfile y configuración Xcode para
permisos, transporte, almacenamiento y exposición de datos. `swift --version`,
`xcodebuild` y simulador/dispositivo deben ejecutarse en macOS compatible para
acreditar compilación o comportamiento. En Linux, marcar esas validaciones como
NOT_RUN/BLOCKED aunque el análisis textual pase.

## Herramientas adicionales

Usar Semgrep, Trivy, linters o scanners de secretos solo si están instalados y
aportan una señal distinta. Guardar comandos, versión, reglas/perfil, exit code y
salida redactada. No instalar herramientas ni subir código a un servicio externo
por defecto. Correlacionar resultados entre herramientas y consolidar duplicados
por causa raíz.
