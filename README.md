# AI Dev Agent Template — Fullstack .NET 9+ / Angular 20+ o React 18+

Template minimalista de configuración para agentes de desarrollo IA.

## Estructura del repositorio

```
.
├── AGENTS.md                     ← Instrucciones universales (fuente de verdad)
├── rules/                        ← 8 reglas modulares
│   ├── backend-dotnet.md
│   ├── frontend-angular.md
│   ├── frontend-react.md
│   ├── architecture.md
│   ├── testing.md
│   ├── security.md
│   ├── database.md
│   └── git-workflow.md
├── subagents/                    ← 4 subagentes especializados
│   ├── architecture-reviewer.md
│   ├── test-generator.md
│   ├── security-reviewer.md
│   └── documentation-updater.md
├── skills/                       ← 4 skills reutilizables
│   ├── generate-feature/SKILL.md
│   ├── safe-refactor/SKILL.md
│   ├── create-tests/SKILL.md
│   └── security-review/SKILL.md
└── scripts/
    ├── setup.sh                  ← Linux / macOS
    └── setup.ps1                 ← Windows / PowerShell
```

Solo estos archivos se versionan. Los scripts generan todo lo demás.

## Uso

### Linux / macOS
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Windows
```powershell
.\scripts\setup.ps1
```

## Qué genera el script

El script pregunta qué agente y dónde está el proyecto, luego genera:

| Agente | Archivos generados en el proyecto destino |
|---|---|
| Claude Code | `AGENTS.md`, `CLAUDE.md`, `.mcp.json`, `.claude/rules/`, `.claude/agents/`, `.claude/skills/` |
| Cursor | `AGENTS.md`, `.cursor/rules/*.mdc`, `.cursor/mcp.json`, `.cursor/skills/` |
| GitHub Copilot | `AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/`, `.vscode/mcp.json`, `.github/skills/` |
| OpenCode | `AGENTS.md`, `opencode.json` (con MCP), `.opencode/agents/`, `.opencode/skills/` |
| Codex | `AGENTS.md`, `.codex/config.toml` (con MCP), `.codex/rules/`, `.codex/agents/`, `.agents/skills/` |
| Kiro | `AGENTS.md`, `.kiro/steering/`, `.kiro/settings/mcp.json`, `.kiro/skills/` |

## MCP — Documentación oficial de .NET

Todos los agentes se configuran con el servidor MCP de Microsoft Learn:
```
https://learn.microsoft.com/api/mcp
```
Nombre del servidor: `microsoft-docs`. Permite consultar documentación oficial de .NET,
ASP.NET Core, EF Core y otras APIs de Microsoft directamente desde el agente.

## Características

- **TDD obligatorio** — Prueba primero, luego implementación.
- **Sin librerías de pago** — xUnit nativo, Mediator propio, Mapster.
- **IHttpClientFactory** — Sin `new HttpClient()`.
- **SonarAnalyzer.CSharp** — En todos los proyectos no-test. `TreatWarningsAsErrors=true`.
- **GitFlow + Conventional Commits** — Reglas de ramas y formato de commits.
- **Agente documentador** — Mantiene README, ADRs y CHANGELOG al día.
- **Multi-agente** — Claude Code, Cursor, GitHub Copilot, OpenCode, Codex y Kiro.

## Actualizar el template

Edita los archivos en `rules/`, `subagents/` o `skills/` y vuelve a ejecutar el script
en el proyecto destino. Los archivos generados se sobreescriben automáticamente.
