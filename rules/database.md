# Reglas de base de datos — SQL y NoSQL

> Aplica al trabajar en repositorios, DbContext, migraciones o acceso a datos.
> El motor activo se confirma al inicio del proyecto.

## Reglas comunes a todos los motores

- **Nunca construyas queries concatenando strings.** Usa parámetros siempre.
- Encapsula todo acceso a datos en repositorios. Nunca en controladores, handlers directamente ni componentes.
- Paginación en todas las queries sobre colecciones potencialmente grandes.
- Revisa N+1 queries antes de entregar. Señal: `Include` dentro de un loop o carga completa cuando solo necesitas dos campos.
- No modifiques migraciones ya aplicadas. Crea una nueva.
- Documenta cada migración: propósito, tablas afectadas, compatibilidad hacia atrás, estrategia de rollback.
- No ejecutes migraciones en ambientes compartidos sin aprobación explícita.
- No registres: queries con datos de usuarios, payloads completos, connection strings.

---

## [EF Core 9+]

### Configuración

```csharp
// Una clase por entidad — nunca DataAnnotations en entidades de dominio
public sealed class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> builder)
    {
        builder.ToTable("products");
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Name).IsRequired().HasMaxLength(200);
        builder.Property(p => p.Price).HasColumnType("decimal(18,2)");
        builder.HasIndex(p => p.Sku).IsUnique();
    }
}

// Registro automático en DbContext
protected override void OnModelCreating(ModelBuilder modelBuilder) =>
    modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
```

### Consultas

- `.AsNoTracking()` en todas las consultas de solo lectura.
- Proyecciones con `.Select(x => new Dto {...})` cuando solo necesitas algunos campos.
- Logging de SQL en desarrollo:
  ```csharp
  optionsBuilder.LogTo(Console.WriteLine,
      [DbLoggerCategory.Database.Command.Name], LogLevel.Information);
  ```
- Migraciones: nombres descriptivos (`AddProductPriceIndex`, no `Migration_20241201`).
- Para producción: genera scripts SQL con `dotnet ef migrations script` y aplícalos de forma controlada.

### Repositorio de referencia con EF Core

```csharp
public sealed class ProductRepository(AppDbContext context) : IProductRepository
{
    public async Task<Product?> GetByIdAsync(Guid id, CancellationToken ct = default) =>
        await context.Products
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == id, ct);

    public async Task<PagedResult<Product>> GetPagedAsync(int page, int size, CancellationToken ct = default)
    {
        var total = await context.Products.CountAsync(ct);
        var items = await context.Products
            .AsNoTracking()
            .OrderBy(p => p.Name)
            .Skip((page - 1) * size)
            .Take(size)
            .ToListAsync(ct);
        return new PagedResult<Product>(items, total, page, size);
    }

    public async Task AddAsync(Product product, CancellationToken ct = default)
    {
        await context.Products.AddAsync(product, ct);
        await context.SaveChangesAsync(ct);
    }
}
```

---

## [Dapper]

```csharp
public sealed class ProductRepository(IDbConnectionFactory connectionFactory) : IProductRepository
{
    public async Task<Product?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        await using var conn = await connectionFactory.CreateAsync(ct);
        return await conn.QueryFirstOrDefaultAsync<Product>(
            "SELECT * FROM products WHERE id = @Id",
            new { Id = id });
    }

    public async Task<IReadOnlyList<Product>> GetByCategoryAsync(string category, CancellationToken ct = default)
    {
        await using var conn = await connectionFactory.CreateAsync(ct);
        var results = await conn.QueryAsync<Product>(
            "SELECT * FROM products WHERE category = @Category ORDER BY name",
            new { Category = category });
        return results.AsList();
    }
}
```

- Parámetros nombrados siempre: `@NombreParametro`.
- `IDbConnection` scoped por request o `IDbConnectionFactory` para crear conexiones por operación.
- Para queries dinámicos complejos, usa SqlKata. Sin concatenación de strings.

---

## [MongoDB]

```csharp
public sealed class ProductRepository(IMongoCollection<Product> collection) : IProductRepository
{
    public async Task<Product?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        var filter = Builders<Product>.Filter.Eq(p => p.Id, id);
        return await collection.Find(filter).FirstOrDefaultAsync(ct);
    }

    public async Task<IReadOnlyList<Product>> GetByCategoryAsync(string category, CancellationToken ct = default)
    {
        var filter = Builders<Product>.Filter.Eq(p => p.Category, category);
        return await collection.Find(filter).ToListAsync(ct);
    }
}
```

- Diseña colecciones según patrones de acceso reales, no según normalización relacional.
- Define índices en startup o scripts de inicialización versionados.
- `FilterDefinitionBuilder<T>` para filtros. Sin construcción de filtros con strings.
- TTL en documentos que expiran naturalmente (sesiones, tokens temporales).
- Sin `BsonDocument` para tipos conocidos. Define clases tipadas.

---

## Verificación antes de entregar

- [ ] Sin concatenación de strings en queries
- [ ] Paginación en colecciones grandes
- [ ] Índices para los nuevos patrones de acceso
- [ ] Migración documentada si hubo cambio de esquema
- [ ] Pruebas de integración del repositorio con BD real (Testcontainers)
- [ ] `.AsNoTracking()` en lectura (EF Core)
- [ ] SQL generado revisado en desarrollo (EF Core)
- [ ] Sin datos sensibles en logs de queries
- [ ] `SaveChangesAsync` solo en repositorio o unidad de trabajo
