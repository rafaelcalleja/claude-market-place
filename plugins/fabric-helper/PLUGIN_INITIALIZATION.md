# Plugin Initialization System

## Overview

This plugin includes an automatic initialization system that expands `${CLAUDE_PLUGIN_ROOT}` variables in markdown files during the first Claude Code session.

**Why:** Claude Code slash commands don't currently resolve `${CLAUDE_PLUGIN_ROOT}` variables, but hooks do. This workaround ensures all markdown files contain absolute paths for slash commands to work correctly.

## How It Works

### 1. Automatic Version Detection

The script automatically detects plugin updates by comparing versions:
- Reads current version from `.claude-plugin/plugin.json`
- Compares with version stored in `.initialized` marker
- If versions differ → Re-initializes automatically
- If versions match → Skips silently

**No manual intervention needed when updating the plugin!**

### 2. SessionStart Hook

When Claude Code starts (not on resume/clear/compact), the `SessionStart` hook triggers:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/plugin-initializer.sh \"${CLAUDE_PLUGIN_ROOT}\""
          }
        ]
      }
    ]
  }
}
```

### 3. Initialization Script

The script (`scripts/plugin-initializer.sh`):

1. Reads plugin version from `plugin.json`
2. Checks `.initialized` marker file
3. Compares versions:
   - **Same version** → exits silently (no action needed)
   - **Different version** → re-initializes (automatic update)
   - **No marker** → initializes (first time)
4. Processing:
   - Finds all `.md` files in `agents/` and `commands/`
   - Replaces `${CLAUDE_PLUGIN_ROOT}` with absolute path
   - Replaces `$CLAUDE_PLUGIN_ROOT` with absolute path
   - Creates/updates `.initialized` marker with current version
   - Shows appropriate message (initialized vs re-initialized)

## Example Transformation

**Before initialization:**
```markdown
Extract the pattern from `${CLAUDE_PLUGIN_ROOT}/.fabric-core/pattern_extracts.json`
Use $CLAUDE_PLUGIN_ROOT/scripts/executor.py
```

**After initialization:**
```markdown
Extract the pattern from `/home/user/.claude/plugins/marketplaces/custom/fabric-helper/.fabric-core/pattern_extracts.json`
Use /home/user/.claude/plugins/marketplaces/custom/fabric-helper/scripts/executor.py
```

## Files Created

```
plugins/fabric-helper/
├── hooks/
│   └── hooks.json                        # SessionStart hook configuration
├── scripts/
│   └── plugin-initializer.sh             # Initialization script (executable)
├── .initialized                          # Marker file (created on first run)
└── PLUGIN_INITIALIZATION.md              # This documentation
```

## Usage

### First Time Setup

The plugin will initialize automatically on the first `claude` startup after installation. You'll see this message:

```
✓ Initialized fabric-helper plugin v1.0.9 (5 files processed). Restart Claude Code to load changes.
```

Simply restart Claude Code (exit and run `claude` again) for the changes to take effect.

### Plugin Updates

When you update the plugin to a new version, it will **automatically re-initialize** on the next startup:

```
✓ Re-initialized fabric-helper v1.1.0 (5 files updated). Restart Claude Code to load changes.
```

**No need to manually delete `.initialized`!** The script detects version changes automatically.

### Verify Initialization

```bash
# Check if initialized
cat plugins/fabric-helper/.initialized

# Expected output:
# Initialized at: 2025-10-13T06:59:45+00:00
# Files processed: 8
# Plugin root: /home/user/.claude/plugins/marketplaces/custom/fabric-helper
# Script version: 1.0.0
```

### Verify Variable Expansion

```bash
# Search for unexpanded variables (should return nothing after init)
grep -r 'CLAUDE_PLUGIN_ROOT' plugins/fabric-helper/commands/
grep -r 'CLAUDE_PLUGIN_ROOT' plugins/fabric-helper/agents/
```

### Force Re-initialization (for testing/debugging)

```bash
# Option 1: Remove marker file
rm -f plugins/fabric-helper/.initialized

# Option 2: Bump version in plugin.json
# (script will detect version change)

# Then restart Claude Code
claude
```

## Testing

### Manual Test

```bash
# Run initialization script manually
plugins/fabric-helper/scripts/plugin-initializer.sh "$(pwd)/plugins/fabric-helper"

# Check output
cat plugins/fabric-helper/.initialized
```

### Debug Mode

Start Claude Code with debug output to see hook execution:

```bash
claude --debug
```

Look for:
```
[DEBUG] Executing hooks for SessionStart:startup
[DEBUG] Hook command completed with status 0
```

### View Hook in Claude Code

```bash
# Inside Claude Code
/hooks
```

Should show the SessionStart hook for fabric-helper plugin.

## Troubleshooting

### Issue: Variables Not Expanded

**Check:**
1. Is `.initialized` present? `ls -la plugins/fabric-helper/.initialized`
2. Is script executable? `ls -l plugins/fabric-helper/scripts/plugin-initializer.sh`
3. Did hook execute? Run `claude --debug` and check logs

**Solution:**
```bash
rm -f plugins/fabric-helper/.initialized
chmod +x plugins/fabric-helper/scripts/plugin-initializer.sh
claude --debug
```

### Issue: Hook Not Running

**Check:**
1. Is `hooks.json` valid JSON? `jq . plugins/fabric-helper/hooks/hooks.json`
2. Is plugin installed? `/plugin list`

**Solution:**
```bash
# Validate hook configuration
/hooks

# Reinstall plugin
/plugin uninstall fabric-helper
/plugin install fabric-helper@your-marketplace
```

### Issue: Permission Denied

**Solution:**
```bash
chmod +x plugins/fabric-helper/scripts/plugin-initializer.sh
```

## Architecture

### Why This Workaround?

Claude Code currently has this behavior:
- **Hooks**: Variables like `${CLAUDE_PLUGIN_ROOT}` are expanded by shell
- **Slash Commands**: Variables are NOT expanded, treated as literal strings

### Alternative Approaches Considered

1. ❌ **Use relative paths** - Breaks when running from different directories
2. ❌ **Manual configuration** - Error-prone, not user-friendly
3. ✅ **SessionStart hook** - Automatic, one-time, transparent to user

### Future

When Claude Code adds variable resolution for slash commands, this workaround can be removed by:
1. Deleting `.initialized`
2. Reverting markdown files to use `${CLAUDE_PLUGIN_ROOT}`
3. Removing the SessionStart hook

## Security Notes

- Script only modifies `.md` files in `agents/` and `commands/`
- Creates temporary `.bak` files (auto-removed on success)
- Exits early if already initialized (idempotent)
- No external network calls
- No sensitive data handling

## Version History

### 1.0.2 (2025-10-13)
- **Automatic version detection**: No manual cleanup needed on plugin updates
- Reads version from `plugin.json` and compares with marker file
- Shows different messages for initialization vs re-initialization
- Automatically re-initializes when plugin version changes

### 1.0.1 (2025-10-13)
- Fixed JSON output to show systemMessage to user
- Changed counter increment to avoid set -e issues
- Improved user feedback during initialization

### 1.0.0 (2025-10-13)
- Initial implementation
- SessionStart hook with "startup" matcher
- Variable expansion for both `${CLAUDE_PLUGIN_ROOT}` and `$CLAUDE_PLUGIN_ROOT`
- Marker file to prevent re-initialization
- Automatic backup/restore on errors
