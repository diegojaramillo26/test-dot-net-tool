#!/usr/bin/env bash
# =============================================================================
# setup.sh — AI Dev Agent: Fullstack .NET 9+ / Angular 20+ o React 18+
#
# Uso: ./setup.sh
# El script se ubica en la raíz del repositorio.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
RULES_DIR="$ROOT_DIR/rules"
SUBAGENTS_DIR="$ROOT_DIR/subagents"
SKILLS_DIR="$ROOT_DIR/skills"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
log_info() { echo -e "  ${BLUE}→${NC} $1"; }

# =============================================================================
# SECCIÓN 1: FRONTMATTER Y TRANSFORMADORES
# =============================================================================

mdc_frontmatter() {
  case "$1" in
    backend-dotnet)   printf '%s\n' '---' 'description: Reglas de backend .NET 9+. Aplica en archivos C# y proyectos .NET.' 'globs: "backend/**/*.cs,backend/**/*.csproj,backend/**/appsettings*.json,backend/**/Migrations/**"' 'alwaysApply: false' '---' '' ;;
    frontend-angular) printf '%s\n' '---' 'description: Reglas de Angular 20+. Aplica en componentes, servicios y rutas Angular.' 'globs: "frontend/**/*.component.ts,frontend/**/*.component.html,frontend/**/*.service.ts,frontend/**/*.guard.ts,frontend/**/app.config.ts"' 'alwaysApply: false' '---' '' ;;
    frontend-react)   printf '%s\n' '---' 'description: Reglas de React 18+. Aplica en archivos TSX, JSX, hooks y stores.' 'globs: "frontend/**/*.tsx,frontend/**/*.jsx,frontend/**/hooks/**/*.ts,frontend/**/stores/**/*.ts"' 'alwaysApply: false' '---' '' ;;
    architecture)     printf '%s\n' '---' 'description: Reglas de arquitectura backend. Aplica al crear o modificar capas.' 'globs: "backend/**/*.cs"' 'alwaysApply: false' '---' '' ;;
    testing)          printf '%s\n' '---' 'description: Reglas TDD. Aplica en archivos de prueba y al crear nuevas clases.' 'globs: "**/*.spec.ts,**/*.test.tsx,**/*.test.ts,**/*Tests.cs,tests/**"' 'alwaysApply: false' '---' '' ;;
    security)         printf '%s\n' '---' 'description: Reglas de seguridad OWASP Top 10. Aplica siempre.' 'alwaysApply: true' '---' '' ;;
    database)         printf '%s\n' '---' 'description: Reglas de base de datos. Aplica en repositorios, DbContext y migraciones.' 'globs: "backend/**/Migrations/**,backend/**/*Repository*.cs,backend/**/*DbContext*.cs"' 'alwaysApply: false' '---' '' ;;
    git-workflow)     printf '%s\n' '---' 'description: GitFlow y Conventional Commits. Aplica siempre.' 'alwaysApply: true' '---' '' ;;
    *)                printf '%s\n' '---' 'description: Regla del proyecto.' 'alwaysApply: false' '---' '' ;;
  esac
}

copilot_apply_to() {
  case "$1" in
    backend-dotnet)   echo "backend/**/*.cs,backend/**/*.csproj,backend/**/appsettings*.json" ;;
    frontend-angular) echo "frontend/**/*.component.ts,frontend/**/*.service.ts,frontend/**/app.config.ts" ;;
    frontend-react)   echo "frontend/**/*.tsx,frontend/**/*.jsx,frontend/**/hooks/**/*.ts" ;;
    architecture)     echo "backend/**/*.cs" ;;
    testing)          echo "tests/**,**/*.spec.ts,**/*.test.ts,**/*Tests.cs" ;;
    security)         echo "**/*" ;;
    database)         echo "backend/**/Migrations/**,backend/**/*Repository*.cs,backend/**/*DbContext*.cs" ;;
    git-workflow)     echo "**/*" ;;
    *)                echo "**/*" ;;
  esac
}

kiro_frontmatter() {
  case "$1" in
    backend-dotnet)   printf '%s\n' '---' 'inclusion: fileMatch' 'fileMatchPattern: "backend/**/*.cs,backend/**/*.csproj,backend/**/appsettings*.json"' '---' '' ;;
    frontend-angular) printf '%s\n' '---' 'inclusion: fileMatch' 'fileMatchPattern: "frontend/**/*.component.ts,frontend/**/*.service.ts,frontend/**/app.config.ts"' '---' '' ;;
    frontend-react)   printf '%s\n' '---' 'inclusion: fileMatch' 'fileMatchPattern: "frontend/**/*.tsx,frontend/**/*.jsx,frontend/**/hooks/**/*.ts"' '---' '' ;;
    architecture)     printf '%s\n' '---' 'inclusion: fileMatch' 'fileMatchPattern: "backend/**/*.cs"' '---' '' ;;
    testing)          printf '%s\n' '---' 'inclusion: fileMatch' 'fileMatchPattern: "**/*.spec.ts,**/*.test.ts,**/*Tests.cs,tests/**"' '---' '' ;;
    security)         printf '%s\n' '---' 'inclusion: always' '---' '' ;;
    database)         printf '%s\n' '---' 'inclusion: fileMatch' 'fileMatchPattern: "backend/**/Migrations/**,backend/**/*Repository*.cs,backend/**/*DbContext*.cs"' '---' '' ;;
    git-workflow)     printf '%s\n' '---' 'inclusion: always' '---' '' ;;
    *)                printf '%s\n' '---' 'inclusion: manual' '---' '' ;;
  esac
}

