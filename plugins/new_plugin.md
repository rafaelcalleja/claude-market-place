# Elicitación de Requisitos: Nuevo Plugin Claude Code

**Fecha**: 2025-10-12
**Proyecto Base**: ccfabric (Fabric Patterns Integration)
**Objetivo**: Crear un nuevo plugin para el marketplace basándose en la estructura de ccfabric

---

## Mapa Mental: Componentes del Plugin

```
PLUGIN CLAUDE CODE
│
├─ 1. IDENTIDAD DEL PLUGIN
│   ├─ Nombre del plugin (kebab-case)
│   ├─ Versión semántica (x.y.z)
│   ├─ Descripción breve
│   ├─ Categoría (development/productivity/security/etc)
│   ├─ Keywords/Tags
│   └─ Información del autor
│
├─ 2. COMANDOS (Slash Commands)
│   ├─ Para cada comando:
│   │   ├─ Nombre del comando
│   │   ├─ Descripción
│   │   ├─ Argumentos esperados
│   │   ├─ Herramientas permitidas
│   │   ├─ Categoría
│   │   ├─ Nivel de complejidad
│   │   ├─ MCP servers requeridos
│   │   └─ Lógica de ejecución
│   │
│   └─ Tipos de comandos observados:
│       ├─ Delegación a agentes (suggest_pattern)
│       ├─ Orquestación compleja (orchestrate_patterns)
│       ├─ Ejecución directa con extractos (summarize)
│       └─ Wrapper de agente (exec)
│
├─ 3. AGENTES (Sub-agents)
│   ├─ Para cada agente:
│   │   ├─ Nombre del agente
│   │   ├─ Descripción de cuándo usarlo
│   │   ├─ Modelo preferido (inherit/opus/sonnet)
│   │   ├─ Color de terminal
│   │   ├─ Capacidades específicas
│   │   ├─ Responsabilidades core
│   │   ├─ Metodología de trabajo
│   │   └─ Formato de salida
│   │
│   └─ Tipos de agentes observados:
│       ├─ Suggester (analiza y sugiere, NO ejecuta)
│       └─ Executor (ejecuta patrones específicos)
│
├─ 4. HOOKS (Event Handlers)
│   ├─ Eventos disponibles:
│   │   ├─ PreToolUse
│   │   ├─ PostToolUse
│   │   ├─ Stop
│   │   ├─ SubagentStop
│   │   ├─ SessionStart
│   │   └─ UserPromptSubmit
│   │
│   └─ Para cada hook:
│       ├─ Tipo de evento
│       ├─ Matcher pattern
│       ├─ Tipo de hook (command/validation/notification)
│       └─ Comando a ejecutar
│
├─ 5. ARCHIVOS CORE (Data/Resources)
│   ├─ Archivos JSON de datos
│   ├─ Archivos de configuración
│   ├─ Scripts auxiliares
│   └─ Recursos estáticos
│
├─ 6. CONFIGURACIÓN
│   ├─ MCP Server Permissions
│   ├─ Tool Permissions
│   └─ Settings específicos del plugin
│
└─ 7. INTEGRACIÓN CON MARKETPLACE
    ├─ Ubicación en /plugins/[nombre-plugin]/
    ├─ Estructura .claude-plugin/
    ├─ README.md
    └─ LICENSE

```

---

## DECISIONES NECESARIAS

### CATEGORÍA A: Identidad y Metadatos

**A.1 Información Básica del Plugin**
- [x] ¿Cuál es el nombre del plugin? **fabric-helper**
- [x] ¿Cuál es la versión inicial? **1.0.0**
- [x] ¿Cuál es la descripción del plugin? **"Fabric AI system integration with pattern suggestion and execution workflows"**
- [x] ¿Cuál es la categoría principal? **development**
- [x] ¿Qué palabras clave describen el plugin? **["fabric", "workflow", "analysis", "ai", "patterns"]**

**A.2 Autoría**
- [x] ¿Nombre del autor? **Rafael Calleja**
- [x] ¿Email del autor? **[Sin especificar]**
- [ ] ¿URL del autor? **[Sin especificar]**
- [x] ¿Licencia del plugin? **MIT**

---

### CATEGORÍA B: Comandos (Slash Commands)

