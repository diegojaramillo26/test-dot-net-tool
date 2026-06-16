# Tipos de Datos y JOINs — Referencia Detallada

## Tipos de Datos

### NULL — Cuándo usarlo

```sql
-- ✅ NULL para ausencia real de dato
CREATE TABLE dbo.empleados (
    id              INT             NOT NULL IDENTITY(1,1),
    nombre          VARCHAR(100)    NOT NULL,
    fecha_retiro    DATE            NULL,       -- puede no haber sido retirado aún
    telefono_alt    VARCHAR(20)     NULL        -- puede no tener teléfono alternativo
)

-- ❌ EVITAR: valores inventados para esquivar NOT NULL
fecha_retiro    DATE    NOT NULL DEFAULT '1900-01-01'   -- sin sentido semántico
telefono_alt    VARCHAR(20) NOT NULL DEFAULT 'N/A'      -- rompe lógica de negocio
```

### CHAR vs VARCHAR

| Tipo | Longitud | Velocidad lectura | Espacio | Cuándo usar |
|---|---|---|---|---|
| `CHAR(n)` | Fija (padding con espacios) | ✅ Más rápido | Mayor | Códigos fijos: país (`CO`), estado (`ACT`), tipo doc (`CC`) |
| `VARCHAR(n)` | Variable | Algo más lento | Menor | Nombres, direcciones, descripiciones |

```sql
-- ✅ Ejemplos correctos
codigo_pais     CHAR(2)         NOT NULL,   -- siempre 2 chars
tipo_doc        CHAR(3)         NOT NULL,   -- CC, NIT, PAS
nombre          VARCHAR(100)    NOT NULL,   -- longitud variable
descripcion     VARCHAR(500)    NULL        -- longitud muy variable
```

### TEXT vs VARCHAR para textos largos

```sql
-- ❌ EVITAR: TEXT está deprecated en SQL Server moderno
observaciones   TEXT            NULL

-- ✅ CORRECTO: VARCHAR(MAX) o VARCHAR con límite si < 8000 chars
observaciones   VARCHAR(8000)   NULL    -- si siempre < 8000 chars
observaciones   VARCHAR(MAX)    NULL    -- si puede ser > 8000 chars
```

### FLOAT / REAL / DATETIME como Foreign Key — Prohibido

```sql
-- ❌ NUNCA como FK
CREATE TABLE dbo.detalle (
    precio_fk   FLOAT       NOT NULL,   -- problemas de precisión en igualdad
    fecha_fk    DATETIME    NOT NULL,   -- milisegundos hacen imposible la igualdad exacta
)

-- ✅ FK siempre sobre tipos exactos
CREATE TABLE dbo.detalle (
    item_id     INT         NOT NULL,   -- INT, BIGINT, SMALLINT
    codigo      CHAR(10)    NOT NULL    -- CHAR, VARCHAR con longitud definida
)
```

**Por qué:** FLOAT y REAL son aproximaciones de punto flotante. Dos valores que "deberían ser
iguales" pueden diferir en el último decimal, haciendo que el JOIN no encuentre la fila.
DATETIME tiene precisión de 3.33ms, lo que genera el mismo problema.

---

## JOINs — Guía completa

### Nunca unir por WHERE

```sql
-- ❌ EVITAR: producto cartesiano + filtro (ineficiente y confuso)
SELECT A.id, A.nombre, B.curso
FROM dbo.alumnos A, dbo.inscripciones B
WHERE A.id = B.alumno_id
  AND A.activo = 1

-- ✅ CORRECTO: JOIN explícito
SELECT A.id, A.nombre, B.curso
FROM dbo.alumnos AS A
INNER JOIN dbo.inscripciones AS B ON A.id = B.alumno_id
WHERE A.activo = 1
```

### Tipos de JOIN y cuándo usarlos

