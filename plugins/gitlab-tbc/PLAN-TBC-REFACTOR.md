# Plan de Refactorización: gitlab-tbc Plugin

## Progreso

| Fase | Estado | Fecha |
|------|--------|-------|
| FASE 1: Crear Nueva Estructura | ✅ COMPLETADA | 2025-12-01 |
| FASE 2: Crear Comandos | ✅ COMPLETADA | 2025-12-01 |
| FASE 3: Actualizar Agent | ✅ COMPLETADA | 2025-12-01 |
| FASE 4: Testing | ⏳ PENDIENTE | - |
| FASE 5: Cleanup | ⏳ PENDIENTE | - |

---

## Objetivo

Refactorizar el plugin `gitlab-tbc` para seguir el patrón de arquitectura de **hookify**:
- 1 skill de conocimiento compartido (`building-with-tbc`)
- N comandos que usan esa skill (`/tbc`, `/tbc:wizard`, etc.)
- Agents para trabajo autónomo (`tbc-validator`)

## Estado Actual

### Estructura Existente
```
plugins/gitlab-tbc/
├── skills/
│   ├── tbc-kicker/           # FUNCIONA BIEN - NO TOCAR INICIALMENTE
│   │   ├── SKILL.md          # 360 líneas, workflow completo
│   │   ├── references/       # 4 archivos de templates
│   │   ├── schemas/          # 50 JSON schemas
│   │   ├── examples/         # 4 configs de ejemplo
│   │   └── scripts/          # validate-inputs.py
│   ├── template-discovery/   # A fusionar
│   ├── component-creator/    # A eliminar (absorber en comandos)
│   └── tbc-schema-updater/   # Mantener (utilidad)
├── agents/
│   └── tbc-validator.md      # Ya existe
└── commands/                 # Vacío actualmente
```

### Qué Funciona Bien en tbc-kicker
1. Genera `.gitlab-ci.yml` con formato correcto
2. Usa schemas JSON para validar inputs
3. Transforma nombres de variables (PYTHON_IMAGE → image)
4. Conoce los 50 templates y sus categorías
5. Sugiere configuraciones reales (no alucinaciones)

## Estructura Objetivo

```
plugins/gitlab-tbc/
├── skills/
│   ├── building-with-tbc/     # NUEVO - Conocimiento compartido
│   │   ├── SKILL.md           # Guía del ecosistema TBC
│   │   ├── references/        # Fusión de referencias
│   │   │   ├── templates-catalog.md
│   │   │   ├── build-templates.md
│   │   │   ├── deployment-templates.md
│   │   │   ├── analysis-templates.md
│   │   │   ├── variantes.md
│   │   │   └── presets.md
│   │   ├── schemas/           # 50 JSON schemas (mover)
│   │   ├── examples/          # Ejemplos de configs
│   │   └── scripts/
│   │       └── validate-inputs.py
│   └── tbc-schema-updater/    # Mantener (actualiza schemas)
├── commands/                   # NUEVO
│   ├── tbc.md                 # Router principal
│   ├── wizard.md              # /tbc:wizard (8 pasos)
│   ├── templates.md           # /tbc:templates (listar)
│   ├── validate.md            # /tbc:validate
│   └── help.md                # /tbc:help
└── agents/
    └── tbc-validator.md       # Ya existe (actualizar paths)
```

---

## Fases de Implementación

### FASE 1: Crear Nueva Estructura (Sin Tocar Existente) ✅ COMPLETADA

**Objetivo**: Crear `building-with-tbc` y comandos EN PARALELO a `tbc-kicker`.

**Resultado**:
- ✅ Directorio `skills/building-with-tbc/` creado
- ✅ SKILL.md creado (246 líneas)
- ✅ 7 archivos de referencias copiados
- ✅ 51 schemas JSON copiados
- ✅ 4 ejemplos copiados
- ✅ Script de validación copiado
- ✅ Directorio `commands/` creado

#### Paso 1.1: Crear directorio de la skill

```bash
mkdir -p plugins/gitlab-tbc/skills/building-with-tbc/{references,schemas,examples,scripts}
```

#### Paso 1.2: Crear SKILL.md de building-with-tbc

Crear `skills/building-with-tbc/SKILL.md` con esta estructura:

