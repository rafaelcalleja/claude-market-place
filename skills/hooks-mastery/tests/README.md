# Hooks Mastery - Test Suite

Suite de tests automatizada para validar los scripts del skill hooks-mastery.

## Ejecutar Tests

```bash
# Desde el directorio del skill
./tests/run-tests.sh

# Con output detallado
./tests/run-tests.sh --verbose
```

## Estructura de Tests

```
tests/
├── run-tests.sh              # Script principal de tests
├── README.md                  # Este archivo
│
├── fixtures/                  # Archivos de configuración de prueba
│   ├── valid/                # Configs que deben PASAR validación
│   │   ├── minimal-hooks.json
│   │   ├── all-events.json
│   │   ├── prompt-hooks.json
│   │   ├── regex-matchers.json
│   │   └── multiple-hooks.json
│   │
│   └── invalid/              # Configs que deben FALLAR validación
│       ├── invalid-event-name.json
│       ├── invalid-type.json
│       ├── missing-type.json
│       ├── missing-command.json
│       ├── missing-prompt.json
│       ├── hooks-not-array.json
│       ├── extra-properties.json
│       ├── negative-timeout.json
│       └── invalid-json.json
│
├── hooks/                    # Hooks de prueba para test-hook-io.py
│   ├── pass/                # Hooks que deben ejecutar con éxito
│   │   ├── exit-0-success.py
│   │   ├── json-allow-decision.py
│   │   ├── json-with-context.py
│   │   └── plain-text-context.py
│   │
│   └── fail/                # Hooks que deben fallar o bloquear
│       ├── exit-2-block.py
│       ├── exit-1-error.py
│       ├── json-deny-decision.py
│       ├── json-block-decision.py
│       └── timeout-hook.py
│
└── expected/                 # Outputs esperados (para referencia)
```

## Categorías de Tests

### 1. Dependencias (2 tests)
- Verifica que python3 está disponible
- Verifica que jsonschema está instalado

### 2. validate-hook-config.py - Valid Configs (5 tests)
Valida que configuraciones válidas pasan:
- `minimal-hooks.json` - Configuración mínima
- `all-events.json` - Todos los eventos soportados
- `prompt-hooks.json` - Hooks basados en prompts
- `regex-matchers.json` - Patrones regex y MCP
- `multiple-hooks.json` - Múltiples hooks por evento

### 3. validate-hook-config.py - Invalid Configs (9 tests)
Valida que configuraciones inválidas son rechazadas:
- `invalid-event-name.json` - Nombre de evento no válido
- `invalid-type.json` - Tipo de hook no válido
- `missing-type.json` - Falta campo type
- `missing-command.json` - Falta command en hook command
- `missing-prompt.json` - Falta prompt en hook prompt
- `hooks-not-array.json` - Hooks no es array
- `extra-properties.json` - Propiedades adicionales no permitidas
- `negative-timeout.json` - Timeout negativo
- `invalid-json.json` - JSON malformado

### 4. test-hook-io.py - Passing Hooks (4 tests)
Hooks que deben ejecutar con exit code 0:
- `exit-0-success.py` - Exit simple
- `json-allow-decision.py` - JSON con decisión allow
- `json-with-context.py` - JSON con contexto adicional
- `plain-text-context.py` - Texto plano para contexto

### 5. test-hook-io.py - Blocking Hooks (1 test)
- `exit-2-block.py` - Debe retornar exit code 2

### 6. test-hook-io.py - Non-Blocking Errors (1 test)
- `exit-1-error.py` - Debe retornar exit code 1

### 7. test-hook-io.py - JSON Output Detection (2 tests)
Verifica que JSON es detectado correctamente:
- `json-allow-decision.py`
- `json-with-context.py`

### 8. test-hook-io.py - Different Event Types (9 tests)
Prueba todos los tipos de eventos:
- PreToolUse
- PostToolUse
- Stop
- SubagentStop
- SessionStart
- SessionEnd
- UserPromptSubmit
- Notification
- PreCompact

### 9. generate-hook-template.sh - Python Templates (6 tests)
Genera y ejecuta templates Python para:
- PreToolUse
- PostToolUse
- Stop
- SessionStart
- UserPromptSubmit
- SessionEnd

### 10. generate-hook-template.sh - Bash Templates (3 tests)
Genera y ejecuta templates Bash para:
- PreToolUse
- SessionStart
- Stop

### 11. generate-hook-template.sh - Invalid Event Rejection (1 test)
- Verifica rechazo de evento inválido

## Total: 43 Tests

## Agregar Nuevos Tests

### Agregar fixture válido

1. Crear archivo en `fixtures/valid/`:
```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "Pattern",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/script"
          }
        ]
      }
    ]
  }
}
```

2. El test se incluirá automáticamente

### Agregar fixture inválido

1. Crear archivo en `fixtures/invalid/` con error intencional
2. El test verificará que es rechazado

### Agregar hook de prueba

1. Crear script en `hooks/pass/` o `hooks/fail/`
2. Hacerlo ejecutable: `chmod +x hook.py`
3. El test se incluirá automáticamente

## Output de Ejemplo

```
╔═══════════════════════════════════════════════════════════════════════════╗
║               HOOKS MASTERY - TEST SUITE                                  ║
╚═══════════════════════════════════════════════════════════════════════════╝

[INFO] Skill directory: /path/to/hooks-mastery
[INFO] Tests directory: /path/to/hooks-mastery/tests

═══════════════════════════════════════════════════════════════════════════
1. Checking Dependencies
═══════════════════════════════════════════════════════════════════════════
  ✓ PASS: python3 found
  ✓ PASS: jsonschema module available

═══════════════════════════════════════════════════════════════════════════
2. validate-hook-config.py - Valid Configs (should PASS)
═══════════════════════════════════════════════════════════════════════════
  ✓ PASS: all-events.json
  ✓ PASS: minimal-hooks.json
  ...

═══════════════════════════════════════════════════════════════════════════
TEST SUMMARY
═══════════════════════════════════════════════════════════════════════════

  Total Tests:  43
  Passed:       43
  Failed:       0

╔═══════════════════════════════════════════════════════════════════════════╗
║                     ✓ ALL TESTS PASSED!                                   ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

## Integración Continua

Para usar en CI/CD:

```yaml
# GitHub Actions
- name: Run hooks-mastery tests
  run: |
    cd hooks-mastery
    ./tests/run-tests.sh
```

```bash
# Script simple
cd hooks-mastery
./tests/run-tests.sh || echo "Tests failed!"
```

## Dependencias

- `python3` - Intérprete Python
- `jsonschema` - Librería de validación (se instala automáticamente)
- `bash` - Shell para run-tests.sh
- `jq` - Para templates bash (opcional)
