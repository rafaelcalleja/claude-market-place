🎯 Diferencia Fundamental: Commands vs Skills en plugin-dev

★ Insight ─────────────────────────────────────
- Commands = EJECUTAN workflows (hacer cosas)
- Skills = ENSEÑAN conocimiento (guiar al usuario)
- NO son intercambiables: Diferentes propósitos fundamentales
  ─────────────────────────────────────────────────

📋 EN PLUGIN-DEV ESPECÍFICAMENTE:

✅ COMANDO (solo 1 en plugin-dev):

/plugin-dev:create-plugin

¿Qué HACE?
✓ CREA archivos (plugin.json, README, directorio)
✓ EJECUTA validación (plugin-validator agent)
✓ GENERA estructura completa del plugin
✓ EJECUTA 8 fases con TodoWrite tracking
✓ CORRE bash scripts para testing
✓ INTERACTÚA con el usuario (AskUserQuestion)

Es un WORKFLOW EJECUTABLE. Cuando corres /plugin-dev:create-plugin "my-plugin":
1. Te pregunta qué tipo de plugin
2. Crea los directorios
3. Escribe plugin.json
4. Genera código
5. Valida todo
6. Te da checklist de testing

HACE COSAS automáticamente.

  ---
✅ SKILLS (7 en plugin-dev):

1. agent-development

¿Qué ENSEÑA?
- Cómo diseñar agents
- Sintaxis de frontmatter para agents
- Cuándo usar agents vs skills
- Ejemplos de agent prompts
- Best practices

¿Ejecuta algo? ❌ NO. Solo te enseña.

2. command-development

¿Qué ENSEÑA?
- Cómo crear slash commands
- Sintaxis de $ARGUMENTS, $1, $2
- File references con @
- Bash execution en commands
- YAML frontmatter options

¿Ejecuta algo? ❌ NO. Solo te enseña.

3. skill-development

¿Qué ENSEÑA?
- Cómo crear skills (ironía: una skill que enseña a crear skills)
- Progressive disclosure pattern
- Estructura SKILL.md
- Referencias y assets
- Best practices

¿Ejecuta algo? ❌ NO. Solo te enseña.

4. hook-development

¿Qué ENSEÑA?
- Cómo crear hooks (PreToolUse, PostToolUse, etc.)
- Event types
- Hook configuration
- Validation patterns

¿Ejecuta algo? ❌ NO. Solo te enseña.

5. mcp-integration

¿Qué ENSEÑA?
- Cómo integrar MCP servers
- .mcp.json configuration
- Server types (SSE, stdio, HTTP)
- ${CLAUDE_PLUGIN_ROOT} usage

¿Ejecuta algo? ❌ NO. Solo te enseña.

6. plugin-settings

¿Qué ENSEÑA?
- Cómo usar .local.md para settings
- YAML frontmatter para config
- User-configurable plugins
- Per-project settings

¿Ejecuta algo? ❌ NO. Solo te enseña.

7. plugin-structure

¿Qué ENSEÑA?
- Directory layout de plugins
- plugin.json manifest
- Dónde va cada componente
- Auto-discovery patterns
- Naming conventions

¿Ejecuta algo? ❌ NO. Solo te enseña.

  ---
🤔 ¿Pueden ser intercambiables?

❌ NO. Aquí está por qué:

| Aspecto          | Command                       | Skill                           |
  |------------------|-------------------------------|---------------------------------|
| Propósito        | EJECUTAR workflow             | ENSEÑAR conocimiento            |
| Invocación       | /comando args explícito       | Automática con trigger phrases  |
| Crea archivos?   | ✅ Sí (si es su función)       | ❌ Nunca                         |
| Modifica código? | ✅ Sí (si es su función)       | ❌ Nunca                         |
| Interactividad   | Flujo estructurado secuencial | Responde preguntas contextuales |
| Tracking         | TodoWrite phases              | No necesita (es consulta)       |

🔍 Ejemplo concreto:

Scenario: Quieres crear un nuevo agent.

Si usas COMMAND /plugin-dev:create-plugin:

/plugin-dev:create-plugin "my-agent-plugin"
Lo que pasa:
1. ✅ Pregunta: "¿Qué tipo de componente? (agent/skill/command)"
2. ✅ Seleccionas "agent"
3. ✅ Pregunta detalles del agent
4. ✅ CREA el archivo agents/my-agent.md
5. ✅ ESCRIBE el frontmatter
6. ✅ GENERA el prompt
7. ✅ VALIDA con agent-creator
8. ✅ Te dice "Agent created at agents/my-agent.md"

HIZO TODO POR TI.

Si usas SKILL agent-development:

User: "How do I create an agent?"
Lo que pasa:
1. ✅ Skill se activa automáticamente
2. ✅ Te EXPLICA: "Agents are autonomous subprocesses..."
3. ✅ Te MUESTRA estructura:
  ---
name: My Agent
description: ...
tools: [Read, Write, Grep]
  ---
4. ✅ Te ENSEÑA best practices
5. ✅ Te GUÍA pero TÚ escribes el código

NO HIZO NADA. Solo te enseñó CÓMO hacerlo tú.

  ---
💡 ¿Por qué no son intercambiables?

Commands necesitan:

- ✅ allowed-tools para EJECUTAR (Write, Bash, Task)
- ✅ Lógica secuencial (Phase 1 → Phase 2 → ...)
- ✅ Tracking con TodoWrite
- ✅ Validación con agents
- ✅ Ser determinísticos: siempre hacen los mismos pasos

Skills necesitan:

- ✅ Trigger phrases para auto-activación
- ✅ Progressive disclosure (metadata → SKILL.md → references)
- ✅ Ser consultativos: responden preguntas contextuales
- ✅ No modifican nada (read-only knowledge)

  ---
🎯 Regla de oro:

┌─────────────────────────────────────────────┐
│ Si necesitas HACER algo automáticamente    │
│ → COMMAND                                   │
│                                             │
│ Si necesitas EXPLICAR cómo hacer algo      │
│ → SKILL                                     │
└─────────────────────────────────────────────┘

Ejemplos aplicados a plugin-dev:

| Necesidad                                | Solución                                    | Tipo    |
  |------------------------------------------|---------------------------------------------|---------|
| Crear un plugin completo automáticamente | /plugin-dev:create-plugin                   | Command |
| Aprender cómo crear agents manualmente   | agent-development skill                     | Skill   |
| Entender estructura de plugins           | plugin-structure skill                      | Skill   |
| Validar mi plugin después de crearlo     | (No existe aún, sería /plugin-dev:validate) | Command |
| Aprender sintaxis de hooks               | hook-development skill                      | Skill   |

  ---