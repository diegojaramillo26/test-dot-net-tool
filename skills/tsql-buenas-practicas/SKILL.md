---
name: tsql-buenas-practicas
description: >
  Guía de buenas prácticas para escritura de scripts T-SQL / SQL Server óptimos,
  definida por el equipo de Grupo Bios. Usar SIEMPRE que el agente vaya a escribir,
  revisar, corregir, optimizar o comentar código SQL, queries, procedimientos
  almacenados (stored procedures), funciones, vistas, cursores o cualquier objeto
  de base de datos T-SQL / SQL Server. Activar también cuando el usuario mencione
  "consulta SQL", "stored procedure", "SP", "query", "tabla temporal", "JOIN",
  "índice", "rendimiento de base de datos", "optimizar script", "procedimiento
  almacenado", "cursor SQL", "CTE", "transacción SQL", o cuando suba un archivo
  .sql para revisión. Esta skill contiene las reglas internas aprobadas por la
  organización; tienen prioridad sobre convenciones generales cuando haya diferencia.
---

# Buenas Prácticas T-SQL — Grupo Bios

Aplica estas reglas en TODO código SQL que escribas o revises.
Para el detalle completo de cada sección, consulta los archivos en `references/`.

---

## 1. Formato y Legibilidad

- **Indentar** con tabulaciones y saltos de línea. Cada cláusula principal en su propia línea.
- **Palabras reservadas en MAYÚSCULA**: SELECT, FROM, WHERE, AND, OR, JOIN, ON, GROUP BY, ORDER BY, INSERT, UPDATE, DELETE, etc.
- **No usar paréntesis** donde no sean necesarios para separar cálculos o reglas lógicas.

```sql
-- ✅ Correcto
SELECT TAlum.id, TAlum.nombre
FROM dbo.alumnos AS TAlum
WHERE TAlum.id = '123'

-- ❌ Evitar
select (Tal.Id) from dbo.alumnos AS Tal where (Tal.id = '123')
```

---

## 2. Reglas de Selección de Datos

- **Nunca usar `SELECT *`** — especificar siempre los campos requeridos.
- **Siempre especificar schema/owner**: `FROM dbo.tabla`, nunca `FROM tabla`.
- **Siempre usar alias** para las tablas y calificar cada campo con su alias: `TAlum.id`, no solo `id`.

---

## 3. JOINs

- Usar **INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN** explícitos. Nunca unir tablas por WHERE.
- Escribir siempre la palabra **OUTER** completa: `LEFT OUTER JOIN`, no `LEFT JOIN`.
- Hacer JOINs **siempre sobre campos llave primaria o índices**, en el mismo orden de los campos del índice.
- Se pueden poner condiciones de filtrado dentro del JOIN para reducir datos antes del filtro final.
- **JOIN antes que subconsultas** siempre que sea posible.

---

## 4. Filtros y Condiciones

- **NOT EXISTS en lugar de NOT IN** cuando se comparan con subqueries (NOT IN falla con NULLs).
- **BETWEEN en lugar de IN** para rangos continuos.
- En **LIKE**, evitar `%` al inicio de la cadena (`LIKE '%texto'` produce table scan). Poner al menos 3 caracteres antes del comodín.
- Siempre que los tipos de datos en JOIN, WHERE y parámetros **coincidan exactamente** con los de la tabla destino (las conversiones implícitas anulan índices).

---

## 5. Operaciones Costosas — Evitar cuando no sean necesarias

| Operación | Problema | Alternativa |
|---|---|---|
| `GROUP BY` | Tabla temporal + sort | Omitir si no es necesario |
| `ORDER BY` | Sort en memoria/disco | Solo si el resultado lo requiere |
| `DISTINCT` | Sort implícito | Revisar si el duplicado es real |
| `UNION` | Aplica DISTINCT implícito | Usar `UNION ALL` si no hay duplicados |
| `SELECT INTO` | Bloquea tablas del sistema | Usar `INSERT INTO … SELECT` |
| `LIKE '%texto'` | Table scan completo | Mover `%` al final o usar índices FTS |
| Funciones escalares en SELECT/WHERE | Ejecución fila a fila | Subconsulta o TVF inline |

