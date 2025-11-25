#!/usr/bin/env python3
"""
Hook para añadir recordatorio sobre AskUserQuestion a cada prompt.
Este hook se ejecuta cuando el usuario envía un prompt.
"""
import json
import sys

try:
    # Leer el JSON de entrada desde stdin
    input_data = json.load(sys.stdin)

    # Extraer el prompt del usuario (opcional, solo para validación)
    prompt = input_data.get("prompt", "")

    # Checklist de recordatorios
    reminder = """

Pregunta al usuario usando la tool AskUserQuestion para:
- [ ] Validar cualquier decision o supuesto
- [ ] Resolver dudas"""

    # Método simple: imprimir el recordatorio
    # Para UserPromptSubmit, el stdout con exit code 0 se añade como contexto
    print(reminder)

    # Exit code 0 = éxito, el stdout se añade al contexto
    sys.exit(0)

except json.JSONDecodeError as e:
    # Si hay error al leer el JSON, salir silenciosamente
    print(f"Error al leer JSON: {e}", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    # Cualquier otro error
    print(f"Error en hook: {e}", file=sys.stderr)
    sys.exit(1)