copy_skills() {
  local dest_skills="$1"
  mkdir -p "$dest_skills"
  for skill_dir in "$SKILLS_DIR"/*/; do
    local name; name="$(basename "$skill_dir")"
    mkdir -p "$dest_skills/$name"
    cp "$skill_dir/SKILL.md" "$dest_skills/$name/SKILL.md"
    log_ok "$dest_skills/$name/SKILL.md"
  done
}

# =============================================================================
# SECCIÓN 2: CONTENIDO EMBEBIDO — ARCHIVOS ESPECÍFICOS POR AGENTE
# =============================================================================

gen_claude_md() { cat << 'CLAUDE_MD_END'
# Claude Code — Fullstack .NET 9+ / Angular 20+ o React 18+

Lee `AGENTS.md` antes de comenzar cualquier tarea.

---

## Reglas cargadas automáticamente (`.claude/rules/`)

| Archivo | Se activa al trabajar en |
|---|---|
| `backend-dotnet.md` | Archivos `.cs`, `.csproj`, `appsettings*.json` |
| `frontend-angular.md` | Componentes, servicios, guards Angular |
| `frontend-react.md` | Archivos `.tsx`, `.jsx`, hooks, stores |
| `architecture.md` | Creación o modificación de capas |
| `testing.md` | Archivos de prueba y clases nuevas |
| `security.md` | Siempre |
| `database.md` | Repositorios, DbContext, migraciones |
| `git-workflow.md` | Siempre |

---

## Subagentes (`.claude/agents/`)

| Invocar | Propósito |
|---|---|
| `/agent architecture-reviewer` | Valida dependencias entre capas |
| `/agent test-generator` | Genera pruebas TDD |
| `/agent security-reviewer` | Revisión OWASP Top 10 |
| `/agent documentation-updater` | Actualiza docs tras cambios |

---

## Skills (`.claude/skills/`)

| Invocar | Propósito |
|---|---|
| `/skill generate-feature` | Feature completa con TDD |
| `/skill safe-refactor` | Refactorización sin romper comportamiento |
| `/skill create-tests` | Pruebas para código existente |
| `/skill security-review` | Revisión de seguridad OWASP |

---

## MCP disponible

`microsoft-docs` → Documentación oficial de .NET, ASP.NET Core, EF Core y Microsoft Learn.
Usa este servidor antes de asumir comportamientos de APIs del framework.
CLAUDE_MD_END
}

gen_mcp_json_claude() { cat << 'MCP_CLAUDE_END'
{
  "mcpServers": {
    "microsoft-docs": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
MCP_CLAUDE_END
}

gen_mcp_json_cursor() { cat << 'MCP_CURSOR_END'
{
  "mcpServers": {
    "microsoft-docs": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
MCP_CURSOR_END
}

gen_mcp_json_vscode() { cat << 'MCP_VSCODE_END'
{
  "servers": {
    "microsoft-docs": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
MCP_VSCODE_END
}

gen_mcp_json_kiro() { cat << 'MCP_KIRO_END'
{
  "mcpServers": {
    "microsoft-docs": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
MCP_KIRO_END
}

gen_cursor_general_mdc() { cat << 'CURSOR_GENERAL_END'
---
description: Reglas generales del proyecto fullstack .NET 9+ / Angular o React. Aplica siempre.
alwaysApply: true
---

# Reglas generales

- Proyecto nuevo: pregunta arquitectura, estilo de API, frontend y base de datos antes de generar código.
- Proyecto existente: analiza la estructura antes de preguntar.
- **TDD primero:** prueba antes de la implementación.
- Backend en `backend/`, frontend en `frontend/`, pruebas .NET en `tests/`.

## Stack de referencia

- Testing .NET: xUnit + `Assert.*` nativo. Sin FluentAssertions.
- Mediator: patrón propio. Sin MediatR.
- Mapeo: Mapster. Sin AutoMapper.
- HTTP externo: `IHttpClientFactory`. Sin `new HttpClient()`.
- Análisis estático: SonarAnalyzer.CSharp en todos los proyectos no-test.
- Documentación .NET: servidor MCP `microsoft-docs`.

## Prohibiciones absolutas

- No código de producción sin prueba previa.
- No `new HttpClient()` directo.
- No concatenación de strings en queries.
- No FluentAssertions, MediatR ni AutoMapper.
- No secretos en archivos versionables.
- No `.Result` ni `.Wait()` en async.
- No commits sin listar archivos y esperar aprobación.
CURSOR_GENERAL_END
}

gen_copilot_instructions() { cat << 'COPILOT_INSTR_END'
# Instrucciones para GitHub Copilot

## Stack

- **Backend:** .NET 9+ en `backend/`
- **Frontend:** Angular 20+ o React 18+ en `frontend/`
- **Tests .NET:** en `tests/`

## Proyecto nuevo — pregunta primero

1. Arquitectura: Clean Architecture / Vertical Slice / Hexagonal / N-Capas.
2. Estilo de API: Minimal API con patrón REPR o Controllers.
3. Frontend: Angular 20+ o React 18+.
4. Base de datos: PostgreSQL, SQL Server, MySQL, MongoDB, otro.

## Proyecto existente

Analiza la estructura y respeta las convenciones detectadas.

## TDD obligatorio

Ciclo: Red → Green → Refactor. Prueba antes de implementar.

## Stack de librerías

- Testing: xUnit + `Assert.*` nativo. Sin FluentAssertions.
- Mediator: patrón propio. Sin MediatR.
- Mapeo: Mapster. Sin AutoMapper.
- HTTP externo: `IHttpClientFactory`. Sin `new HttpClient()`.
- Análisis estático: SonarAnalyzer.CSharp. TreatWarningsAsErrors=true.
- Minimal API: patrón REPR. Sin endpoints en Program.cs.

## MCP disponible

`microsoft-docs` → Documentación oficial de .NET en `https://learn.microsoft.com/api/mcp`.
Consulta este servidor antes de asumir comportamientos de APIs del framework.

## Reglas clave

- TypeScript `strict: true`. Sin `any`.
- Async/await en I/O. Sin `.Result` ni `.Wait()`.
- Sin lógica de negocio en controladores ni componentes.
- Sin concatenación de strings en queries.
- Sin secretos en código. Sin passwords/tokens/PII en logs.
- OWASP Top 10 vigente.
COPILOT_INSTR_END
}

gen_opencode_json() { cat << 'OPENCODE_JSON_END'
{
  "$schema": "https://opencode.ai/schemas/config.json",
  "instructions": ["AGENTS.md"],
  "agents": {
    "plan":                   ".opencode/agents/plan.md",
    "review":                 ".opencode/agents/review.md",
    "tests":                  ".opencode/agents/tests.md",
    "security":               ".opencode/agents/security.md",
    "documentation-updater":  ".opencode/agents/documentation-updater.md"
  },
  "mcp": {
    "servers": {
      "microsoft-docs": {
        "type": "http",
        "url": "https://learn.microsoft.com/api/mcp"
      }
    }
  },
  "permissions": {
    "allow":           ["read", "write"],
    "requireApproval": ["execute"]
  }
}
OPENCODE_JSON_END
}

gen_opencode_plan() { cat << 'OC_PLAN_END'
# Agente de planificación

## Rol

Planificas la implementación de una feature o cambio siguiendo TDD: el plan incluye las pruebas como primer paso.

## Cuándo usarme

- Antes de comenzar una feature nueva.
- Antes de una refactorización amplia.
- Cuando no está claro por dónde empezar.

## Mi proceso

1. Leo `AGENTS.md` para conocer arquitectura y reglas.
2. Entiendo el requerimiento funcional.
3. Propongo un plan TDD con archivos en orden (pruebas primero, implementación después).
4. Indico rutas exactas bajo `backend/`, `frontend/` o `tests/`.
5. Espero aprobación antes de que se comience a implementar.

## Mi salida

- Lista ordenada: pruebas primero, implementación después.
- Rutas exactas de todos los archivos.
- Comportamientos que prueba cada archivo de test.
- Dependencias entre cambios.
- Riesgos y estimación de complejidad: Baja / Media / Alta.

## Lo que no hago

Sin generar código. Sin omitir las pruebas del plan.
OC_PLAN_END
}

gen_opencode_review() { cat << 'OC_REVIEW_END'
# Agente de revisión de código

## Rol

Revisas código propuesto con criterio de tech lead. Solo lectura.

## Mi proceso

1. Leo `AGENTS.md` para conocer arquitectura y reglas.
2. Leo los archivos del cambio.
3. Verifico: TDD aplicado, arquitectura, separación de responsabilidades, seguridad, logging.
4. Verifico que no se usan FluentAssertions, MediatR ni AutoMapper.
5. Verifico SonarAnalyzer: sin supresiones injustificadas.

## Mi salida

- Archivo y línea.
- Descripción del problema.
- Severidad: Bloqueante / Advertencia / Sugerencia.
- Corrección propuesta.

## Lo que priorizo

1. Pruebas faltantes (TDD no aplicado).
2. Violaciones de arquitectura.
3. Issues de SonarAnalyzer suprimidas sin justificación.
4. Bugs reales y riesgos de seguridad.
5. Librerías prohibidas.

## Lo que no hago

Sin modificar archivos. Sin reportar estilo puro.
OC_REVIEW_END
}

gen_opencode_tests() { cat << 'OC_TESTS_END'
# Agente generador de pruebas (TDD)

## Rol

Generas pruebas siguiendo TDD. Modo preferido: pruebas antes de la implementación.

## Frameworks

- Backend: xUnit + `Assert.*` nativo (sin FluentAssertions) + Moq + Testcontainers.
- Angular: Jest + Angular Testing Library.
- React: Jest + React Testing Library + MSW.

## Por cada unidad

- Happy path completo.
- Al menos un escenario de error esperado.
- Bordes relevantes (nulos, vacíos, límites).

## Lo que no hago

Sin FluentAssertions. Sin Thread.Sleep. Sin snapshot tests complejos. Sin código de producción.
OC_TESTS_END
}

gen_opencode_security() { cat << 'OC_SEC_END'
# Agente revisor de seguridad

## Rol

Revisas código contra OWASP Top 10. Solo lectura.

## Severidades

- **Crítica** (bloquear merge): inyección con input externo, secretos hardcodeados, autorización ausente.
- **Alta** (corregir antes del merge): CORS mal configurado, JWT sin validación completa, datos sensibles en logs.
- **Media** (próximo ciclo): headers ausentes, rate limiting ausente, dependencias vulnerables.

## Por hallazgo

- Severidad y categoría OWASP. Archivo y línea. Descripción del riesgo. Corrección concreta.

## Lo que no hago

Sin modificar archivos. Sin falsos positivos sin evidencia.
OC_SEC_END
}

gen_opencode_docs() { cat << 'OC_DOCS_END'
# Agente actualizador de documentación

## Rol

Mantienes README, ADRs, CHANGELOG y OpenAPI al día tras cada cambio relevante.

## Cuándo actuar

- Al completar una feature. Al cambiar endpoints de API. Al modificar variables de entorno.
- Al cambiar arquitectura o estructura de carpetas. Al corregir bugs que afectan docs.

## Formato ADR

```markdown
# ADR-NNN: Título

**Estado:** Aceptado
**Fecha:** YYYY-MM-DD

## Contexto
Problema o situación.

## Decisión
Qué se decidió y por qué.

## Consecuencias
Beneficios, compromisos, deuda técnica.
```

## Lo que no hago

Sin modificar código de producción ni pruebas. Sin borrar secciones sin proponerlo primero.
OC_DOCS_END
}

gen_codex_config_toml() { cat << 'CODEX_CFG_END'
# Configuración del proyecto para Codex
# Lee AGENTS.md antes de comenzar cualquier tarea.

[project]
instructions_file = "AGENTS.md"

[approval]
approval_policy = "on-request"

[sandbox]
sandbox_mode = "workspace-write"

[agents]
max_threads = 4
max_depth = 1

[agents.subagents]
reviewer              = ".codex/agents/reviewer.toml"
test_generator        = ".codex/agents/test-generator.toml"
security_reviewer     = ".codex/agents/security-reviewer.toml"
documentation_updater = ".codex/agents/documentation-updater.toml"

[mcp.servers.microsoft-docs]
type = "http"
url  = "https://learn.microsoft.com/api/mcp"
CODEX_CFG_END
}

gen_codex_safe_commands() { cat << 'CODEX_RULES_END'
# Reglas de comandos para Codex

allow_rule(
    pattern = ["dotnet", "build"],
    justification = "Compilar es seguro.",
)
allow_rule(
    pattern = ["dotnet", "test"],
    justification = "Ejecutar tests es seguro.",
)
allow_rule(
    pattern = ["dotnet", "restore"],
    justification = "Restaurar paquetes NuGet es seguro.",
)
allow_rule(
    pattern = ["dotnet", "format"],
    justification = "Formatear código es seguro.",
)
allow_rule(
    pattern = ["dotnet", "list", "package", "--vulnerable"],
    justification = "Auditar vulnerabilidades es solo lectura.",
)
allow_rule(
    pattern = ["npm", "install"],
    justification = "Instalar dependencias Node.js.",
)
allow_rule(
    pattern = ["npm", "run", "build"],
    justification = "Compilar frontend.",
)
allow_rule(
    pattern = ["npm", "test"],
    justification = "Ejecutar tests de frontend.",
)
allow_rule(
    pattern = ["npm", "run", "lint"],
    justification = "Lint es solo lectura.",
)
allow_rule(
    pattern = ["npm", "audit"],
    justification = "Auditar vulnerabilidades npm.",
)
allow_rule(
    pattern = ["ng", "build"],
    justification = "Compilar Angular.",
)
allow_rule(
    pattern = ["ng", "test"],
    justification = "Ejecutar tests Angular.",
)
allow_rule(
    pattern = ["git", "status"],
    justification = "Solo lectura.",
)
allow_rule(
    pattern = ["git", "diff"],
    justification = "Solo lectura.",
)
allow_rule(
    pattern = ["git", "log"],
    justification = "Solo lectura.",
)
prompt_rule(
    pattern = ["dotnet", "ef", "database", "update"],
    justification = "Aplicar migraciones modifica la BD. Requiere aprobación.",
)
prompt_rule(
    pattern = ["dotnet", "ef", "migrations", "add"],
    justification = "Crear migración modifica el esquema. Requiere revisión.",
)
prompt_rule(
    pattern = ["dotnet", "ef", "database", "drop"],
    justification = "Destructivo. Requiere aprobación.",
)
prompt_rule(
    pattern = ["git", "commit"],
    justification = "Mostrar archivos y mensaje antes de ejecutar.",
)
prompt_rule(
    pattern = ["git", "push"],
    justification = "Publicar remotamente requiere confirmación.",
)
prompt_rule(
    pattern = ["dotnet", "add", "package"],
    justification = "Agregar paquete modifica el proyecto. Requiere justificación.",
)
prompt_rule(
    pattern = ["npm", "install", "--save"],
    justification = "Agregar dependencia modifica package.json.",
)
forbidden_rule(
    pattern = ["rm", "-rf"],
    justification = "Irreversible. Prohibido.",
)
forbidden_rule(
    pattern = ["git", "push", "--force"],
    justification = "Puede destruir historial compartido. Prohibido.",
)
forbidden_rule(
    pattern = ["docker", "system", "prune"],
    justification = "Destructivo. Prohibido.",
)
forbidden_rule(
    pattern = ["terraform", "destroy"],
    justification = "Destruye infraestructura. Prohibido.",
)
CODEX_RULES_END
}

gen_codex_reviewer_toml() { cat << 'CODEX_REV_END'
name        = "reviewer"
description = "Revisor de código para pull requests. Verifica correctness, arquitectura, TDD, seguridad, SonarAnalyzer y pruebas faltantes. Solo lectura."
sandbox_mode = "read-only"

developer_instructions = """
Actúas como tech lead revisando código de un proyecto fullstack .NET 9+ / Angular o React.

Lee AGENTS.md y rules/backend-dotnet.md antes de comenzar.

Tu proceso:
1. Lee todos los archivos del cambio.
2. Verifica que la arquitectura activa se respeta.
3. Verifica que se aplicó TDD: cada clase o caso de uso nuevo debe tener prueba.
4. Verifica que no hay issues de SonarAnalyzer suprimidas sin justificación.
5. Verifica que TreatWarningsAsErrors no fue deshabilitado sin razón.
6. Verifica que no hay lógica de negocio en controladores, endpoints ni componentes.
7. Verifica que no hay queries construidas con concatenación de strings.
8. Verifica que no hay secretos en código.
9. Verifica que no se usan FluentAssertions, MediatR ni AutoMapper.
10. Verifica que no hay new HttpClient() directo.

Tu salida por hallazgo:
- Archivo y línea.
- Descripción concreta del problema.
- Severidad: Bloqueante / Advertencia / Sugerencia.
- Corrección propuesta.

No modifiques archivos.
"""
CODEX_REV_END
}

gen_codex_test_generator_toml() { cat << 'CODEX_TG_END'
name        = "test-generator"
description = "Generador de pruebas TDD para .NET 9+ / Angular o React. Usa xUnit con Assert.* nativo. Sin FluentAssertions."

developer_instructions = """
Actúas como especialista en TDD para proyectos fullstack .NET 9+ / Angular o React.

Lee AGENTS.md y rules/testing.md antes de comenzar.

Frameworks:
- Backend: xUnit + Assert.* nativo (sin FluentAssertions) + Moq o NSubstitute + Testcontainers
- Angular: Jest + Angular Testing Library
- React: Jest + React Testing Library + MSW

Modos:
1. TDD puro (preferido): recibes descripción del comportamiento. Generas pruebas en rojo ANTES de que exista la implementación.
2. Cobertura: código existente sin pruebas. Generas pruebas para los huecos.

Nomenclatura .NET: MetodoOEscenario_Condicion_ResultadoEsperado
Estructura: Arrange / Act / Assert
Aserciones: Assert.Equal, Assert.NotNull, Assert.ThrowsAsync, Assert.True, etc.

Por cada unidad:
- Happy path completo.
- Al menos un escenario de error esperado.
- Bordes relevantes (nulos, vacíos, límites).

No generes: FluentAssertions, snapshot tests complejos, Thread.Sleep, datos de producción, código de producción.
"""
CODEX_TG_END
}

gen_codex_security_reviewer_toml() { cat << 'CODEX_SR_END'
name        = "security-reviewer"
description = "Revisor de seguridad OWASP Top 10 para .NET 9+ y frontend Angular o React. Solo lectura."
sandbox_mode = "read-only"

developer_instructions = """
Actúas como especialista en seguridad de aplicaciones web.

Lee AGENTS.md y rules/security.md antes de comenzar.

Prioridad Crítica (bloquear merge):
- Inyección SQL/NoSQL con input del usuario.
- Secretos hardcodeados.
- Autorización ausente en endpoints sensibles.
- Contraseñas en texto plano o hash débil.

Prioridad Alta (corregir antes del merge):
- CORS mal configurado.
- JWT sin validación completa.
- Datos sensibles en logs.
- HTTPS no forzado.
- innerHTML/dangerouslySetInnerHTML con contenido externo.

Por hallazgo: severidad, categoría OWASP, archivo y línea, descripción del riesgo, corrección concreta.

No modifiques archivos. No reportes estilo como seguridad.
"""
CODEX_SR_END
}

gen_codex_docs_updater_toml() { cat << 'CODEX_DU_END'
name        = "documentation-updater"
description = "Actualiza documentación técnica tras cambios relevantes: features, cambios de API, arquitectura, variables de entorno o dependencias."

developer_instructions = """
Actúas como technical writer que mantiene la documentación al día.

Lee AGENTS.md antes de comenzar.

Qué actualizas:
- README.md: comandos, variables de entorno, estructura, instalación.
- docs/architecture/ o docs/: ADRs y decisiones arquitectónicas.
- CHANGELOG.md: entradas con formato Keep a Changelog.
- OpenAPI/Swagger: verifica que nuevos endpoints tienen ProducesResponseType o TypedResults.

Formato ADR:
---
# ADR-NNN: Título
**Estado:** Aceptado
**Fecha:** YYYY-MM-DD

## Contexto
## Decisión
## Consecuencias
---

Reglas:
- Documenta el POR QUÉ, no solo el QUÉ.
- Sin secciones vacías. Mantén el idioma del proyecto.
- No modifiques código de producción ni pruebas.
"""
CODEX_DU_END
}

gen_kiro_general_steering() { cat << 'KIRO_GENERAL_END'
---
inclusion: always
---

# Reglas generales del proyecto

## Proyecto nuevo — Pregunta primero

Antes de generar cualquier archivo, obtén:
1. **Arquitectura backend:** Clean Architecture / Vertical Slice / Hexagonal / N-Capas.
2. **Estilo de API:** Minimal API con patrón REPR, o Controllers.
3. **Frontend:** Angular 20+, React 18+, o no aplica.
4. **Base de datos:** PostgreSQL, SQL Server, MySQL, MongoDB, otro.

## Proyecto existente

Inspecciona la estructura y respeta las convenciones detectadas.

## Estructura del proyecto

```
backend/    ← .NET 9+
frontend/   ← Angular 20+ o React 18+
tests/      ← Pruebas .NET
```

## TDD — No negociable

```
RED → Escribe la prueba. Debe fallar.
GREEN → Implementa lo mínimo para que pase.
REFACTOR → Mejora. Pruebas siguen verdes.
```

## Stack de referencia

- Testing .NET: xUnit + `Assert.*` nativo. Sin FluentAssertions.
- Mediator: patrón propio. Sin MediatR.
- Mapeo: Mapster. Sin AutoMapper.
- HTTP externo: `IHttpClientFactory`. Sin `new HttpClient()`.
- Análisis estático: SonarAnalyzer.CSharp en proyectos no-test. TreatWarningsAsErrors=true.
- Documentación .NET: servidor MCP `microsoft-docs` configurado en `.kiro/settings/mcp.json`.

## Prohibiciones absolutas

- No código de producción sin prueba previa.
- No `new HttpClient()` directo.
- No concatenación de strings en queries.
- No FluentAssertions, MediatR ni AutoMapper.
- No secretos en archivos versionables.
- No commits sin listar archivos y esperar aprobación.
KIRO_GENERAL_END
}

# =============================================================================
# SECCIÓN 3: FUNCIONES DE SETUP POR AGENTE
# =============================================================================

setup_claude_code() {
  local dest="$1"
  echo -e "${CYAN}${BOLD}Configurando Claude Code...${NC}"

  cp "$ROOT_DIR/AGENTS.md" "$dest/AGENTS.md"; log_ok "AGENTS.md"
  gen_claude_md > "$dest/CLAUDE.md";          log_ok "CLAUDE.md"
  gen_mcp_json_claude > "$dest/.mcp.json";    log_ok ".mcp.json (microsoft-docs)"

  mkdir -p "$dest/.claude/rules"
  for f in "$RULES_DIR"/*.md; do
    cp "$f" "$dest/.claude/rules/"
    log_ok ".claude/rules/$(basename "$f")"
  done

  mkdir -p "$dest/.claude/agents"
  for f in "$SUBAGENTS_DIR"/*.md; do
    cp "$f" "$dest/.claude/agents/"
    log_ok ".claude/agents/$(basename "$f")"
  done

  copy_skills "$dest/.claude/skills"
  echo -e "${GREEN}  ✓ Claude Code configurado${NC}"
}

setup_cursor() {
  local dest="$1"
  echo -e "${CYAN}${BOLD}Configurando Cursor...${NC}"

  cp "$ROOT_DIR/AGENTS.md" "$dest/AGENTS.md"; log_ok "AGENTS.md"

  mkdir -p "$dest/.cursor/rules"
  gen_cursor_general_mdc > "$dest/.cursor/rules/general.mdc"; log_ok ".cursor/rules/general.mdc"

  for f in "$RULES_DIR"/*.md; do
    local name; name="$(basename "$f" .md)"
    { mdc_frontmatter "$name"; cat "$f"; } > "$dest/.cursor/rules/${name}.mdc"
    log_ok ".cursor/rules/${name}.mdc"
  done

  gen_mcp_json_cursor > "$dest/.cursor/mcp.json"; log_ok ".cursor/mcp.json (microsoft-docs)"

  copy_skills "$dest/.cursor/skills"
  echo -e "${GREEN}  ✓ Cursor configurado${NC}"
}

setup_copilot() {
  local dest="$1"
  echo -e "${CYAN}${BOLD}Configurando GitHub Copilot...${NC}"

  cp "$ROOT_DIR/AGENTS.md" "$dest/AGENTS.md"; log_ok "AGENTS.md"

  mkdir -p "$dest/.github/instructions"
  gen_copilot_instructions > "$dest/.github/copilot-instructions.md"
  log_ok ".github/copilot-instructions.md"

  for f in "$RULES_DIR"/*.md; do
    local name; name="$(basename "$f" .md)"
    local apply_to; apply_to="$(copilot_apply_to "$name")"
    { printf '%s\n' "---" "applyTo: \"$apply_to\"" "---" ""; cat "$f"; } \
      > "$dest/.github/instructions/${name}.instructions.md"
    log_ok ".github/instructions/${name}.instructions.md"
  done

  mkdir -p "$dest/.vscode"
  gen_mcp_json_vscode > "$dest/.vscode/mcp.json"; log_ok ".vscode/mcp.json (microsoft-docs)"

  copy_skills "$dest/.github/skills"
  echo -e "${GREEN}  ✓ GitHub Copilot configurado${NC}"
}

setup_opencode() {
  local dest="$1"
  echo -e "${CYAN}${BOLD}Configurando OpenCode...${NC}"

  cp "$ROOT_DIR/AGENTS.md" "$dest/AGENTS.md"; log_ok "AGENTS.md"
  gen_opencode_json > "$dest/opencode.json";   log_ok "opencode.json (con MCP microsoft-docs)"

  mkdir -p "$dest/.opencode/agents"
  gen_opencode_plan     > "$dest/.opencode/agents/plan.md";                  log_ok ".opencode/agents/plan.md"
  gen_opencode_review   > "$dest/.opencode/agents/review.md";                log_ok ".opencode/agents/review.md"
  gen_opencode_tests    > "$dest/.opencode/agents/tests.md";                 log_ok ".opencode/agents/tests.md"
  gen_opencode_security > "$dest/.opencode/agents/security.md";              log_ok ".opencode/agents/security.md"
  gen_opencode_docs     > "$dest/.opencode/agents/documentation-updater.md"; log_ok ".opencode/agents/documentation-updater.md"

  for f in "$SUBAGENTS_DIR"/*.md; do
    cp "$f" "$dest/.opencode/agents/"
    log_ok ".opencode/agents/$(basename "$f")"
  done

  copy_skills "$dest/.opencode/skills"
  echo -e "${GREEN}  ✓ OpenCode configurado${NC}"
}

setup_codex() {
  local dest="$1"
  echo -e "${CYAN}${BOLD}Configurando Codex...${NC}"

  cp "$ROOT_DIR/AGENTS.md" "$dest/AGENTS.md"; log_ok "AGENTS.md"
  mkdir -p "$dest/.codex/rules" "$dest/.codex/agents"

  gen_codex_config_toml        > "$dest/.codex/config.toml";                        log_ok ".codex/config.toml (con MCP microsoft-docs)"
  gen_codex_safe_commands      > "$dest/.codex/rules/safe-commands.rules";           log_ok ".codex/rules/safe-commands.rules"
  gen_codex_reviewer_toml      > "$dest/.codex/agents/reviewer.toml";               log_ok ".codex/agents/reviewer.toml"
  gen_codex_test_generator_toml > "$dest/.codex/agents/test-generator.toml";        log_ok ".codex/agents/test-generator.toml"
  gen_codex_security_reviewer_toml > "$dest/.codex/agents/security-reviewer.toml";  log_ok ".codex/agents/security-reviewer.toml"
  gen_codex_docs_updater_toml  > "$dest/.codex/agents/documentation-updater.toml";  log_ok ".codex/agents/documentation-updater.toml"

  # Codex: skills en .agents/skills/ (convención propia)
  copy_skills "$dest/.agents/skills"
  echo -e "${GREEN}  ✓ Codex configurado${NC}"
}

setup_kiro() {
  local dest="$1"
  echo -e "${CYAN}${BOLD}Configurando Kiro...${NC}"

  cp "$ROOT_DIR/AGENTS.md" "$dest/AGENTS.md"; log_ok "AGENTS.md"

  mkdir -p "$dest/.kiro/steering"
  gen_kiro_general_steering > "$dest/.kiro/steering/general.md"; log_ok ".kiro/steering/general.md"

  for f in "$RULES_DIR"/*.md; do
    local name; name="$(basename "$f" .md)"
    { kiro_frontmatter "$name"; cat "$f"; } > "$dest/.kiro/steering/${name}.md"
    log_ok ".kiro/steering/${name}.md"
  done

  mkdir -p "$dest/.kiro/settings"
  gen_mcp_json_kiro > "$dest/.kiro/settings/mcp.json"; log_ok ".kiro/settings/mcp.json (microsoft-docs)"

  copy_skills "$dest/.kiro/skills"
  echo -e "${GREEN}  ✓ Kiro configurado${NC}"
}

# =============================================================================
# SECCIÓN 4: MAIN
# =============================================================================

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║    AI Dev Agent — Setup de proyecto fullstack        ║${NC}"
echo -e "${CYAN}${BOLD}║    .NET 9+  /  Angular 20+  /  React 18+            ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}${BOLD}Selecciona el agente de desarrollo:${NC}"
echo -e "  ${BOLD}1)${NC} Claude Code"
echo -e "  ${BOLD}2)${NC} Cursor"
echo -e "  ${BOLD}3)${NC} GitHub Copilot"
echo -e "  ${BOLD}4)${NC} OpenCode"
echo -e "  ${BOLD}5)${NC} Codex"
echo -e "  ${BOLD}6)${NC} Kiro"
echo -e "  ${BOLD}7)${NC} Todos los agentes"
echo ""
read -rp "$(echo -e "${BOLD}Opción [1-7]:${NC} ")" AGENT_CHOICE

if [[ ! "$AGENT_CHOICE" =~ ^[1-7]$ ]]; then
  echo -e "${RED}Opción inválida.${NC}"; exit 1
fi

echo ""
read -rp "$(echo -e "${BOLD}Ruta de destino del proyecto (Enter = directorio actual):${NC} ")" DEST_PATH
DEST_PATH="${DEST_PATH:-.}"; DEST_PATH="${DEST_PATH%/}"

if [[ ! -d "$DEST_PATH" ]]; then
  read -rp "$(echo -e "${YELLOW}Directorio '$DEST_PATH' no existe. ¿Crearlo? [s/N]:${NC} ")" CREATE_DIR
  [[ "$CREATE_DIR" =~ ^[sS]$ ]] && mkdir -p "$DEST_PATH" || { echo -e "${RED}Cancelado.${NC}"; exit 1; }
fi

DEST_PATH="$(cd "$DEST_PATH" && pwd)"
echo -e "${BLUE}Destino: ${BOLD}$DEST_PATH${NC}"; echo ""

case "$AGENT_CHOICE" in
  1) setup_claude_code "$DEST_PATH" ;;
  2) setup_cursor      "$DEST_PATH" ;;
  3) setup_copilot     "$DEST_PATH" ;;
  4) setup_opencode    "$DEST_PATH" ;;
  5) setup_codex       "$DEST_PATH" ;;
  6) setup_kiro        "$DEST_PATH" ;;
  7)
    setup_claude_code "$DEST_PATH"; echo ""
    setup_cursor      "$DEST_PATH"; echo ""
    setup_copilot     "$DEST_PATH"; echo ""
    setup_opencode    "$DEST_PATH"; echo ""
    setup_codex       "$DEST_PATH"; echo ""
    setup_kiro        "$DEST_PATH"
    ;;
esac

echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║     ✓ Configuración completada                       ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Limpiando carpetas del template...${NC}"
for folder in rules skills subagents; do
    if [[ -d "$ROOT_DIR/$folder" ]]; then
        rm -rf "$ROOT_DIR/$folder"
        log_ok "Eliminado: $folder/"
    fi
done
echo ""
echo -e "${BOLD}Destino:${NC} $DEST_PATH"
echo ""
echo -e "${BOLD}Próximos pasos:${NC}"
echo -e "  ${CYAN}1.${NC} Proyecto ${BOLD}nuevo${NC}: dile al agente qué quieres construir."
echo -e "     Preguntará arquitectura, estilo de API, frontend y base de datos."
echo -e "  ${CYAN}2.${NC} Proyecto ${BOLD}existente${NC}: comparte el repositorio. El agente analiza primero."
echo -e "  ${CYAN}3.${NC} El agente aplica ${BOLD}TDD${NC}: prueba primero, implementación después."
echo -e "  ${CYAN}4.${NC} Servidor MCP ${BOLD}microsoft-docs${NC} configurado para consultar documentación .NET."
echo ""
