# Ubicacion de Archivos de Version

## Marketplace Central

```
.claude-plugin/marketplace.json
```

Estructura:
```json
{
  "plugins": [
    {
      "name": "nombre-plugin",
      "version": "X.Y.Z",  // <-- Actualizar aqui
      ...
    }
  ]
}
```

## Plugin Individual

```
plugins/{nombre-plugin}/.claude-plugin/plugin.json
```

Estructura:
```json
{
  "name": "nombre-plugin",
  "version": "X.Y.Z",  // <-- Actualizar aqui
  ...
}
```

## Plugins Disponibles

| Plugin | Ruta |
|--------|------|
| custom-hooks | `plugins/custom-hooks/.claude-plugin/plugin.json` |
| fabric-helper | `plugins/fabric-helper/.claude-plugin/plugin.json` |
| superclaude-framework | `plugins/superclaude-framework/.claude-plugin/plugin.json` |
| hook-workflow | `plugins/hook-workflow/.claude-plugin/plugin.json` |
| productivity-commands | `plugins/productivity-commands/.claude-plugin/plugin.json` |
| code-analysis-agents | `plugins/code-analysis-agents/.claude-plugin/plugin.json` |
| auto-formatter | `plugins/auto-formatter/.claude-plugin/plugin.json` |

## Checklist

- [ ] Actualizar version en marketplace.json
- [ ] Actualizar version en plugin.json del plugin
- [ ] Verificar que ambas versiones coincidan
