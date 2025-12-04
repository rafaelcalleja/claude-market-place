# Skill Description Generation Prompt Template

Use this prompt to generate skill descriptions that follow Claude Code conventions.

## Prompt Template

```
Necesito una descripción para una skill de Claude Code.

Contexto: Lee @[RUTA_ARCHIVO] y analiza su contenido para entender:
- Qué información proporciona
- Cuándo debería activarse (trigger pattern)
- Qué categorías de contenido cubre

Requisitos:
1. Identifica el QUÉ: qué proporciona la skill basándote en el contenido del archivo
2. Identifica el TRIGGER: Debe ser un patrón DETECTABLE y OBSERVABLE en el prompt del usuario. Ejemplos VÁLIDOS:
   - "when double-dash flags (--flag) detected"
   - "when @filename mentioned"
   - "when specific keywords present (list keywords)"
   - "when code patterns match X syntax"
   Ejemplos INVÁLIDOS (no uses estos):
   - "when guidance needed" (subjetivo, no detectable)
   - "when appropriate" (ambiguo)
   - "when complex problems arise" (interpretativo)
3. Identifica las CATEGORÍAS: tipos de información que contiene (genérico, sin ejemplos concretos)
4. La descripción debe ser genérica y resistente a cambios futuros en el contenido
5. No menciones nombres propios, frameworks específicos, o elementos concretos del contenido - usa categorías funcionales amplias
6. Formato: una línea concisa para el campo "description" del YAML frontmatter
7. Longitud: ~150-200 caracteres máximo
8. El TRIGGER debe ser algo que Claude pueda detectar AUTOMÁTICAMENTE sin interpretación subjetiva

Estructura requerida:
"Provides [QUÉ] when [TRIGGER DETECTABLE] - describes/covers [CATEGORÍAS GENÉRICAS]"

CRÍTICO: El TRIGGER debe responder a "¿Qué patrón literal/sintáctico en el texto del usuario activa esto?"
No debe ser "cuando se necesita" sino "cuando aparece X en el prompt"
```

## Ejemplo de Uso

```
Necesito una descripción para una skill de Claude Code.

Contexto: Lee @plugins/superclaude-framework/core/FLAGS.md y analiza su contenido para entender:
- Qué información proporciona
- Cuándo debería activarse (trigger pattern)
- Qué categorías de contenido cubre

[... resto del prompt ...]
```

## Resultado Esperado

```
Provides execution mode configuration and tool selection patterns when double-dash flags detected - describes operational modes, service integration, analysis depth, execution control, and output optimization
```

## Características del Resultado Ideal

- ✅ Comienza con "Provides"
- ✅ Trigger detectable y específico
- ✅ Sin nombres propios o frameworks específicos
- ✅ Categorías genéricas y funcionales
- ✅ Longitud apropiada (150-220 caracteres)
- ✅ Future-proof (resistente a cambios en el contenido)