**B.1 Decisiones Generales sobre Comandos**
- [x] ¿Cuántos comandos tendrá el plugin? **3 comandos: suggest, orchestrate, exec**
- [x] ¿Los comandos delegarán a agentes o ejecutarán directamente? **Sí, delegarán a agentes especializados**
- [x] ¿Se necesita orquestación de múltiples pasos? **Sí, el comando orchestrate**
- [x] ¿Los comandos usarán archivos de datos externos? **Sí, pattern_descriptions.json y pattern_extracts.json**

**B.2 Para Cada Comando Individual**

**Comando #1: suggest**
- [x] Nombre del comando (sin /): **suggest**
- [x] Descripción breve: **"Suggest Fabric patterns based on user prompt analysis"**
- [x] ¿Qué argumentos acepta?: **[user_prompt]**
- [x] ¿Hint para argumentos?: **"Describe what you want to do"**
- [x] ¿Qué herramientas necesita?: **[Task]**
- [x] Categoría del comando: **utility**
- [x] Nivel de complejidad: **basic**
- [x] ¿Requiere MCP servers específicos?: **No**
- [x] ¿Delega a un agente?: **Sí, pattern-suggester**
- [x] Lógica de ejecución:
  1. Recibe prompt del usuario
  2. Delega al agente pattern-suggester
  3. El agente lee pattern_descriptions.json
  4. Analiza el prompt y sugiere patrones
  5. Devuelve nombres de patrones recomendados

**Comando #2: orchestrate**
- [x] Nombre del comando (sin /): **orchestrate**
- [x] Descripción breve: **"Orchestrate complete Fabric pattern workflows"**
- [x] ¿Qué argumentos acepta?: **[user_prompt]**
- [x] ¿Hint para argumentos?: **"Describe your complete workflow need"**
- [x] ¿Qué herramientas necesita?: **[Task, TodoWrite]**
- [x] Categoría del comando: **utility**
- [x] Nivel de complejidad: **intermediate**
- [x] ¿Requiere MCP servers específicos?: **No**
- [x] ¿Delega a un agente?: **Sí, pattern-suggester + pattern-executor (secuencia)**
- [x] Lógica de ejecución:
  1. Recibe prompt del usuario
  2. Llama a pattern-suggester para obtener secuencia
  3. Por cada patrón en la secuencia:
     - Llama a pattern-executor
     - Pasa output del anterior como input del siguiente
  4. Devuelve resultado final

**Comando #3: exec**
- [x] Nombre del comando (sin /): **exec**
- [x] Descripción breve: **"Execute a specific Fabric pattern by name"**
- [x] ¿Qué argumentos acepta?: **[pattern_name] [user_prompt]**
- [x] ¿Hint para argumentos?: **"[pattern_name] [input_text]"**
- [x] ¿Qué herramientas necesita?: **[Task]**
- [x] Categoría del comando: **utility**
- [x] Nivel de complejidad: **basic**
- [x] ¿Requiere MCP servers específicos?: **No**
- [x] ¿Delega a un agente?: **Sí, pattern-executor**
- [x] Lógica de ejecución:
  1. Recibe nombre del patrón y prompt del usuario
  2. Delega al agente pattern-executor
  3. El agente extrae el patrón de pattern_extracts.json
  4. Aplica el patrón al input
  5. Devuelve resultado

---

### CATEGORÍA C: Agentes (Sub-agents)

**C.1 Decisiones Generales sobre Agentes**
- [x] ¿Cuántos agentes especializados necesita el plugin? **2 agentes: pattern-suggester y pattern-executor**
- [x] ¿Los agentes solo analizan/sugieren o también ejecutan? **Suggester solo analiza/sugiere, Executor ejecuta patrones**
- [x] ¿Necesitan acceso a archivos de datos específicos? **Sí, pattern_descriptions.json y pattern_extracts.json**
- [x] ¿Qué modelo deben usar por defecto? **inherit para suggester, sonnet para executor**

**C.2 Para Cada Agente Individual**

