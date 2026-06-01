# Reglas de backend — .NET 9+

> Backend en `backend/`. Pruebas en `tests/`.
> La estructura interna de proyectos depende de la arquitectura elegida al inicio.

## Configuración obligatoria en proyectos nuevos

### Directory.Build.props (raíz del repositorio)

Crea este archivo en la raíz para aplicar configuración global a todos los proyectos:

```xml
<Project>
  <PropertyGroup>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <LangVersion>latest</LangVersion>
    <AnalysisMode>Recommended</AnalysisMode>
  </PropertyGroup>

  <!-- SonarAnalyzer en todos los proyectos excepto tests -->
  <ItemGroup Condition="!$(MSBuildProjectName.EndsWith('.Tests'))">
    <PackageReference Include="SonarAnalyzer.CSharp">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
    </PackageReference>
  </ItemGroup>
</Project>
```

**Reglas sobre esta configuración:**
- `TreatWarningsAsErrors=true` es obligatorio en proyectos nuevos. No se puede deshabilitar por proyecto sin aprobación explícita del equipo.
- `SonarAnalyzer.CSharp` se instala en todos los proyectos de producción. **Nunca** en proyectos `*.Tests`.
- No suprimas issues de SonarAnalyzer con `#pragma warning disable` sin documentar la justificación en el mismo código.
- Cuando SonarAnalyzer reporte una issue en código nuevo, corrígela antes de continuar. La supresión es el último recurso.

## Documentación oficial de .NET — Servidor MCP

Usa el servidor MCP `microsoft-docs` para consultar documentación oficial de .NET, ASP.NET Core, EF Core y otras APIs de Microsoft. Está configurado en todos los agentes de este template.

Consulta `microsoft-docs` cuando necesites:
- Firma exacta de métodos o comportamiento de APIs del framework.
- Parámetros de configuración de ASP.NET Core (middleware, DI, autenticación).
- Opciones de EF Core, Dapper, configuración de `IHttpClientFactory`.
- Verificar comportamiento de extensiones, atributos o tipos del ecosistema Microsoft.

## C# — Tipos y nulabilidad

- Nullable reference types habilitado globalmente por `Directory.Build.props`. No lo deshabilites en proyectos individuales.
- No suprimas advertencias de nulabilidad con `!` (null-forgiving) sin justificación documentada.
- Usa `record` para DTOs inmutables, commands, queries y responses.
- Usa `readonly struct` para value objects pequeños y de alta frecuencia.
- Tipos de retorno explícitos. Evita `dynamic` u `object` salvo casos justificados.

## Async y CancellationToken

- Todos los métodos de I/O son `async Task<T>` o `async ValueTask<T>`.
- Pasa `CancellationToken` a todos los métodos async que lo soporten.
- No uses `.Result`, `.Wait()` ni `.GetAwaiter().GetResult()` fuera de contextos de startup.
- No uses `Task.Run` para hacer código síncrono async dentro de un request HTTP.
- Usa `IAsyncEnumerable<T>` para streams procesables elemento a elemento.

## IHttpClientFactory — Obligatorio para HTTP externo

**Nunca instancies `HttpClient` directamente con `new HttpClient()`.**
Motivo: gestión correcta de sockets, DNS refresh y lifetimes de conexión.

### Cliente tipado (recomendado para APIs específicas)

```csharp
// Registro en DI
builder.Services.AddHttpClient<IProductApiClient, ProductApiClient>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["ProductApi:BaseUrl"]!);
    client.Timeout = TimeSpan.FromSeconds(30);
});

// Implementación
public sealed class ProductApiClient(HttpClient httpClient) : IProductApiClient
{
    public async Task<ProductDto?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        var response = await httpClient.GetAsync($"products/{id}", ct);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<ProductDto>(ct);
    }
}
```

### Cliente nombrado (múltiples endpoints del mismo servicio)

```csharp
builder.Services.AddHttpClient("PaymentGateway", client =>
{
    client.BaseAddress = new Uri(builder.Configuration["PaymentGateway:BaseUrl"]!);
});

// Uso en servicio
public sealed class PaymentService(IHttpClientFactory factory)
{
    public async Task<bool> ProcessAsync(PaymentRequest request, CancellationToken ct)
    {
        var client = factory.CreateClient("PaymentGateway");
        // ...
    }
}
```

