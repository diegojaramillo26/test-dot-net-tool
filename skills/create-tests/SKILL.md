---
name: create-tests
description: Crea pruebas para código existente sin cobertura o con cobertura insuficiente. Usa xUnit con Assert.* nativo para .NET y Jest + Testing Library para frontend. No genera código de producción.
---

# Skill: Crear pruebas

## Entradas esperadas

- Archivo(s) de código a probar.
- Tipo: unitaria, integración de repositorio, integración de API, o componente frontend.

## Proceso

### Paso 1 — Analizar el código

1. Lee los archivos a probar completos.
2. Identifica métodos y comportamientos públicos.
3. Detecta: happy paths, errores esperados, bordes, contratos.
4. Verifica qué pruebas ya existen para no duplicar.

### Paso 2 — Determinar rutas

- .NET: en `tests/NombreProyecto.TipoCapa.Tests/` espejando `backend/`.
- Angular: junto al archivo en `*.spec.ts`.
- React: junto al archivo en `*.test.ts` o `*.test.tsx`.

### Paso 3 — Generar archivos de prueba

**Backend .NET — xUnit sin FluentAssertions:**
```csharp
public sealed class ProductRepositoryTests : IClassFixture<DatabaseFixture>
{
    private readonly ProductRepository _sut;

    public ProductRepositoryTests(DatabaseFixture fixture)
    {
        _sut = new ProductRepository(fixture.DbContext);
    }

    [Fact]
    public async Task GetByIdAsync_WhenProductExists_ReturnsProduct()
    {
        // Arrange + Act + Assert
        var result = await _sut.GetByIdAsync(fixture.SeedProductId, CancellationToken.None);
        Assert.NotNull(result);
        Assert.Equal(fixture.SeedProductId, result.Id);
    }

    [Fact]
    public async Task GetByIdAsync_WhenProductNotFound_ReturnsNull()
    {
        var result = await _sut.GetByIdAsync(Guid.NewGuid(), CancellationToken.None);
        Assert.Null(result);
    }
}
```

**React — Jest + Testing Library + MSW:**
```tsx
describe('useProducts', () => {
  it('should return products on success', async () => {
    server.use(
      http.get('/api/products', () =>
        HttpResponse.json([{ id: '1', name: 'Laptop', price: 999 }]))
    );
    const { result } = renderHook(() => useProducts(), { wrapper: QueryClientWrapper });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    Assert.equal(1, result.current.data!.length);
    expect(result.current.data![0].name).toBe('Laptop');
  });

  it('should set error state when API fails', async () => {
    server.use(http.get('/api/products', () => new HttpResponse(null, { status: 500 })));
    const { result } = renderHook(() => useProducts(), { wrapper: QueryClientWrapper });
    await waitFor(() => expect(result.current.isError).toBe(true));
  });
});
```

### Paso 4 — Verificar

- [ ] `dotnet test` o `npm test` con los nuevos tests en verde.
- [ ] Cobertura del módulo mejora respecto al estado anterior.
- [ ] Sin datos reales de producción en fixtures.
- [ ] Cada prueba es independiente.

## Restricciones

- Sin FluentAssertions. Solo `Assert.*` nativo de xUnit.
- Sin `Thread.Sleep` ni `Task.Delay`.
- Sin pruebas de métodos privados directamente.
- Sin snapshot tests de componentes complejos.
- Sin datos reales de producción en fixtures.
- Sin código de producción.
