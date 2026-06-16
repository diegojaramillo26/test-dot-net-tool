# Tablas Temporales vs Variables Tipo Tabla — Comparativa Detallada

## Regla de uso según volumen

| Volumen de registros | Estructura recomendada |
|---|---|
| < 100 registros | Variable tipo tabla (`DECLARE @t TABLE`) |
| ≥ 100 registros | Tabla temporal (`#tabla`) o CTE |
| Muy grande + acceso concurrente | Tabla temporal con índices |

---

## Variables Tipo Tabla

```sql
DECLARE @MiTabla TABLE (
    Id      INT         NOT NULL,
    Nombre  VARCHAR(100) NOT NULL
)

INSERT INTO @MiTabla (Id, Nombre)
SELECT id, nombre FROM dbo.fuente WHERE condicion = 1
```

### Ventajas
- Menos re-compilaciones en procedimientos almacenados.
- Acceden a estructuras de memoria → menos I/O que tablas temporales.
- No se afectan por `ROLLBACK` (el contenido persiste aunque se revierta la transacción).

### Limitaciones
- No se pueden generar dinámicamente.
- **No usan paralelismo** (single thread) → lento para grandes volúmenes o alta concurrencia.
- **No se les pueden agregar índices**.
- No se pueden `ALTER` ni `TRUNCATE` una vez creadas.
- Si se insertan muchos registros, SQL Server las mueve a TEMPDB igualmente.

---

## Tablas Temporales

```sql
-- Crear tabla temporal
CREATE TABLE #MiTemporal (
    Id      INT         NOT NULL,
    Nombre  VARCHAR(100) NOT NULL
)

-- Opcionalmente agregar índice
CREATE INDEX IX_MiTemporal_Id ON #MiTemporal (Id)

-- Usar la tabla
INSERT INTO #MiTemporal (Id, Nombre)
SELECT id, nombre FROM dbo.fuente WHERE condicion = 1

-- SIEMPRE destruir al terminar
DROP TABLE #MiTemporal
```

### Ventajas
- Se almacenan en TEMPDB (disco/memoria según configuración del servidor).
- Permiten agregar **índices** → crítico para grandes volúmenes.
- Pueden tratarse como tablas normales.
- Soportan paralelismo en planes de ejecución.

### Limitaciones
- Su creación puede generar **bloqueos en tablas del sistema** (sysobjects, sysindexes).
- Pueden provocar **re-compilación continua** de los SPs que las contienen.
- Se destruyen al finalizar la sesión, pero hay que destruirlas explícitamente con `DROP TABLE`.

### ⚠️ Regla crítica — Destrucción de tablas temporales

```sql
-- SIEMPRE verificar existencia antes de crear (para evitar errores en re-ejecución)
IF OBJECT_ID('tempdb..#MiTemporal') IS NOT NULL
    DROP TABLE #MiTemporal

CREATE TABLE #MiTemporal (...)

-- ... lógica del SP ...

-- SIEMPRE al finalizar
DROP TABLE #MiTemporal
```

---

## Expresiones de Tabla Común (CTE)

Alternativa limpia para consultas complejas sin necesidad de crear objetos físicos:

```sql
WITH CTE_Alumnos AS (
    SELECT id, nombre, ROW_NUMBER() OVER (PARTITION BY nombre ORDER BY id) AS rn
    FROM dbo.alumnos
    WHERE activo = 1
)
SELECT id, nombre
FROM CTE_Alumnos
WHERE rn = 1
```

### Cuándo usar CTE
- Cuando la lógica es compleja y se puede expresar en una sola consulta.
- Para reemplazar subconsultas anidadas difíciles de leer.
- Para consultas recursivas (jerarquías, árboles).
- Cuando el resultado NO necesita ser reutilizado múltiples veces (si se necesita reusar, mejor tabla temporal).

---

## SELECT INTO — Por qué evitarlo

```sql
-- ❌ EVITAR: genera bloqueos en sysobjects y sysindexes
SELECT id, nombre
INTO #MiTemporal
FROM dbo.alumnos

-- ✅ CORRECTO: crear la tabla primero, luego insertar
CREATE TABLE #MiTemporal (
    id      INT         NOT NULL,
    nombre  VARCHAR(100) NOT NULL
)

INSERT INTO #MiTemporal (id, nombre)
SELECT id, nombre
FROM dbo.alumnos
```

`SELECT INTO` bloquea tablas del sistema mientras crea la estructura, lo que en servidores con alta concurrencia puede afectar a otras sesiones.

---

## Cursores — Cuándo y cómo

### ⚠️ Evaluar siempre antes de usar un cursor

Los cursores procesan fila a fila, consumiendo memoria proporcional al result set.

```sql
-- Estructura básica de un cursor
DECLARE cursor_nombre CURSOR FOR
    SELECT id, nombre FROM dbo.alumnos WHERE activo = 1

OPEN cursor_nombre

FETCH NEXT FROM cursor_nombre INTO @id, @nombre

WHILE @@FETCH_STATUS = 0
BEGIN
    -- lógica por fila
    FETCH NEXT FROM cursor_nombre INTO @id, @nombre
END

-- SIEMPRE cerrar y destruir
CLOSE cursor_nombre
DEALLOCATE cursor_nombre
```

### Alternativas al cursor (en orden de preferencia)

1. **JOIN con lógica de UPDATE/INSERT en bloque** → más eficiente en casi todos los casos
2. **Ciclo WHILE con tabla temporal** → más control que cursor, menos overhead
3. **Tablas derivadas** → para transformaciones en una sola pasada
4. **Subqueries correlacionados** → para lógica por fila sin cursor explícito
5. **CASE** → para lógica condicional dentro de una consulta set-based
6. **Múltiples consultas** → dividir el problema en pasos simples
