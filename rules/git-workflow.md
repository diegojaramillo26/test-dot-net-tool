# Reglas de Git — GitFlow + Conventional Commits

## Modelo de ramas (GitFlow)

### Ramas permanentes

| Rama | Propósito | Acepta merges desde |
|---|---|---|
| `main` | Código en producción. Siempre estable. | `release/*`, `hotfix/*` |
| `develop` | Integración continua. Base para features. | `feature/*`, `bugfix/*`, `release/*` |

### Ramas temporales

| Tipo | Nombre | Base | Merge hacia |
|---|---|---|---|
| Feature | `feature/descripcion-breve` | `develop` | `develop` |
| Release | `release/vX.Y.Z` | `develop` | `main` + `develop` |
| Hotfix | `hotfix/descripcion-breve` | `main` | `main` + `develop` |
| Bugfix | `bugfix/descripcion-breve` | `develop` | `develop` |

### Reglas de ramas

- **No hagas commits directos en `main` ni en `develop`.**
- Nombres de rama: minúsculas, kebab-case. Ejemplos: `feature/order-cancellation`, `hotfix/jwt-expiry-fix`.
- Una rama = una feature o fix. No mezcles contextos en la misma rama.
- Elimina la rama local y remota después del merge.
- Antes de abrir PR: asegúrate de que `dotnet build && dotnet test` pasan en verde.

---

## Conventional Commits

### Formato

```
<tipo>(<scope>): <descripción en presente, minúsculas, sin punto final>

[cuerpo opcional — explica el QUÉ y el POR QUÉ]

[pie opcional]
BREAKING CHANGE: descripción del breaking change
Closes #N
```

### Tipos

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Nueva funcionalidad visible para el usuario o consumidor de la API |
| `fix` | Corrección de bug |
| `refactor` | Cambio de código sin cambio de comportamiento ni corrección de bug |
| `test` | Agregar, corregir o reorganizar pruebas |
| `docs` | Cambios solo en documentación |
| `chore` | Mantenimiento, herramientas, actualización de dependencias |
| `perf` | Mejora de rendimiento |
| `ci` | Cambios en pipelines CI/CD |
| `build` | Cambios en build system o dependencias del proyecto |
| `style` | Formato, espaciado (sin cambio funcional) |

### Scope

Usa el nombre del módulo, feature, capa o componente afectado.

```
feat(orders): add order cancellation endpoint
fix(auth): correct JWT expiration validation
refactor(products): extract pricing calculation to value object
test(users): add integration tests for user repository
docs(readme): update local setup instructions
chore(deps): update EF Core to 9.0.2
perf(products): add index on category_id column
```

### Breaking changes

Agrega `!` después del tipo/scope o usa el pie `BREAKING CHANGE:`:

```
feat(api)!: rename /users endpoint to /accounts

BREAKING CHANGE: clientes existentes deben actualizar la URL base de /users a /accounts.
```

---

## Proceso antes de proponer un commit

1. Lista los archivos modificados: `git status`.
2. Revisa el diff: `git diff --staged`.
3. Verifica que los tests pasan: `dotnet test` / `npm test`.
4. **Propón el mensaje de commit** al usuario.
5. **Espera aprobación** antes de ejecutar el commit.
6. Ejecuta: `git commit -m "tipo(scope): descripción"`.

---

## Pull Requests / Merge Requests

- Una PR por feature o fix. Sin mezclar contextos.
- El título de la PR sigue el formato de Conventional Commits.
- La PR debe pasar todos los tests y el lint antes de solicitar revisión.
- Resuelve todos los comentarios de revisión antes de hacer merge.

### Estrategia de merge recomendada

| Tipo de rama | Estrategia |
|---|---|
| `feature/*` → `develop` | Squash merge (historial limpio) |
| `bugfix/*` → `develop` | Squash merge |
| `release/*` → `main` | Merge commit (preserva historial del release) |
| `hotfix/*` → `main` | Merge commit |

---

## Prohibiciones

- No hagas commits en `main` ni en `develop` directamente.
- No uses mensajes vagos: `"fix"`, `"changes"`, `"wip"`, `"update"`.
- No mezcles cambios no relacionados en un mismo commit.
- No uses emojis en mensajes de commit.
- No forces push en ramas compartidas (`main`, `develop`) sin coordinación explícita del equipo.
- No cierres la PR sin que los tests estén en verde.