**Agente #1: pattern-suggester**
- [x] Nombre del agente (kebab-case): **pattern-suggester**
- [x] Descripción de cuándo invocarlo: **"Use when needing Fabric pattern suggestions based on user intent. Analyzes prompts semantically to identify appropriate patterns from the Fabric library."**
- [x] Modelo preferido: **inherit**
- [x] Color de terminal (opcional): **blue**
- [x] Capacidades principales:
  - Análisis semántico de prompts
  - Matching de patrones por tags y descripción
  - Identificación de intent, dominio, y requisitos
  - Recomendación de workflows de múltiples patrones
- [x] Responsabilidades core:
  1. Leer y analizar pattern_descriptions.json
  2. Analizar semánticamente el prompt del usuario
  3. Identificar patrones apropiados
  4. Generar recomendaciones de 3-5 patrones
  5. Sugerir secuencias para tareas complejas
- [x] Metodología de trabajo:
  1. Cargar pattern_descriptions.json
  2. Extraer intent del usuario (análisis, creación, extracción, etc.)
  3. Identificar dominio (development, security, writing, etc.)
  4. Match por tags y similitud semántica
  5. Devolver nombres de patrones con razones
- [x] Formato de salida esperado: **Lista de nombres de patrones con explicación breve**
- [x] ¿Qué NO debe hacer? (restricciones):
  - ❌ NO ejecutar patrones
  - ❌ NO crear archivos
  - ❌ NO generar contenido
  - ✅ SOLO sugerir nombres de patrones

**Agente #2: pattern-executor**
- [x] Nombre del agente (kebab-case): **pattern-executor**
- [x] Descripción de cuándo invocarlo: **"Execute specific Fabric patterns with high-quality analysis. Extracts pattern from library and applies it to user input."**
- [x] Modelo preferido: **sonnet**
- [x] Color de terminal (opcional): **green**
- [x] Capacidades principales:
  - Extracción de patrones del catálogo
  - Ejecución de patrones de Fabric
  - Análisis de alta calidad con modelo Sonnet
  - Procesamiento de diversos tipos de input
- [x] Responsabilidades core:
  1. Recibir nombre de patrón e input del usuario
  2. Extraer patrón usando jq de pattern_extracts.json
  3. Aplicar el patrón al input proporcionado
  4. Generar análisis detallado y de calidad
  5. Devolver resultado formateado
- [x] Metodología de trabajo:
  1. Validar que el patrón existe en pattern_extracts.json
  2. Extraer con: `jq -r '.patterns[] | select(.patternName=="PATTERN") | .pattern_extract'`
  3. Aplicar el prompt del patrón al input del usuario
  4. Ejecutar con modelo Sonnet para calidad
  5. Devolver resultado estructurado
- [x] Formato de salida esperado: **Resultado del patrón aplicado, formato según cada patrón**
- [x] ¿Qué NO debe hacer? (restricciones):
  - ❌ NO sugerir patrones (eso es del suggester)
  - ❌ NO modificar los patrones originales
  - ✅ SOLO ejecutar el patrón solicitado

---

### CATEGORÍA D: Hooks (Automatización)

**D.1 Decisiones Generales sobre Hooks**
- [x] ¿El plugin necesita hooks automáticos? **No, sin hooks por ahora**

---

### CATEGORÍA E: Archivos Core y Datos

**E.1 Archivos de Datos**
- [x] ¿El plugin necesita archivos JSON de datos? **Sí, archivos de patrones de Fabric**
- [x] ¿Qué tipo de datos almacenará?:
  - **pattern_descriptions.json**: Catálogo de patrones con nombre, descripción y tags
  - **pattern_extracts.json**: Prompts completos de cada patrón para ejecución
- [x] ¿Estructura de los archivos? (schema):
  ```json
  // pattern_descriptions.json
  {
    "patterns": [
      {
        "patternName": "nombre",
        "description": "descripción",
        "tags": ["TAG1", "TAG2"]
      }
    ]
  }

  // pattern_extracts.json
  {
    "patterns": [
      {
        "patternName": "nombre",
        "pattern_extract": "prompt completo del patrón..."
      }
    ]
  }
  ```