```yaml
---
name: building-with-tbc
description: This skill should be used when building GitLab CI/CD pipelines with
  the To-Be-Continuous framework. Load this skill to access accurate template
  specifications, variables, schemas, and configuration patterns. Required by
  TBC commands to generate valid configurations without hallucinations.
version: 1.0.0
---
```

**Contenido del body**:

1. **Overview del Ecosistema TBC**
   - Qué es TBC (62 proyectos, 8 categorías)
   - Kicker wizard concept
   - Modos de include (component, project, remote)

2. **Template Categories**
   - Tabla con las 8 categorías y conteo
   - Single vs Multiple selection por categoría

3. **Configuration Format**
   - Component mode syntax (recomendado)
   - Project mode syntax
   - Remote mode syntax
   - Input name transformation rules

4. **Template Configuration**
   - Variables: name, default, type, mandatory, secret, advanced
   - Features: enabled/disabled toggles
   - Variants: Vault, OIDC, cloud-specific

5. **Validation**
   - Cómo usar `scripts/validate-inputs.py`
   - Schemas disponibles en `schemas/`

6. **Reference Files**
   - Pointers a `references/*.md`
   - Pointers a `examples/*.yml`

**IMPORTANTE**: El body debe ser LEAN (~150-200 líneas). El contenido detallado
va en `references/`.

#### Paso 1.3: Copiar referencias

Copiar desde `tbc-kicker/references/` y `template-discovery/references/`:

```bash
# Desde tbc-kicker
cp skills/tbc-kicker/references/build-templates.md skills/building-with-tbc/references/
cp skills/tbc-kicker/references/deployment-templates.md skills/building-with-tbc/references/
cp skills/tbc-kicker/references/analysis-templates.md skills/building-with-tbc/references/
cp skills/tbc-kicker/references/presets.md skills/building-with-tbc/references/

# Desde template-discovery
cp skills/template-discovery/references/catalog.md skills/building-with-tbc/references/templates-catalog.md
cp skills/template-discovery/references/variantes.md skills/building-with-tbc/references/
cp skills/template-discovery/references/best-practices.md skills/building-with-tbc/references/
```

#### Paso 1.4: Copiar schemas y scripts

```bash
# Schemas (50 archivos JSON)
cp -r skills/tbc-kicker/schemas/* skills/building-with-tbc/schemas/

# Scripts
cp skills/tbc-kicker/scripts/validate-inputs.py skills/building-with-tbc/scripts/

# Examples
cp -r skills/tbc-kicker/examples/* skills/building-with-tbc/examples/
```

#### Paso 1.5: Crear directorio de comandos

```bash
mkdir -p plugins/gitlab-tbc/commands
```

---

### FASE 2: Crear Comandos ✅ COMPLETADA

**Resultado**:
| Comando | Archivo | Líneas |
|---------|---------|--------|
| `/tbc` | commands/tbc.md | 302 |
| `/tbc:wizard` | commands/wizard.md | 401 |
| `/tbc:templates` | commands/templates.md | 301 |
| `/tbc:validate` | commands/validate.md | 355 |
| `/tbc:help` | commands/help.md | 489 |
| **Total** | 5 archivos | **1,848** |

#### Paso 2.1: Crear comando principal /tbc

Crear `commands/tbc.md`:

```yaml
---
description: Generate GitLab CI/CD configurations using To-Be-Continuous framework
argument-hint: Optional description of what you want to build
allowed-tools: ["Read", "Write", "Glob", "Grep", "AskUserQuestion", "Task", "Skill"]
---
```

**Contenido del body**:

1. **Load skill first**: `**Load building-with-tbc skill** using Skill tool`

2. **Intent Classification**:
   ```
   Analyze user request:
   - "create/generate/new/setup" → GENERATE flow (new project)
   - "migrate/convert/upgrade/existing" → MIGRATE flow
   - "what/explain/list/compare" → CONSULT flow
   ```

3. **GENERATE Flow** (equivalente a tbc-kicker):
   - Ask about project type, language, deployment
   - Configure global options
   - Select templates per category
   - Read schemas for validation
   - Configure variables
   - Generate `.gitlab-ci.yml`
   - Invoke tbc-validator agent before showing output

4. **MIGRATE Flow**:
   - Analyze existing `.gitlab-ci.yml`
   - Identify equivalent TBC templates
   - Suggest migration plan
   - Generate TBC version

