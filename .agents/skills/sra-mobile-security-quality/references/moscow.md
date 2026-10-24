# Priorización MoSCoW de hallazgos

MoSCoW ordena el trabajo; no reemplaza severidad, confianza ni estado de
validación. Clasificar cada vulnerabilidad, bug, deuda o riesgo con evidencia del
contexto actual.

## Must

Debe resolverse antes de aceptar, integrar o liberar el alcance evaluado. Usar
cuando exista al menos una condición material como:

- explotación confirmada o exposición probable con impacto crítico/alto;
- bypass de autenticación/autorización, secreto expuesto o pérdida/corrupción de
  datos;
- escritura duplicada o incierta que pueda alterar asistencia sin control;
- regresión confirmada en un flujo crítico, fallo de build/test obligatorio o
  quality gate bloqueante;
- dependencia vulnerable alcanzable sin mitigación razonable y con corrección
  compatible disponible.

Indicar el gate que bloquea y la evidencia necesaria para cerrarlo.

## Should

Debe resolverse en la siguiente iteración razonable. Tiene impacto importante,
pero existe mitigación, exposición limitada o el producto puede operar de forma
controlada. Incluye vulnerabilidades medias alcanzables, errores relevantes en
rutas secundarias, cobertura ausente sobre riesgos importantes y deuda que eleva
claramente la probabilidad de regresión.

Indicar mitigación temporal, responsable sugerido y condición que lo convertiría
en Must.

## Could

Mejora conveniente de bajo impacto o baja probabilidad: code smells menores,
duplicación localizada, pruebas adicionales sobre riesgo bajo, endurecimiento en
profundidad o actualización no urgente. Debe tener beneficio concreto; no crear
tareas de estilo sin efecto verificable.

## Won't this iteration

No se abordará en el alcance o iteración actual. No significa “nunca”. Aplicar a:

- falso positivo o paquete no incluido/alcanzable;
- riesgo aceptado con mitigación y responsable identificados;
- corrección que requiere migración de framework, contrato backend, dispositivo,
  infraestructura o decisión externa fuera del alcance;
- hallazgo duplicado cuya causa raíz ya está priorizada.

Registrar motivo, evidencia, riesgo residual, dependencia externa y condición o
fecha para reconsiderarlo. Un problema Must no puede degradarse a Won't solo por
costo o dificultad.

## Formato obligatorio

```text
ID: SQ-###
Tipo: vulnerabilidad | bug | calidad | dependencia | cobertura
Severidad: Critical | High | Medium | Low | Info
Confianza: alta | media | baja
MoSCoW: Must | Should | Could | Won't this iteration
Estado: PASS | FAIL | BLOCKED | NOT_RUN
Evidencia: archivo:símbolo, herramienta/regla, escenario reproducible
Impacto y exposición: quién o qué resulta afectado y bajo qué condiciones
Justificación MoSCoW: razón contextual de la prioridad
Acción mínima: corrección o mitigación compatible
Validación de cierre: prueba, análisis o gate que debe pasar
```

Al resumir, ordenar primero Must, luego Should, Could y Won't. Dentro de cada
grupo ordenar por severidad, confianza y alcance. Reportar también conteos por
categoría y cualquier Must bloqueado.
