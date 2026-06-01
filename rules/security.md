# Reglas de seguridad — OWASP Top 10

> Aplica siempre a todo el proyecto, backend y frontend.
> Referencia: OWASP Top 10 vigente y OWASP ASVS 4.0.

## Obligatorio en todo código nuevo

- Valida entradas externas en el borde del sistema. No confíes en datos del cliente.
- Usa parámetros en queries. Nunca concatenes strings para construir SQL o NoSQL.
- No incluyas secretos, tokens ni credenciales en archivos versionables.
- No registres: passwords, tokens, documentos de identidad, tarjetas, datos de salud, PII.
- No expongas stack traces en respuestas de error de producción. Usa `ProblemDetails`.
- Aplica autorización en todos los endpoints que lo requieran.

---

## A01 — Control de acceso

- No implementes lógica de autorización solo en el cliente. El servidor siempre valida.
- Verifica que el usuario tiene permiso sobre el **recurso específico**, no solo que está autenticado.
- Políticas de autorización: `[Authorize(Policy = "NombrePolicy")]`. Sin roles hardcodeados dispersos.
- Sin IDs secuenciales en URLs para recursos sensibles. Usa UUIDs.

## A02 — Fallos criptográficos

- Contraseñas con BCrypt, Argon2 o PBKDF2. Sin MD5, SHA1 ni SHA256 sin salt.
- HTTPS en todos los ambientes. HSTS en producción.
- Sin tokens de sesión en `localStorage`. Usa cookies `HttpOnly + Secure`.
- Cifra datos sensibles en reposo cuando el nivel de sensibilidad lo justifique.

## A03 — Inyección

- Parámetros en todas las queries (EF Core, Dapper, MongoDB Driver). Cero concatenación.
- Angular: no uses `[innerHTML]` con contenido externo. React: no uses `dangerouslySetInnerHTML` con contenido externo.
- Valida y sanitiza entradas en el borde del sistema (filtros, validators de ASP.NET Core).

## A04 — Diseño inseguro

- Rate limiting en endpoints de autenticación y endpoints públicos críticos.
- `ProblemDetails` (RFC 7807) para errores HTTP.
- Sin información interna en errores: nombres de servidor, versiones, rutas internas.

## A05 — Configuración incorrecta

- CORS explícito. Sin `AllowAnyOrigin + AllowCredentials` en producción.
- CSP configurado en el frontend.
- Swagger y endpoints de diagnóstico deshabilitados en producción.
- Timeouts en conexiones de BD y llamadas HTTP externas.
- Headers mínimos: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`.

## A06 — Componentes vulnerables

- `dotnet list package --vulnerable` antes de cada merge a main.
- `npm audit` antes de cada merge a main.
- No ignores vulnerabilidades críticas o altas sin documentar justificación y plan.
- Lockfiles (`package-lock.json`, `packages.lock.json`) commiteados al repositorio.

## A07 — Autenticación

- JWT: valida firma, `exp`, `iss`, `aud`. Sin excepción.
- Rotación de refresh tokens.
- Invalida sesiones activas al cambiar contraseña.
- Límite de intentos de login con bloqueo temporal.
- Sin tokens en `localStorage`. Cookies `HttpOnly + Secure`.

## A09 — Logging y monitoreo

- Registra: intentos de autenticación fallidos, cambios de permisos, errores de autorización.
- No registres: passwords, tokens, documentos, tarjetas, datos de salud.
- Correlaciona logs con `X-Correlation-ID` o `TraceId`.

## A10 — SSRF

- Sin requests HTTP a URLs construidas desde input del usuario sin validación estricta.
- Allowlist para dominios externos cuando las URLs son configurables.

---

## Placeholders para secretos (nunca valores reales)

```
${DATABASE_URL}
${JWT_SECRET}
${API_KEY}
${AZURE_CLIENT_SECRET}
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
```

Usa variables de entorno, Azure Key Vault, AWS Secrets Manager o HashiCorp Vault.

---

## Verificación antes de entregar

- [ ] Inputs validados en el borde del sistema
- [ ] Sin concatenación de strings en queries
- [ ] Sin secretos en código o configuración versionada
- [ ] Sin datos sensibles en logs
- [ ] `dotnet list package --vulnerable` sin críticos o altos
- [ ] `npm audit` sin críticos o altos
- [ ] Sin stack traces en respuestas de error
- [ ] Autorización aplicada en endpoints nuevos
- [ ] Sin `[innerHTML]` / `dangerouslySetInnerHTML` con contenido externo