---

## 6. Procedimientos Almacenados

- **Nunca usar el prefijo `sp_` o `SP_`**: SQL Server los busca en `master` primero.
  - Usar prefijo propio: `GBSP_` (ej: `GBSP_CONS_ITEM`).
  - Si ya existe con `SP_`, invocarlo siempre con base de datos y esquema: `EXEC BDCON.dbo.SP_CONSITE`.
- **Siempre incluir `SET NOCOUNT ON`** al inicio: elimina el conteo de filas afectadas y reduce tráfico de red.
- **Usar `SP_EXECUTESQL` en lugar de `EXECUTE`/`EXEC`** para SQL dinámico: admite parámetros, reutiliza planes de ejecución y previene SQL Injection.
- Si el SP tiene muchos bloques `IF-ELSE` para distintos procesos, **separar en SPs independientes** para preservar los planes de ejecución en memoria.
- **Preferir SPs sobre vistas y funciones** cuando el rendimiento sea prioritario.
- **Mantener las transacciones lo más cortas posible** dentro de un SP para reducir bloqueos.

---

## 7. Cursores

Evaluar siempre si realmente son necesarios — consumen mucha memoria. Alternativas preferibles:

- Ciclos `WHILE`
- Tablas derivadas
- Subqueries correlacionados
- `CASE`
- Múltiples consultas
- Combinación de las anteriores

Si se usan cursores: **siempre destruirlos** al finalizar (`DEALLOCATE cursor_name`).

---

## 8. Tablas Temporales y Variables Tipo Tabla

→ Ver comparativa detallada en `references/tablas-temporales.md`

**Regla rápida:**
- **< 100 registros** → Variable tipo tabla (`DECLARE @tabla TABLE (...)`)
- **≥ 100 registros** → Tabla temporal (`#tabla`) o CTE

**Siempre destruir tablas temporales** al finalizar: `DROP TABLE #tabla`.

**No usar `SELECT INTO`** para crear tablas temporales — genera bloqueos en sysobjects.

---

## 9. Tipos de Datos

- **NULLs**: usarlos cuando representen ausencia real de dato. No inventar valores (`-1`, `1/1/1900`, `'N/A'`, `' '`) para rellenar campos NOT NULL.
- **Siempre crear llave primaria** en todas las tablas, mínimo `IDENTITY`.
- **VARCHAR vs CHAR**: CHAR para longitud fija (más rápido en lectura), VARCHAR para longitud variable (ahorra espacio).
- **Texto largo < 8000 chars**: usar `VARCHAR` en lugar de `TEXT` (TEXT está deprecated).
- **No usar FLOAT, REAL ni DATETIME como FOREIGN KEY** (problemas de precisión en comparaciones).

---

## 10. Índices

- Crear índices en tablas temporales cuando haya tratamiento intensivo de datos.
- Los JOINs y WHERE deben usar campos indexados en el mismo orden del índice.
- Validar que los tipos de dato coincidan exactamente para que el índice se use.

---

## Checklist rápido antes de entregar un script

- [ ] ¿Palabras reservadas en MAYÚSCULA?
- [ ] ¿Cada cláusula en su propia línea con indentación?
- [ ] ¿Se especificó schema en todas las tablas (`dbo.tabla`)?
- [ ] ¿Se evitó `SELECT *`?
- [ ] ¿Todos los campos tienen alias de tabla?
- [ ] ¿Los JOINs son explícitos (no por WHERE)?
- [ ] ¿Se usó `NOT EXISTS` en lugar de `NOT IN`?
- [ ] ¿El SP no empieza con `sp_` o `SP_`?
- [ ] ¿Se incluyó `SET NOCOUNT ON`?
- [ ] ¿Se destruyen tablas temporales y cursores?
- [ ] ¿Los tipos de datos en JOINs y parámetros coinciden con la tabla?
- [ ] ¿Se evitó `SELECT INTO`?
- [ ] ¿Las transacciones son lo más cortas posible?
