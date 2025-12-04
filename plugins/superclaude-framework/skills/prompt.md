Necesito una descripción para una skill de Claude Code.

Contexto: Lee @[RUTA_ARCHIVO] y analiza su contenido para entender:
- Qué información proporciona
- Cuándo debería activarse (trigger pattern)
- Qué categorías de contenido cubre

Requisitos:
1. Identifica el QUÉ: qué proporciona la skill basándote en el contenido del archivo
2. Identifica el TRIGGER: bajo qué patrón observable en el prompt del usuario debe activarse (ejemplo: presencia de cierto formato, palabra clave, sintaxis específica)
3. Identifica las CATEGORÍAS: tipos de información que contiene (genérico, sin ejemplos concretos)
4. La descripción debe ser genérica y resistente a cambios futuros en el contenido
5. No menciones nombres propios, frameworks específicos, o elementos concretos del contenido - usa categorías funcionales amplias
6. Formato: una línea concisa para el campo "description" del YAML frontmatter
7. Longitud: ~150-200 caracteres máximo
8. El TRIGGER debe ser detectable automáticamente en el texto del usuario, no una "configuración" abstracta

Estructura requerida:
"Provides [QUÉ] when [TRIGGER] - describes [CATEGORÍAS GENÉRICAS]"

Nota: El TRIGGER debe ser algo que Claude pueda detectar en el prompt del usuario (ej: "when double-dash flags detected", "when code blocks present", "when URL patterns found")
