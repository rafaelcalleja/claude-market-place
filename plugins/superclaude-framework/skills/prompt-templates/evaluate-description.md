# Skill Description Evaluation Prompt Template

Use this prompt to evaluate and correct skill descriptions for Claude Code.

## Prompt Template

```
Evalúa esta descripción de skill de Claude Code y proporciona correcciones específicas:

DESCRIPCIÓN A EVALUAR:
"""
[PEGAR DESCRIPCIÓN AQUÍ]
"""

CRITERIOS DE EVALUACIÓN:

1. ESTRUCTURA REQUERIDA:
   ✅ Debe comenzar con "Provides [QUÉ]"
   ✅ Debe incluir "when [TRIGGER]"
   ✅ Debe terminar con "- describes/covers [CATEGORÍAS]"

2. TRIGGER (CRÍTICO):
   ✅ Debe ser DETECTABLE en el texto del usuario
   ✅ NO subjetivo ("when needed", "when appropriate")
   ✅ Debe especificar QUÉ buscar (keywords, patterns, syntax)

   Ejemplos VÁLIDOS:
   - "when double-dash flags (--flag) detected"
   - "when keywords present (list, examples)"
   - "when @filename mentioned"

   Ejemplos INVÁLIDOS:
   - "when guidance needed"
   - "when complex scenarios"
   - "when appropriate"

3. CONTENIDO:
   ✅ Genérico (sin nombres propios de frameworks)
   ✅ Categorías funcionales amplias
   ✅ Plural consistente (standards, patterns, modes)
   ✅ Longitud: 150-220 caracteres

4. CLARIDAD:
   ✅ Sin ambigüedad
   ✅ Observable/medible
   ✅ Future-proof

FORMATO DE RESPUESTA:

## Evaluación:
[Análisis de qué está bien y qué falla]

## Problemas detectados:
- [ ] Problema 1: [descripción]
- [ ] Problema 2: [descripción]

## Correcciones sugeridas:

### Versión corregida (cambios mínimos):
```
[versión con correcciones mínimas]
```

### Versión optimizada (mejoras opcionales):
```
[versión mejorada manteniendo la esencia]
```

## Explicación de cambios:
1. [Cambio 1]
   - Por qué: [razón]
   - Impacto: [efecto]
2. [Cambio 2]
   - Por qué: [razón]
   - Impacto: [efecto]

## Recomendación:
[Cuál versión usar y por qué]
```

## Ejemplo de Uso

```
Evalúa esta descripción de skill de Claude Code y proporciona correcciones específicas:

DESCRIPCIÓN A EVALUAR:
"""
Software engineering principles and decision frameworks when architectural guidance keywords detected (SOLID, patterns, trade-offs, quality) - covers design philosophy, risk management, and quality standard
"""

[... resto del prompt ...]
```

## Resultado Esperado

```
## Evaluación:
✅ Trigger detectable presente
✅ Keywords específicos listados
❌ Falta "Provides" al inicio
❌ "standard" debería ser "standards"

## Problemas detectados:
- [x] Falta "Provides" al inicio (estructura requerida)
- [x] Singular "standard" inconsistente con resto de plurales

## Correcciones sugeridas:

### Versión corregida (cambios mínimos):
Provides software engineering principles and decision frameworks when architectural guidance keywords detected (SOLID, patterns, trade-offs, quality) - covers design philosophy, risk management, and quality standards

Longitud: 213 caracteres ✅

### Versión optimizada (mejoras opcionales):
Provides engineering principles and decision frameworks when architecture keywords detected (SOLID, patterns, trade-offs, quality, design) - covers design philosophy, risk assessment, and quality standards

Longitud: 207 caracteres ✅

## Explicación de cambios:
1. Añadido "Provides" al inicio
   - Por qué: Cumplir con estructura requerida "Provides [QUÉ]"
   - Impacto: Claridad y consistencia con formato de skills
2. Corregido "standard" → "standards"
   - Por qué: Consistencia de plural con "principles", "frameworks", "patterns"
   - Impacto: Gramática correcta y paralelismo estructural

## Recomendación:
Usar la versión corregida si se prefiere conservar exactamente el contenido original, o la versión optimizada para mayor concisión y cobertura de triggers.
```

## Características de una Buena Evaluación

- ✅ Identifica todos los problemas estructurales
- ✅ Proporciona dos versiones (mínima y optimizada)
- ✅ Explica cada cambio con razón e impacto
- ✅ Incluye métricas (longitud de caracteres)
- ✅ Da recomendación final clara
- ✅ Mantiene el espíritu de la descripción original