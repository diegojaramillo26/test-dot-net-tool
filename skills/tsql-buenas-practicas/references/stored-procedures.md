# Procedimientos Almacenados y SQL Dinámico

## Nomenclatura de Procedimientos Almacenados

### ❌ Prohibido: prefijo `sp_` o `SP_`

```sql
-- ❌ NUNCA crear así
CREATE PROCEDURE SP_CONS_ITEM ...
CREATE PROCEDURE sp_consulta_alumnos ...
```

**Por qué:** SQL Server busca primero en la base de datos `master` cualquier SP con prefijo `sp_`.
Esto genera overhead en cada ejecución y puede provocar colisiones con SPs del sistema.

### ✅ Correcto: prefijo propio de la organización

```sql
-- ✅ Usar prefijo GBSP_ para Grupo Bios
CREATE PROCEDURE GBSP_CONS_ITEM ...
CREATE PROCEDURE GBSP_CONSULTA_ALUMNOS ...
```

### Si ya existe un SP con prefijo `SP_`

Mientras se migra, invocarlo siempre calificando base de datos y esquema:

```sql
-- ✅ Calificar completamente para evitar búsqueda en master
EXEC BDCON.dbo.SP_CONSITE
EXEC BDCON.dbo.SP_CONS_ITEM @param1 = valor
```

---

## Estructura base de un Stored Procedure

```sql
CREATE PROCEDURE GBSP_NOMBRE_SP
    @Parametro1   INT,
    @Parametro2   VARCHAR(100) = NULL   -- parámetros opcionales con default
AS
BEGIN
    SET NOCOUNT ON   -- SIEMPRE al inicio

    -- lógica del SP

END
GO
```

### ¿Por qué SET NOCOUNT ON?

En cada INSERT, UPDATE, DELETE y SELECT, SQL Server envía al cliente el conteo de filas
afectadas. En SPs complejos con múltiples operaciones, esto genera tráfico de red
innecesario. `SET NOCOUNT ON` lo suprime.

---

## SQL Dinámico — SP_EXECUTESQL vs EXEC

### ❌ EXEC con concatenación (vulnerable y lento)

```sql
-- ❌ EVITAR: vulnerable a SQL Injection y no reutiliza plan
DECLARE @sql NVARCHAR(1000)
SET @sql = 'SELECT * FROM dbo.' + @NombreTabla + ' WHERE id = ' + CAST(@Id AS VARCHAR)
EXEC (@sql)
```

### ✅ SP_EXECUTESQL con parámetros

```sql
-- ✅ CORRECTO: seguro, parametrizado, reutiliza plan de ejecución
DECLARE @sql        NVARCHAR(1000)
DECLARE @params     NVARCHAR(200)

SET @sql    = N'SELECT id, nombre FROM dbo.alumnos WHERE id = @IdParam AND activo = @ActivoParam'
SET @params = N'@IdParam INT, @ActivoParam BIT'

EXEC SP_EXECUTESQL @sql, @params,
    @IdParam     = @Id,
    @ActivoParam = 1
```

**Ventajas de SP_EXECUTESQL:**
- Admite parámetros → previene SQL Injection
- Genera un plan de ejecución reutilizable (caché)
- Más versátil que EXECUTE simple
- Aumenta probabilidades de reutilización eficaz del plan

---

## Transacciones en Stored Procedures

Mantener las transacciones lo más cortas posible:

```sql
CREATE PROCEDURE GBSP_ACTUALIZAR_ITEM
    @Id     INT,
    @Valor  DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON

    -- lógica de preparación FUERA de la transacción
    DECLARE @ValorAnterior DECIMAL(18,2)
    SELECT @ValorAnterior = valor FROM dbo.items WHERE id = @Id

    -- solo el bloque crítico dentro de la transacción
    BEGIN TRANSACTION
        UPDATE dbo.items
        SET valor = @Valor
        WHERE id = @Id

        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION
            RETURN -1
        END
    COMMIT TRANSACTION

    -- lógica post-commit FUERA de la transacción
    RETURN 0
END
```

**Por qué transacciones cortas:** cada transacción genera bloqueos (locks) sobre las filas/páginas
afectadas. Cuanto más tiempo esté abierta la transacción, más tiempo estarán bloqueadas esas
filas para otras sesiones. Esto puede generar deadlocks en servidores con alta concurrencia.

---

## SPs con mucha lógica condicional — Separar en SPs hijos

```sql
-- ❌ EVITAR: el plan de ejecución varía según el valor de @Tipo,
-- desperdiciando el plan en caché
CREATE PROCEDURE GBSP_PROCESAR
    @Tipo INT
AS
BEGIN
    SET NOCOUNT ON
    IF @Tipo = 1
        -- 50 líneas de lógica tipo 1
    ELSE IF @Tipo = 2
        -- 50 líneas de lógica tipo 2
    ELSE
        -- 50 líneas de lógica tipo 3
END

-- ✅ CORRECTO: cada bloque en su propio SP con su plan optimizado
CREATE PROCEDURE GBSP_PROCESAR_TIPO1 AS BEGIN SET NOCOUNT ON ... END
CREATE PROCEDURE GBSP_PROCESAR_TIPO2 AS BEGIN SET NOCOUNT ON ... END
CREATE PROCEDURE GBSP_PROCESAR_TIPO3 AS BEGIN SET NOCOUNT ON ... END

CREATE PROCEDURE GBSP_PROCESAR
    @Tipo INT
AS
BEGIN
    SET NOCOUNT ON
    IF @Tipo = 1      EXEC GBSP_PROCESAR_TIPO1
    ELSE IF @Tipo = 2 EXEC GBSP_PROCESAR_TIPO2
    ELSE              EXEC GBSP_PROCESAR_TIPO3
END
```

---

## Vistas y Funciones — Cuándo usarlas

La regla general es **preferir SPs**, pero hay excepciones válidas:

| Objeto | Cuándo es válido usarlo |
|---|---|
| **Vista** | Seguridad por columna (ocultar campos sensibles), simplificación de consultas ad hoc, reportes de BI |
| **Función TVF inline** | Cuando se necesita parametrizar una vista; el optimizador la trata como una vista y puede paralelizarla |
| **Función escalar** | Solo cuando la reutilización de código justifica el costo de rendimiento; evaluar caso a caso |
| **SP** | Caso general de lógica de negocio, operaciones DML, procesos batch |
