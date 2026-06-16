# AI Dev Agent — Fullstack .NET 10+ / Angular 20+ o React 18+

> Las reglas detalladas viven en `rules/`. Este archivo es el punto de entrada.

---

## Proyecto nuevo — Pregunta primero

Antes de generar cualquier archivo, obtén respuesta a:

1. **Arquitectura backend:** Clean Architecture / Vertical Slice / Hexagonal / N-Capas.
2. **Estilo de API:** Minimal API con patrón REPR, o Controllers (MVC).
3. **Frontend:** Angular 20+, React 18+, o no aplica.
4. **Base de datos:** PostgreSQL, SQL Server, MySQL, SQLite, MongoDB, otro.
5. **ORM / acceso a datos:** EF Core 10+, Dapper, MongoDB Driver.
6. **Cobertura mínima de tests:** (sugerido 80% backend, 75% frontend).

No generes código hasta tener al menos 1, 2 y 3 respondidos.

---

## Proyecto existente — Analiza antes de preguntar

1. Inspecciona estructura, dependencias, configuración, pruebas y convenciones.
2. Infiere todo lo que puedas. No hagas preguntas que el repositorio ya responde.
3. Respeta convenciones detectadas aunque difieran del template.
4. Reporta brevemente lo detectado antes de proponer cambios.

---

## Estructura del proyecto

```
backend/    ← .NET 10+ (proyectos .csproj)
frontend/   ← Angular 20+ o React 18+
tests/      ← Proyectos de prueba .NET
```

---

## TDD — No negociable

```
RED     → Escribe la prueba. Ejecútala. Debe fallar.
GREEN   → Implementa lo mínimo para que pase.
REFACTOR → Mejora sin cambiar comportamiento. Pruebas siguen verdes.
```

No escribas código de producción sin una prueba que lo justifique.
Al corregir un bug: primero la prueba que lo reproduce, luego la corrección.
Nunca deshabilites, comentes ni elimines pruebas para que el build pase.

---

## Stack de referencia rápida

| Dominio | Decisión |
|---|---|
| Testing .NET | xUnit + `Assert.*` nativo. **Sin FluentAssertions.** |
| Mediator | Patrón propio (interfaces propias). **Sin MediatR.** |
| Mapeo | Mapster. **Sin AutoMapper.** |
| HTTP externo | `IHttpClientFactory`. **Sin `new HttpClient()`.** |
| Minimal API | Patrón REPR. Cada endpoint = clase `IEndpoint`. Sin endpoints en `Program.cs`. |
| Documentación de API | OpenAPI nativo (`AddOpenApi`) + Scalar (`MapScalarApiReference`). **Sin Swagger/Swashbuckle.** |
| Análisis estático | SonarAnalyzer.CSharp en todos los proyectos no-test. |
| Documentación .NET | Servidor MCP `microsoft-docs` (`https://learn.microsoft.com/api/mcp`). |

---

## Prohibiciones absolutas

- No código de producción sin prueba previa (TDD).
- No lógica de negocio en controladores, endpoints ni componentes de UI.
- No `new HttpClient()` directamente. Usa `IHttpClientFactory`.
- No concatenación de strings en queries SQL/NoSQL.
- No FluentAssertions, MediatR ni AutoMapper.
- No secretos ni credenciales en archivos versionables.
- No modificar migraciones ya aplicadas.
- No `.Result` ni `.Wait()` en código async.
- No commits sin listar archivos modificados y esperar aprobación.
- No datos sensibles (passwords, tokens, PII) en logs.
- No comandos destructivos sin aprobación explícita.

---

## Comandos de validación

```bash
dotnet build && dotnet test
ng build && ng test --watch=false
npm run build && npm test -- --watchAll=false && npm run lint
```
