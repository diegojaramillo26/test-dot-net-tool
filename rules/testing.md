# Reglas de testing — TDD obligatorio

> Framework .NET: xUnit + `Assert.*` nativo. **Sin FluentAssertions.**
> Estructura: pruebas .NET en `tests/`, pruebas frontend junto al código.

## Ciclo TDD — Para cada unidad de código nuevo

```
1. RED     → Escribe la prueba. Ejecútala. DEBE FALLAR.
2. GREEN   → Implementa lo mínimo para que pase.
3. REFACTOR → Mejora. Las pruebas deben permanecer en verde.
```

- No escribas código de producción sin una prueba en rojo que lo justifique.
- Una prueba en rojo a la vez.
- Al corregir un bug: primero la prueba que lo reproduce (rojo), luego la corrección.
- Nunca deshabilites, comentes ni elimines pruebas para que el build pase.

---

## Backend .NET — xUnit (sin FluentAssertions)

### Nomenclatura
```
MetodoOEscenario_Condicion_ResultadoEsperado
```

### Aserciones nativas de xUnit
```csharp
Assert.Equal(expected, actual);
Assert.NotEqual(unexpected, actual);
Assert.Null(value);
Assert.NotNull(value);
Assert.True(condition);
Assert.False(condition);
Assert.Empty(collection);
Assert.NotEmpty(collection);
Assert.Single(collection);
Assert.Contains(expected, collection);
Assert.Equal(3, collection.Count);
Assert.Contains("substring", actual);
Assert.StartsWith("prefix", actual);

// Excepciones
await Assert.ThrowsAsync<ArgumentException>(
    () => handler.HandleAsync(command, CancellationToken.None));
```

### Estructura de prueba
```csharp
public sealed class CreateProductHandlerTests
{
    private readonly Mock<IProductRepository> _repo = new();
    private readonly CreateProductHandler _sut;

    public CreateProductHandlerTests()
    {
        _sut = new CreateProductHandler(_repo.Object);
    }

    [Fact]
    public async Task HandleAsync_WhenDataIsValid_ReturnsCreatedProduct()
    {
        // Arrange
        var command = new CreateProductCommand("Laptop", 999m, 5);
        _repo.Setup(r => r.AddAsync(It.IsAny<Product>(), It.IsAny<CancellationToken>()))
             .Returns(Task.CompletedTask);

        // Act
        var result = await _sut.HandleAsync(command, CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Laptop", result.Name);
        Assert.NotEqual(Guid.Empty, result.Id);
    }

    [Fact]
    public async Task HandleAsync_WhenPriceIsZero_ThrowsArgumentException()
    {
        // Arrange
        var command = new CreateProductCommand("Laptop", 0m, 5);

        // Act & Assert
        var ex = await Assert.ThrowsAsync<ArgumentException>(
            () => _sut.HandleAsync(command, CancellationToken.None));
        Assert.Contains("price", ex.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public async Task HandleAsync_WhenPriceIsNotPositive_ThrowsArgumentException(decimal price)
    {
        await Assert.ThrowsAsync<ArgumentException>(
            () => _sut.HandleAsync(new CreateProductCommand("X", price, 1), CancellationToken.None));
    }
}
```

### Tipos de prueba y herramientas

| Tipo | Qué prueba | Herramienta |
|---|---|---|
| Unitaria | Handlers, entidades, value objects | xUnit + Moq/NSubstitute |
| Integración repositorio | Acceso a BD real | xUnit + Testcontainers |
| Integración API | Endpoints HTTP completos | xUnit + `WebApplicationFactory<TProgram>` |
| Aceptación | Flujos críticos end-to-end | xUnit + `WebApplicationFactory` + BD real |

### Reglas comunes .NET

- Cada prueba: independiente. Sin estado compartido entre pruebas.
- Sin `Thread.Sleep` ni `Task.Delay`. Mockea el tiempo.
- No pruebes métodos privados directamente. Prueba comportamiento observable.
- Sin datos reales de producción en fixtures.

---

## Frontend Angular — Jest + Angular Testing Library

```typescript
describe('ProductService', () => {
  it('should call /api/products when getAll is called', () => {
    // Arrange — escrito ANTES de implementar el servicio
    const mockHttp = { get: jest.fn().mockReturnValue(of([])) } as any;
    const service = new ProductService(mockHttp);

    // Act
    service.getAll().subscribe();

    // Assert
    expect(mockHttp.get).toHaveBeenCalledWith('/api/products');
  });
});
```

---

## Frontend React — Jest + React Testing Library + MSW

```tsx
describe('ProductList', () => {
  it('should show loading state initially', () => {
    render(<ProductList />);
    expect(screen.getByRole('status')).toBeInTheDocument();
  });

  it('should show products when loaded', async () => {
    server.use(
      http.get('/api/products', () =>
        HttpResponse.json([{ id: '1', name: 'Laptop', price: 999 }]))
    );
    render(<ProductList />);
    expect(await screen.findByText('Laptop')).toBeInTheDocument();
  });

  it('should show error when API fails', async () => {
    server.use(http.get('/api/products', () => new HttpResponse(null, { status: 500 })));
    render(<ProductList />);
    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
```

### Reglas comunes frontend

- Prueba lo que el usuario ve y hace. No pruebes internals.
- Sin snapshot tests de componentes complejos.
- Cada prueba independiente. Resetea MSW handlers entre pruebas.

---

## Estructura de archivos de prueba

### .NET
```
tests/
  NombreProyecto.Domain.Tests/
    Entities/
    ValueObjects/
  NombreProyecto.Application.Tests/
    Features/
      Products/
        CreateProductHandlerTests.cs
  NombreProyecto.Infrastructure.Tests/
    Repositories/
      ProductRepositoryTests.cs
  NombreProyecto.API.Tests/
    Endpoints/
      ProductsEndpointTests.cs
```

### Angular
```
frontend/src/app/
  features/nombre-feature/
    services/nombre.service.spec.ts    ← junto al servicio
    components/nombre.component.spec.ts ← junto al componente
```

### React
```
frontend/src/
  features/nombre-feature/
    components/NombreComponente.test.tsx  ← junto al componente
    hooks/useNombreHook.test.ts
```

---

## Cobertura mínima

- Backend: 80% (ajustable en la configuración del proyecto).
- Frontend: 75% (ajustable).
- Medir con: `dotnet test --collect:"XPlat Code Coverage"` y `--coverage` en Jest.
