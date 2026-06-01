---
name: security-review
description: Ejecuta una revisión de seguridad OWASP Top 10 sobre el código indicado. Úsala antes de merges a main en código con autenticación, autorización, entrada de usuario, queries a BD o llamadas HTTP externas. Solo lectura.
---

# Skill: Revisión de seguridad OWASP

## Entradas esperadas

- Archivo(s) o módulo a revisar.
- Contexto: qué hace el código (autenticación, query a BD, integración HTTP, formulario de usuario, etc.).

## Proceso

### Paso 1 — Leer reglas de seguridad

Lee `security.md` antes de comenzar la revisión.

### Paso 2 — Revisar por categoría OWASP

**A01:** ¿El usuario tiene permiso sobre el recurso específico? ¿Sin IDs secuenciales en URLs sensibles?

**A02:** ¿Contraseñas con BCrypt/Argon2/PBKDF2? ¿HTTPS? ¿Sin tokens en `localStorage`?

**A03:** ¿Todas las queries con parámetros? ¿Sin concatenación de strings? ¿Salidas HTML sanitizadas?

**A04:** ¿Rate limiting en endpoints sensibles? ¿Sin detalles internos en errores?

**A05:** ¿CORS explícito? ¿Swagger deshabilitado en producción?

**A07:** ¿JWT valida firma, `exp`, `iss` y `aud`? ¿Sin tokens en `localStorage`?

**A09:** ¿Sin datos sensibles en logs? ¿Eventos de autenticación fallida registrados?

**A10:** ¿Sin requests HTTP a URLs construidas con input del usuario sin validación?

### Paso 3 — Reportar hallazgos

| Campo | Descripción |
|---|---|
| Severidad | Crítica / Alta / Media / Baja |
| OWASP | A01–A10 |
| Archivo y línea | Ruta exacta y línea |
| Descripción | Qué vulnerabilidad y por qué es un riesgo |
| Corrección | Código o configuración concretos |

### Paso 4 — Resumen ejecutivo

- Total de hallazgos por severidad.
- Veredicto: ¿puede mergear con correcciones Críticas y Altas pendientes?
- Próximos pasos.

## Restricciones

- Sin modificar archivos.
- Sin reportar estilo como seguridad.
- Sin falsos positivos sin evidencia concreta.
