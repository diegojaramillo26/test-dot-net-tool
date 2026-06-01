---
name: generate-feature
description: Genera una feature fullstack completa siguiendo TDD. Aplica la arquitectura activa del proyecto. Escribe pruebas primero, luego la implementación. Úsala para crear un nuevo endpoint de API, una nueva pantalla frontend o una feature completa. No la uses para modificar features existentes (usa safe-refactor).
---

# Skill: Generar feature completa (TDD)

## Entradas esperadas

- Nombre de la feature (ej: `CreateOrder`, `UserProfile`, `ProductSearch`).
- Descripción funcional: qué debe hacer, qué reglas de negocio aplican.
- Alcance: backend, frontend, o fullstack.

## Proceso

### Paso 1 — Confirmar configuración del proyecto

Confirma:
- Arquitectura backend activa.
- Estilo de API: Minimal API (REPR) o Controllers.
- Framework frontend: Angular o React.
- Motor de base de datos.

Si no está claro, pregunta antes de continuar.

### Paso 2 — Planificar (propón y espera aprobación)

Lista todos los archivos a crear con rutas exactas. Ejemplo (Clean Architecture + REPR):

```
Backend:
  tests/NombreProyecto.Application.Tests/Features/Orders/CreateOrderHandlerTests.cs
  tests/NombreProyecto.Infrastructure.Tests/Repositories/OrderRepositoryTests.cs
  tests/NombreProyecto.API.Tests/Endpoints/CreateOrderEndpointTests.cs
  backend/NombreProyecto.Domain/Entities/Order.cs
  backend/NombreProyecto.Domain/Exceptions/InsufficientStockException.cs
  backend/NombreProyecto.Application/Features/Orders/CreateOrder/CreateOrderCommand.cs
  backend/NombreProyecto.Application/Features/Orders/CreateOrder/CreateOrderHandler.cs
  backend/NombreProyecto.Application/Features/Orders/CreateOrder/CreateOrderResponse.cs
  backend/NombreProyecto.Infrastructure/Repositories/OrderRepository.cs
  backend/NombreProyecto.API/Endpoints/Orders/CreateOrderEndpoint.cs

Frontend Angular:
  frontend/src/app/features/orders/pages/create-order.page.spec.ts
  frontend/src/app/features/orders/services/order.service.spec.ts
  frontend/src/app/features/orders/pages/create-order.page.ts
  frontend/src/app/features/orders/services/order.service.ts
  frontend/src/app/features/orders/models/order.model.ts
```

Espera aprobación antes de generar código.

### Paso 3 — Implementar en orden TDD (RED → GREEN → REFACTOR)

1. Prueba del handler / caso de uso → implementación del handler.
2. Prueba de la entidad de dominio → implementación de la entidad.
3. Prueba del repositorio (Testcontainers) → implementación del repositorio.
4. Prueba del endpoint o controller → implementación del endpoint.
5. Prueba del componente/servicio frontend → implementación frontend.
6. Refactor general si hay duplicación o mejoras evidentes.

### Paso 4 — Verificar antes de entregar

- [ ] `dotnet build` y `dotnet test` en verde.
- [ ] `ng build` / `npm run build` y tests frontend en verde.
- [ ] Sin lógica de negocio en controladores, endpoints ni componentes.
- [ ] Sin `new HttpClient()` directo. Usa `IHttpClientFactory`.
- [ ] Sin FluentAssertions, MediatR ni AutoMapper.
- [ ] Sin secretos en código.
- [ ] Cada prueba cubre happy path + al menos un error esperado.
- [ ] Documentación actualizada si cambió la API pública.

## Restricciones

- No generes código de producción sin prueba previa.
- No saltes el paso de planificación.
- No mezcles código de arquitecturas distintas.
- No generes archivos sin ruta exacta bajo `backend/`, `frontend/` o `tests/`.