```sql
-- INNER JOIN: solo filas que tienen coincidencia en ambas tablas
SELECT A.id, B.curso
FROM dbo.alumnos AS A
INNER JOIN dbo.inscripciones AS B ON A.id = B.alumno_id

-- LEFT OUTER JOIN: todas las filas de A, con o sin coincidencia en B
SELECT A.id, B.curso
FROM dbo.alumnos AS A
LEFT OUTER JOIN dbo.inscripciones AS B ON A.id = B.alumno_id
-- Los alumnos sin inscripción aparecen con B.curso = NULL

-- RIGHT OUTER JOIN: todas las filas de B, con o sin coincidencia en A
SELECT A.id, B.curso
FROM dbo.alumnos AS A
RIGHT OUTER JOIN dbo.inscripciones AS B ON A.id = B.alumno_id
-- Inscripciones sin alumno aparecen con A.id = NULL
-- (raro; generalmente se prefiere reescribir como LEFT OUTER JOIN)
```

**Regla de escritura:** siempre escribir `LEFT OUTER JOIN` y `RIGHT OUTER JOIN` con la
palabra `OUTER` completa (no abreviar a `LEFT JOIN`).

### Condiciones de filtrado en el JOIN

```sql
-- Se puede filtrar dentro del ON para reducir datos antes del join
SELECT A.id, A.nombre, B.nota
FROM dbo.alumnos AS A
INNER JOIN dbo.notas AS B
    ON A.id = B.alumno_id
    AND B.periodo = '2024-1'      -- filtra notas ANTES de unir con alumnos
WHERE A.activo = 1
```

### NOT IN vs NOT EXISTS

```sql
-- ❌ NOT IN con posibles NULLs en el subquery → puede retornar 0 filas inesperadamente
SELECT id, nombre
FROM dbo.alumnos
WHERE id NOT IN (SELECT alumno_id FROM dbo.suspendidos)
-- Si ANY fila de dbo.suspendidos tiene alumno_id = NULL, la consulta retorna vacío

-- ✅ NOT EXISTS → más seguro y generalmente más eficiente
SELECT A.id, A.nombre
FROM dbo.alumnos AS A
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.suspendidos AS S
    WHERE S.alumno_id = A.id
)
```

### BETWEEN para rangos

```sql
-- ✅ BETWEEN para rangos continuos (más legible y eficiente que múltiples condiciones)
SELECT id, nombre, fecha_ingreso
FROM dbo.alumnos
WHERE fecha_ingreso BETWEEN '2024-01-01' AND '2024-12-31'

-- Equivalente pero menos claro
WHERE fecha_ingreso >= '2024-01-01' AND fecha_ingreso <= '2024-12-31'
```

### LIKE — Posición del comodín

```sql
-- ❌ EVITAR: % al inicio → table scan (ignora índices)
WHERE nombre LIKE '%García'
WHERE nombre LIKE '%arc%'

-- ✅ CORRECTO: al menos 3 caracteres antes del %
WHERE nombre LIKE 'Gar%'
WHERE nombre LIKE 'García%'
```

### UNION vs UNION ALL

```sql
-- ❌ UNION: aplica DISTINCT implícito (sort + dedup = más lento)
SELECT id FROM dbo.tabla_a
UNION
SELECT id FROM dbo.tabla_b

-- ✅ UNION ALL: cuando se sabe que no hay duplicados (más rápido)
SELECT id FROM dbo.tabla_a
UNION ALL
SELECT id FROM dbo.tabla_b
```

---

## Coincidencia de tipos en JOINs y WHERE

```sql
-- Suponer: dbo.alumnos.id es INT

-- ❌ EVITAR: conversión implícita anula el índice sobre id
WHERE id = '123'          -- VARCHAR vs INT → implicit conversion
WHERE id = 123.0          -- DECIMAL vs INT → implicit conversion

-- ✅ CORRECTO: mismo tipo que la columna
WHERE id = 123            -- INT vs INT → usa el índice
```

Lo mismo aplica para parámetros de SPs:

```sql
-- Si @IdAlumno es VARCHAR pero alumnos.id es INT:
-- El motor convierte cada fila de la tabla, anulando el índice

-- ✅ Siempre declarar el parámetro del mismo tipo que la columna
CREATE PROCEDURE GBSP_BUSCAR_ALUMNO
    @IdAlumno INT    -- mismo tipo que dbo.alumnos.id
AS
...
```