5. **CONSULT Flow**:
   - Read relevant references
   - Answer questions about templates/variables
   - Show examples

6. **Validation Rule**:
   ```
   CRITICAL: Before presenting ANY TBC configuration that YOU generate,
   invoke the tbc-validator agent. Never show unvalidated output.
   ```

#### Paso 2.2: Crear comando /tbc:wizard

Crear `commands/wizard.md`:

```yaml
---
description: Guided 8-step wizard to generate GitLab CI/CD configuration
allowed-tools: ["Read", "AskUserQuestion", "Skill", "Task"]
---
```

**Contenido**: El flujo de 8 pasos del wizard original de kicker:
1. Configure Global Options
2. Build (Language)
3. Code Analysis
4. Packaging
5. Infrastructure
6. Deployment
7. Acceptance Tests
8. Generate Configuration

Cada paso usa AskUserQuestion para selección interactiva.

#### Paso 2.3: Crear comando /tbc:templates

Crear `commands/templates.md`:

```yaml
---
description: List available TBC templates and their categories
allowed-tools: ["Read", "Skill"]
---
```

**Contenido**:
- Load skill
- Read `references/templates-catalog.md`
- Show table of templates by category
- Allow filtering by category

#### Paso 2.4: Crear comando /tbc:validate

Crear `commands/validate.md`:

```yaml
---
description: Validate a TBC configuration against schemas
argument-hint: Path to .gitlab-ci.yml file
allowed-tools: ["Read", "Bash", "Skill"]
---
```

**Contenido**:
- Load skill
- Read provided config file
- Run `scripts/validate-inputs.py` on each template
- Report validation results

#### Paso 2.5: Crear comando /tbc:help

Crear `commands/help.md`:

```yaml
---
description: Get help with TBC plugin commands
allowed-tools: ["Read"]
---
```

**Contenido**: Similar a `/hookify:help`
- Overview del plugin
- Available commands
- Usage examples
- Troubleshooting

---

### FASE 3: Actualizar Agent tbc-validator ✅ COMPLETADA

**Resultado**:
- ✅ Path actualizado: `${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/scripts/validate-inputs.py`
- ✅ Documentación actualizada para referenciar nuevos comandos
- ✅ Mensajes de error actualizados

Actualizar `agents/tbc-validator.md`:

1. Cambiar path del script de validación:
   ```
   ${CLAUDE_PLUGIN_ROOT}/skills/building-with-tbc/scripts/validate-inputs.py
   ```

2. Actualizar descripción para mencionar los nuevos comandos

---

### FASE 4: Testing ⏳ PENDIENTE

#### Paso 4.1: Test de equivalencia

Probar que `/tbc` produce resultados equivalentes a usar `tbc-kicker` skill:

1. **Test 1**: "Genera pipeline para Python con Docker y Kubernetes"
   - Con tbc-kicker (actual)
   - Con /tbc (nuevo)
   - Comparar outputs

2. **Test 2**: "Configura CI/CD para Node.js con SonarQube"
   - Ambos métodos
   - Comparar

3. **Test 3**: Validación de variables
   - Usar schema incorrecto → debe fallar
   - Usar schema correcto → debe pasar

#### Paso 4.2: Test de comandos específicos

- `/tbc:wizard` - Ejecutar los 8 pasos
- `/tbc:templates` - Listar templates
- `/tbc:validate` - Validar config existente
- `/tbc:help` - Ver ayuda

---

### FASE 5: Cleanup (Solo después de validar) ⏳ PENDIENTE

**SOLO EJECUTAR DESPUÉS DE CONFIRMAR QUE TODO FUNCIONA**

#### Paso 5.1: Marcar skills obsoletas

Agregar a `tbc-kicker/SKILL.md`:
```yaml
---
name: TBC Kicker (DEPRECATED)
description: DEPRECATED - Use /tbc command instead. This skill...
---
```

Agregar a `template-discovery/SKILL.md`:
```yaml
---
name: Template Discovery (DEPRECATED)
description: DEPRECATED - Use /tbc:templates command instead...
---
```

#### Paso 5.2: Eliminar después de período de gracia

Después de 2-4 semanas sin problemas:
```bash
rm -rf skills/tbc-kicker
rm -rf skills/template-discovery
rm -rf skills/component-creator
```

