# Reglas de arquitectura backend

> Estructura del proyecto: `backend/` para .NET, `frontend/` para Angular/React, `tests/` para pruebas.
> Aplica SOLO las reglas de la arquitectura confirmada al inicio del proyecto.

---

## Aislamiento por proyecto — Obligatorio

**Cada capa debe vivir en su propio proyecto `.csproj` independiente.** No como carpeta dentro de otro proyecto.

**Motivo:** el límite de ensamblado hace que las dependencias entre capas sean verificables en tiempo de compilación. .NET prohíbe referencias circulares entre proyectos, eliminando una clase entera de violaciones arquitectónicas que las carpetas no pueden prevenir.

**Excepción estricta — Vertical Slice Architecture:** siempre un único proyecto `.csproj`, organizado por feature (slice vertical). No se divide en capas ni se extrae infraestructura compartida a proyecto aparte. El aislamiento en VSA es por feature, no por capa — esa es su premisa fundamental.

---

## Dependencias entre proyectos permitidas

### Clean Architecture
```
Domain        → (ninguna)
Application   → Domain
Infrastructure → Application, Domain
API           → Application       ← NUNCA → Infrastructure directamente
```

### Vertical Slice Architecture
```
Infrastructure compartida → (sin dependencias de features)
Feature Handler            → Infrastructure compartida
Feature Endpoint/Controller → Feature Handler (vía ISender)
Un handler NO importa tipos de otro handler de feature diferente
```

### Hexagonal Architecture
```
Core/Domain      → (ninguna)
Core/Application → Core/Domain
Adapters/Driving → Core/Application   ← NO a Adapters/Driven
Adapters/Driven  → Core/Application, Core/Domain
```

### N-Capas
```
DataAccess   → Common
Business     → DataAccess, Common
Presentation → Business, Common   ← NUNCA → DataAccess directamente
```

---

## [Clean Architecture] — Estructura de carpetas

> Cada `NombreProyecto.*` es un proyecto `.csproj` independiente (no una carpeta dentro de otro proyecto).

```
backend/
  NombreProyecto.Domain/            ← .csproj propio
    Entities/
    ValueObjects/
    Interfaces/          ← Interfaces de repositorio
    Exceptions/
    Events/
  NombreProyecto.Application/       ← .csproj propio
    Abstractions/
      Mediator/          ← ICommand, IQuery, ISender (patrón propio)
      Repositories/
      Services/
    Features/
      Products/
        CreateProduct/
          CreateProductCommand.cs
          CreateProductHandler.cs
          CreateProductResponse.cs
    Common/
      Mapping/           ← Configuraciones de Mapster
  NombreProyecto.Infrastructure/    ← .csproj propio
    Repositories/
    Persistence/
      DbContext/
      Configurations/    ← IEntityTypeConfiguration<T>
      Migrations/
    ExternalServices/
    Mediator/            ← Implementación del Sender
  NombreProyecto.API/               ← .csproj propio
    Endpoints/           ← Si usa Minimal API REPR
      Products/
        CreateProductEndpoint.cs
    Controllers/         ← Si usa Controllers
    Middlewares/
    Extensions/
    Program.cs           ← Solo bootstrap
tests/
  NombreProyecto.Domain.Tests/
  NombreProyecto.Application.Tests/
  NombreProyecto.Infrastructure.Tests/
  NombreProyecto.API.Tests/
```

---

## [Vertical Slice Architecture] — Estructura de carpetas

> **Excepción de aislamiento:** VSA usa un único proyecto `.csproj`. El aislamiento es por feature (slice vertical), no por capa horizontal. `Infrastructure/` es una carpeta interna, no un proyecto separado.

```
backend/
  NombreProyecto.API/               ← único .csproj (proyecto completo)
    Features/
      Products/
        CreateProduct/
          CreateProductCommand.cs
          CreateProductHandler.cs
          CreateProductValidator.cs
          CreateProductResponse.cs
          CreateProductEndpoint.cs    ← REPR o action de controller
        GetProductById/
          ...
      Orders/
        ...
    Infrastructure/                  ← carpeta interna, NO proyecto separado
      Database/
      ExternalServices/
    Program.cs
tests/
  NombreProyecto.API.Tests/
    Features/
      Products/
        CreateProductHandlerTests.cs
```

