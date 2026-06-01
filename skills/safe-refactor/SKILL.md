---
name: safe-refactor
description: Refactoriza código existente sin cambiar comportamiento observable. Úsala para mejorar legibilidad, eliminar duplicación o mejorar cohesión sin alterar la API pública. No la uses para agregar funcionalidad nueva (usa generate-feature).
---

# Skill: Refactorización segura

## Entradas esperadas

- Archivo(s) o módulo a refactorizar.
- Objetivo: qué se quiere mejorar (legibilidad, duplicación, cohesión, naming, etc.).

## Proceso

### Paso 1 — Entender el comportamiento actual

1. Lee los archivos a refactorizar completamente.
2. Identifica las pruebas existentes que cubren ese código.
3. **Si no hay pruebas**, propón crearlas primero usando la skill `create-tests`. Espera aprobación.

### Paso 2 — Identificar riesgos (reportar antes de continuar)

- ¿El cambio afecta la API pública (métodos, interfaces, contratos)?
- ¿Toca migraciones, DTOs de API o contratos de integración?
- ¿Hay archivos de infraestructura (Dockerfile, manifiestos) involucrados?
- ¿Puede afectar el rendimiento?

### Paso 3 — Proponer plan y esperar aprobación

- Qué cambios concretos se harán (qué se mueve, renombra, extrae, consolida).
- Qué NO cambiará (comportamiento externo preservado).
- Estrategia de rollback si algo falla.

### Paso 4 — Aplicar cambios mínimos

- El cambio más pequeño posible que logre el objetivo.
- Sin funcionalidad nueva en el mismo paso.
- Mantén el estilo existente del archivo.
- Sin renombrar APIs públicas sin notificar impacto.

### Paso 5 — Verificar

- [ ] `dotnet build` / `ng build` / `npm run build` sin errores.
- [ ] Todos los tests en verde (sin modificar ni deshabilitar pruebas).
- [ ] Comportamiento observable intacto.
- [ ] Sin dependencias nuevas.

### Paso 6 — Actualizar documentación si aplica

Nombres públicos cambiados, estructura de carpetas, instrucciones de uso del módulo.

## Restricciones

- Sin cambio de comportamiento externo sin indicarlo.
- Sin renombrar APIs públicas sin estrategia de compatibilidad.
- Sin modificar migraciones ya aplicadas.
- Sin agregar dependencias externas nuevas.
- Sin funcionalidad nueva.