---

## Checklist de Validación

### Fases 1-3 (Implementación):

- [x] `building-with-tbc` skill creada con SKILL.md lean (246 líneas)
- [x] Referencias copiadas y organizadas (7 archivos)
- [x] Schemas copiados (51 archivos)
- [x] Scripts copiados y paths actualizados
- [x] Comando `/tbc` creado con routing (302 líneas)
- [x] Comando `/tbc:wizard` creado con 8 pasos (401 líneas)
- [x] Comando `/tbc:templates` creado (301 líneas)
- [x] Comando `/tbc:validate` creado (355 líneas)
- [x] Comando `/tbc:help` creado (489 líneas)
- [x] Agent `tbc-validator` actualizado

### Fase 4 (Testing - PENDIENTE):

- [ ] Tests de equivalencia pasan
- [ ] `/tbc:wizard` ejecuta 8 pasos correctamente
- [ ] `/tbc:templates` lista templates correctamente
- [ ] `/tbc:validate` valida configs correctamente
- [ ] Documentación revisada

### Verificar que NO se perdió funcionalidad:

- [ ] Genera component mode syntax correctamente
- [ ] Transforma nombres de variables (PYTHON_IMAGE → image)
- [ ] Conoce las 8 categorías y selección correcta
- [ ] Lee schemas para sugerir variables válidas
- [ ] Muestra ejemplos de configuración
- [ ] Valida antes de mostrar output

---

## Notas Importantes

### Por qué seguir el patrón de hookify

1. **Separación clara**: Conocimiento (skill) vs Ejecución (commands)
2. **Punto de entrada único**: `/tbc` como router
3. **Subcomandos especializados**: `:wizard`, `:templates`, `:validate`
4. **Skill como "source of truth"**: Los comandos cargan la skill primero

### Riesgos y Mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Perder funcionalidad de kicker | No tocar kicker hasta probar nuevo |
| Romper validación | Mantener scripts idénticos |
| Confusión de usuarios | Período de deprecación gradual |
| Paths incorrectos | Usar ${CLAUDE_PLUGIN_ROOT} siempre |

### Patrón de carga de skill en comandos

Cada comando debe empezar con:
```markdown
**FIRST: Load the building-with-tbc skill** using the Skill tool to access
TBC specifications, schemas, and validation scripts.
```

---

## Timeline

| Fase | Planificado | Ejecutado |
|------|-------------|-----------|
| FASE 1 | Día 1-2 | ✅ 2025-12-01 |
| FASE 2 | Día 3-4 | ✅ 2025-12-01 |
| FASE 3 | Día 5 | ✅ 2025-12-01 |
| FASE 4 | Semana 2 | ⏳ Pendiente |
| FASE 5 | Semana 3+ | ⏳ Pendiente |

---

## Estructura Final Creada

```
plugins/gitlab-tbc/
├── skills/
│   ├── building-with-tbc/        # ✅ NUEVO
│   │   ├── SKILL.md              # 246 líneas
│   │   ├── references/           # 7 archivos
│   │   ├── schemas/              # 51 JSON
│   │   ├── examples/             # 4 configs
│   │   └── scripts/              # validate-inputs.py
│   ├── tbc-kicker/               # SIN CAMBIOS (deprecated pending)
│   ├── template-discovery/       # SIN CAMBIOS (deprecated pending)
│   ├── component-creator/        # SIN CAMBIOS (deprecated pending)
│   └── tbc-schema-updater/       # SIN CAMBIOS
├── commands/                      # ✅ NUEVO
│   ├── tbc.md                    # 302 líneas - router
│   ├── wizard.md                 # 401 líneas - 8 pasos
│   ├── templates.md              # 301 líneas - catálogo
│   ├── validate.md               # 355 líneas - validador
│   └── help.md                   # 489 líneas - documentación
└── agents/
    └── tbc-validator.md          # ✅ ACTUALIZADO
```

---

## Autor

Plan creado para ser ejecutado por cualquier LLM siguiendo las instrucciones
paso a paso.

- **Fecha creación**: 2025-12-01
- **Última actualización**: 2025-12-01
- **Versión**: 1.1.0
- **Estado**: Fases 1-3 completadas, pendiente testing