---

## [Hexagonal Architecture] — Estructura de carpetas

> Cada `NombreProyecto.*` es un proyecto `.csproj` independiente (no una carpeta dentro de otro proyecto).

```
backend/
  NombreProyecto.Core/              ← .csproj propio
    Domain/
    Application/
      Ports/
        Input/           ← Interfaces que el mundo invoca
        Output/          ← Interfaces que la app necesita del exterior
      UseCases/
  NombreProyecto.Adapters/          ← .csproj propio (o dividido en Driving/Driven)
    Driving/
      API/               ← REST, gRPC
    Driven/
      Database/
      ExternalServices/
tests/
  NombreProyecto.Core.Tests/
  NombreProyecto.Adapters.Tests/
```

---

## [N-Capas] — Estructura de carpetas

> Cada `NombreProyecto.*` es un proyecto `.csproj` independiente (no una carpeta dentro de otro proyecto).

```
backend/
  NombreProyecto.Presentation/      ← .csproj propio
  NombreProyecto.Business/          ← .csproj propio
  NombreProyecto.DataAccess/        ← .csproj propio
  NombreProyecto.Common/            ← .csproj propio
tests/
  NombreProyecto.Business.Tests/
  NombreProyecto.DataAccess.Tests/
  NombreProyecto.Presentation.Tests/
```

---

## Minimal API — Patrón REPR (si se elige ese estilo)

```csharp
// Interfaz base
public interface IEndpoint
{
    static abstract void MapEndpoint(IEndpointRouteBuilder app);
}

// Extensión de registro — el único código en Program.cs
public static class EndpointExtensions
{
    public static IEndpointRouteBuilder MapEndpoints(
        this IEndpointRouteBuilder app, Assembly assembly)
    {
        var types = assembly.GetTypes()
            .Where(t => t.IsAssignableTo(typeof(IEndpoint))
                     && t is { IsAbstract: false, IsInterface: false });
        foreach (var type in types)
            type.GetMethod(nameof(IEndpoint.MapEndpoint))!.Invoke(null, [app]);
        return app;
    }
}

// Ejemplo de endpoint REPR
public sealed class CreateProductEndpoint : IEndpoint
{
    public record Request(string Name, decimal Price, int Stock);
    public record Response(Guid Id, string Name);

    public static void MapEndpoint(IEndpointRouteBuilder app) =>
        app.MapPost("/api/products", HandleAsync)
           .WithName("CreateProduct")
           .WithTags("Products")
           .Produces<Response>(StatusCodes.Status201Created)
           .ProducesValidationProblem();

    private static async Task<IResult> HandleAsync(
        Request request, ISender sender, CancellationToken ct)
    {
        var result = await sender.SendAsync(
            new CreateProductCommand(request.Name, request.Price, request.Stock), ct);
        return Results.Created($"/api/products/{result.Id}", new Response(result.Id, result.Name));
    }
}
```

En `Program.cs` solo:
```csharp
app.MapEndpoints(Assembly.GetExecutingAssembly());
```

---

## Señales de violación arquitectónica (reportar siempre)

- Entidad de dominio con `[Column]`, `[Table]`, `[ForeignKey]` o atributos de EF/ORM.
- Caso de uso / handler que instancia `DbContext` directamente.
- Controlador o endpoint que inyecta un repositorio sin pasar por `ISender`.
- `using` de `Infrastructure` desde `Application` o `Domain`.
- Handler de una feature importando tipos de otro handler de feature diferente.
- Presentación (N-Capas) llamando a DataAccess directamente.
- Adaptador Driving invocando directamente a adaptador Driven (Hexagonal).
- **Dos o más capas distintas compiladas en el mismo `.csproj`** en Clean/Hexagonal/N-Capas (p. ej. Domain + Application en un único proyecto). ← No aplica a VSA.
- **Capa implementada como carpeta dentro de otro proyecto** en lugar de proyecto `.csproj` propio (p. ej. `NombreProyecto.API/Domain/` en vez de `NombreProyecto.Domain.csproj`). ← No aplica a VSA.