- [x] ¿Ubicación de los archivos?: **.fabric-core/** (en la raíz del plugin)
- [x] ¿Cómo se referencian?: **Rutas relativas desde raíz del plugin** (`.fabric-core/pattern_descriptions.json`)
- [x] ¿Origen de los datos?: **Copiar desde /home/rcalleja/projects/ccfabric/.ccfabric-core/**
- [x] ¿Se actualizan?: **Estáticos en el plugin, se incluyen en la instalación**

**E.2 Scripts y Recursos**
- [x] ¿Necesita scripts auxiliares?: **No, por ahora**
- [ ] Scripts futuros posibles:
  - Script para actualizar pattern files desde Fabric oficial
  - Script de validación de JSON

---

### CATEGORÍA F: Configuración y Permisos

**F.1 MCP Server Permissions**
- [x] ¿Qué MCP servers necesita el plugin? **Ninguno**
- [x] Lista de MCP servers: **N/A - Solo herramientas nativas**

**F.2 Tool Permissions**
- [x] ¿Qué tools nativos necesita acceso?:
  - [x] **Task** - Para invocar sub-agents (suggester y executor)
  - [x] **Read** - Para leer pattern_descriptions.json y pattern_extracts.json
  - [x] **Write** - Disponible para casos donde sea necesario
  - [x] **Edit** - Disponible para casos donde sea necesario
  - [x] **Bash** - Para ejecutar comandos (jq si es necesario)
  - [x] **TodoWrite** - Para orchestrate comando (tracking de workflow)
  - [x] **Grep** - Para búsquedas en archivos
  - [x] **Glob** - Para búsqueda de archivos

**F.3 Settings Específicos**
- [x] ¿Configuraciones especiales del plugin?: **No, configuración estándar**
- [x] ¿Variables de entorno necesarias?: **No**
- [x] ¿Paths personalizados?: **No, usa rutas relativas estándar**

---

### CATEGORÍA G: Estructura de Archivos

**G.1 Organización**
- [x] ¿Usar estructura nueva (.claude-plugin/) o legacy (.claude/)? **Estructura nueva (plugin marketplace)**
- [x] Estructura del plugin:
  ```
  /plugins/fabric-helper/
  ├── .claude-plugin/
  │   └── plugin.json              # Manifest del plugin
  ├── commands/
  │   ├── suggest.md               # Comando suggest
  │   ├── orchestrate.md           # Comando orchestrate
  │   └── exec.md                  # Comando exec
  ├── agents/
  │   ├── pattern-suggester.md     # Agente suggester
  │   └── pattern-executor.md      # Agente executor
  ├── .fabric-core/
  │   ├── pattern_descriptions.json # Catálogo de patrones
  │   └── pattern_extracts.json     # Prompts de patrones
  ├── README.md                     # Documentación
  └── LICENSE                       # MIT License
  ```

**G.2 Documentación**
- [x] ¿Incluir README completo? **Sí**
- [x] ¿Ejemplos de uso? **Sí, con ejemplos de cada comando**
- [x] ¿Troubleshooting section? **Sí, sección básica**
- [x] ¿Changelog? **No inicialmente, agregar en futuras versiones**

---

### CATEGORÍA H: Casos de Uso y Flujos

**H.1 Flujos de Trabajo Principales**

**Flujo #1: Sugerencia y ejecución simple**
- **Descripción**: Usuario no sabe qué patrón usar, pide sugerencias y luego ejecuta uno
- **Comandos involucrados**: suggest → exec
- **Agentes involucrados**: pattern-suggester → pattern-executor
- **Entrada esperada**: Descripción en lenguaje natural de la tarea
- **Salida esperada**: Análisis completo según el patrón seleccionado
- **Ejemplo**:
  ```
  /suggest "I need to review this code for security issues"
  → Suggester recomienda: review_code, analyze_security, extract_vulnerabilities

  /exec analyze_security "[código aquí]"
  → Executor aplica el patrón y devuelve análisis de seguridad
  ```

**Flujo #2: Orquestación de workflow completo**
- **Descripción**: Usuario necesita un workflow completo de múltiples patrones encadenados
- **Comandos involucrados**: orchestrate
- **Agentes involucrados**: pattern-suggester (planificación) + pattern-executor (ejecución múltiple)
- **Entrada esperada**: Descripción de workflow complejo
- **Salida esperada**: Resultado final después de aplicar secuencia de patrones
- **Ejemplo**:
  ```
  /orchestrate "Analyze this meeting transcript, extract action items, and create a summary report"
  → Suggester identifica: analyze_meeting → extract_tasks → create_summary
  → Executor aplica secuencia:
     1. analyze_meeting (transcript) → análisis
     2. extract_tasks (análisis) → lista de tareas
     3. create_summary (tareas) → reporte final
  → Devuelve: Reporte estructurado con resumen y tareas
  ```

**Flujo #3: Ejecución directa de patrón conocido**
- **Descripción**: Usuario conoce el patrón exacto que necesita
- **Comandos involucrados**: exec
- **Agentes involucrados**: pattern-executor
- **Entrada esperada**: Nombre del patrón + contenido a procesar
- **Salida esperada**: Resultado del patrón aplicado
- **Ejemplo**:
  ```
  /exec summarize "[long article text]"
  → Executor aplica patrón summarize directamente
  → Devuelve: Resumen conciso del artículo
  ```

**H.2 Casos de Uso Específicos**

**Caso de uso #1: Análisis de código**
- **Descripción del problema**: Desarrollador necesita revisar código para calidad y bugs
- **Solución que proporciona el plugin**: Sugiere y ejecuta patrones de análisis de código
- **Comando(s) a usar**: `/suggest "review this code" → /exec review_code`
- **Ejemplo de invocación**:
  ```
  /suggest "I need to review this TypeScript function for bugs and best practices"
  /exec review_code "function getData() { ... }"
  ```

**Caso de uso #2: Documentación y extracción**
- **Descripción del problema**: Usuario necesita documentar código o extraer información clave
- **Solución que proporciona el plugin**: Workflow de análisis → extracción → formato
- **Comando(s) a usar**: `/orchestrate`
- **Ejemplo de invocación**:
  ```
  /orchestrate "Extract the main ideas from this research paper and create documentation"
  ```

**Caso de uso #3: Transformación de contenido**
- **Descripción del problema**: Convertir contenido entre formatos (markdown, summaries, etc.)
- **Solución que proporciona el plugin**: Patrones de conversión y transformación
- **Comando(s) a usar**: `/exec convert_to_markdown` o `/exec create_summary`
- **Ejemplo de invocación**:
  ```
  /exec convert_to_markdown "[HTML content here]"
  /exec create_summary "[long document text]"
  ```

---

## ANÁLISIS DE PATRONES DEL PROYECTO ccfabric

### Patrones Identificados

**1. Patrón de Suggester + Executor**
```
Usuario → Comando suggest_pattern → Agent pattern-suggester → Respuesta con nombres
Usuario → Comando exec → Agent pattern-executor → Ejecución del patrón
```

**2. Patrón de Orquestación**
```
Usuario → Comando orchestrate_patterns →
  → Agent pattern-suggester (obtiene secuencia)
  → For each pattern:
    → Agent pattern-executor (ejecuta patrón)
    → Output → Input del siguiente
  → Resultado final
```

**3. Patrón de Ejecución Directa**
```
Usuario → Comando summarize →
  → jq extract de pattern_extracts.json
  → Aplicar patrón directamente
  → Respuesta
```

**4. Uso de Datos Externos**
- pattern_descriptions.json: Catálogo read-only de patrones
- pattern_extracts.json: Prompts completos de patrones
- Separación de datos y lógica

---

## DECISIONES DE IMPLEMENTACIÓN

### I.1 Estructura Elegida
- [ ] ¿Nueva (plugin marketplace) o legacy (.claude/)?
- [ ] Justificación:

### I.2 Tecnologías y Dependencias
- [ ] ¿Lenguajes de scripting? (bash/python/node):
- [ ] ¿Dependencias externas? (jq/curl/etc):
- [ ] ¿MCP servers requeridos?:

### I.3 Testing y Validación
- [ ] ¿Cómo se probará el plugin?:
- [ ] ¿Casos de prueba específicos?:
- [ ] ¿Comando de validación? (make validate):

---

---

## ✅ ELICITACIÓN COMPLETADA

**Estado**: Todas las categorías (A-H) completadas
**Fecha de finalización**: 2025-10-12

### Resumen de Decisiones

- **Plugin**: fabric-helper v1.0.0
- **Categoría**: development
- **Comandos**: 3 (suggest, orchestrate, exec)
- **Agentes**: 2 (pattern-suggester, pattern-executor)
- **Hooks**: Ninguno
- **Datos**: pattern_descriptions.json + pattern_extracts.json
- **MCP Servers**: Ninguno
- **Tools**: Todos los nativos (Task, Read, Write, Edit, Bash, TodoWrite, Grep, Glob)

---

## PRÓXIMOS PASOS - IMPLEMENTACIÓN

### Fase 1: Estructura Base
1. ✅ **Crear estructura de directorios**
   ```bash
   mkdir -p plugins/fabric-helper/.claude-plugin
   mkdir -p plugins/fabric-helper/commands
   mkdir -p plugins/fabric-helper/agents
   mkdir -p plugins/fabric-helper/.fabric-core
   ```

2. ✅ **Copiar archivos de datos**
   ```bash
   cp /home/rcalleja/projects/ccfabric/.ccfabric-core/*.json \
      plugins/fabric-helper/.fabric-core/
   ```

3. ✅ **Crear plugin.json**
   - Ubicación: `plugins/fabric-helper/.claude-plugin/plugin.json`
   - Con metadatos de Categoría A

### Fase 2: Comandos
4. ✅ **Implementar suggest.md**
   - Ubicación: `plugins/fabric-helper/commands/suggest.md`
   - Según especificaciones de Categoría B

5. ✅ **Implementar orchestrate.md**
   - Ubicación: `plugins/fabric-helper/commands/orchestrate.md`
   - Según especificaciones de Categoría B

6. ✅ **Implementar exec.md**
   - Ubicación: `plugins/fabric-helper/commands/exec.md`
   - Según especificaciones de Categoría B

### Fase 3: Agentes
7. ✅ **Implementar pattern-suggester.md**
   - Ubicación: `plugins/fabric-helper/agents/pattern-suggester.md`
   - Según especificaciones de Categoría C

8. ✅ **Implementar pattern-executor.md**
   - Ubicación: `plugins/fabric-helper/agents/pattern-executor.md`
   - Según especificaciones de Categoría C

### Fase 4: Documentación
9. ✅ **Crear README.md**
   - Descripción del plugin
   - Instalación
   - Ejemplos de uso (casos de uso H.1 y H.2)
   - Troubleshooting básico

10. ✅ **Crear LICENSE**
    - MIT License con autor Rafael Calleja

### Fase 5: Integración con Marketplace
11. ✅ **Actualizar marketplace.json**
    - Agregar entrada para fabric-helper
    - En: `.claude-plugin/marketplace.json`

12. ✅ **Validar plugin**
    ```bash
    make validate
    ```

13. ✅ **Probar localmente**
    ```bash
    make install
    # Luego en Claude Code:
    /suggest "test prompt"
    ```

### Fase 6: Testing
14. ✅ **Probar cada comando**
    - /suggest con diferentes prompts
    - /exec con diferentes patrones
    - /orchestrate con workflows complejos

15. ✅ **Verificar agentes**
    - pattern-suggester devuelve nombres correctos
    - pattern-executor ejecuta patrones correctamente

### Fase 7: Finalización
16. ✅ **Commit al repositorio**
    ```bash
    git add plugins/fabric-helper
    git commit -m "Add fabric-helper plugin"
    ```

17. ✅ **Actualizar documentación del marketplace**
    - Agregar fabric-helper a la lista de plugins en README.md principal

---

## NOTAS TÉCNICAS

### Comandos - Frontmatter YAML
```yaml
---
name: command_name
description: "Brief description"
argument-hint: [arg1] [arg2]
allowed-tools: [Task, Read, Write]
category: utility
complexity: basic
mcp-servers: []
---
```

### Agentes - Frontmatter YAML
```yaml
---
name: agent-name
description: When to invoke this agent...
model: inherit
color: blue
---
```

### Hooks - hooks.json
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/scripts/script.sh"
        }]
      }
    ]
  }
}
```

---

## REFERENCIAS

- **ccfabric estructura**: /home/rcalleja/projects/ccfabric/.claude/
- **Marketplace docs**: RESEARCH_REPORT.md, QUICK_REFERENCE.md
- **Claude Code docs**: https://docs.claude.com/en/docs/claude-code
- **Anthropic examples**: https://github.com/anthropics/claude-code

---

*Documento vivo - actualizar según avance la elicitación*