### Resiliencia recomendada

```csharp
builder.Services.AddHttpClient<IExternalService, ExternalService>()
    .AddStandardResilienceHandler(); // Polly: retries, circuit breaker, timeout
```

## Controllers (cuando se elige estilo MVC)

- Deriva de `ControllerBase`. Sin `Controller` salvo que uses Views.
- Cada action method máximo 10 líneas. Solo coordina: deserializa → invoca → serializa.
- Devuelve `ActionResult<T>` con tipos explícitos. Documenta con `[ProducesResponseType]`.
- No inyectes repositorios directamente. Usa `ISender`.

## Minimal API — Patrón REPR (cuando se elige ese estilo)

- Cada endpoint implementa `IEndpoint` con método estático `MapEndpoint`.
- `Request` y `Response` son `record` anidados en la clase del endpoint.
- Registra con `app.MapEndpoints(Assembly.GetExecutingAssembly())` en `Program.cs`.
- No pongas lógica de negocio en el handler. Invoca el `ISender`.

## Patrón Mediator propio (sin MediatR)

```csharp
// En backend/NombreProyecto.Application/Abstractions/Mediator/
public interface ICommand { }
public interface ICommand<TResult> { }
public interface IQuery<TResult> { }

public interface ICommandHandler<TCommand> where TCommand : ICommand
{
    Task HandleAsync(TCommand command, CancellationToken ct = default);
}
public interface ICommandHandler<TCommand, TResult> where TCommand : ICommand<TResult>
{
    Task<TResult> HandleAsync(TCommand command, CancellationToken ct = default);
}
public interface IQueryHandler<TQuery, TResult> where TQuery : IQuery<TResult>
{
    Task<TResult> HandleAsync(TQuery query, CancellationToken ct = default);
}
public interface ISender
{
    Task SendAsync<TCommand>(TCommand command, CancellationToken ct = default)
        where TCommand : ICommand;
    Task<TResult> SendAsync<TResult>(ICommand<TResult> command, CancellationToken ct = default);
    Task<TResult> QueryAsync<TResult>(IQuery<TResult> query, CancellationToken ct = default);
}
```

## Mapster (sin AutoMapper)

```csharp
TypeAdapterConfig<Entidad, EntidadDto>.NewConfig()
    .Map(dest => dest.NombreCompleto, src => $"{src.Nombre} {src.Apellido}");

var dto   = entidad.Adapt<EntidadDto>();
var lista = entidades.Adapt<List<EntidadDto>>();
```

## Inyección de dependencias

- Métodos de extensión por capa: `AddDomainServices()`, `AddApplicationServices()`, `AddInfrastructureServices()`.
- Sin Service Locator en lógica de negocio.
- Valida configuración crítica con `ValidateOnStart()`.

## Manejo de errores

- Middleware global que devuelva `ProblemDetails` (RFC 7807).
- Sin stack traces en producción.
- Diferencia errores de negocio (4xx) de errores de infraestructura (5xx).
- Maneja `OperationCanceledException` explícitamente.

## Logging

- `ILogger<T>` inyectado. Logging estructurado con Serilog.
- Sin passwords, tokens, PII, datos financieros en logs.

## Seguridad

- Valida inputs en el borde del sistema (filters, validators de ASP.NET Core).
- CORS explícito. Sin `AllowAnyOrigin + AllowCredentials` en producción.
- Rate limiting en endpoints de autenticación y públicos críticos.
- JWT: valida firma, `exp`, `iss`, `aud`.

## Verificación antes de entregar

- [ ] `dotnet build` sin errores — **con `TreatWarningsAsErrors=true` activo**
- [ ] `dotnet test` todos en verde
- [ ] Sin issues de SonarAnalyzer suprimidas sin justificación
- [ ] `dotnet list package --vulnerable` sin críticos o altos
- [ ] Sin `new HttpClient()` directo
- [ ] Sin `.Result` / `.Wait()` fuera de startup
- [ ] Sin secretos en código o configuración versionada
- [ ] Prueba escrita antes de la implementación (TDD)
