# Glob Patterns Reference

## Common Patterns

| Pattern | Matches |
|---------|---------|
| `**/*.ts` | All TypeScript files in any directory |
| `src/**/*` | All files under `src/` directory |
| `*.md` | Markdown files in the project root only |
| `src/components/*.tsx` | React components in a specific directory |
| `**/*.{ts,tsx}` | All TypeScript and TSX files |
| `{src,lib}/**/*.ts` | TypeScript files in src/ or lib/ |

## Brace Expansion

Use braces `{}` to match multiple patterns:

```
src/**/*.{ts,tsx}     -> src/**/*.ts AND src/**/*.tsx
{src,lib}/**/*.ts     -> src/**/*.ts AND lib/**/*.ts
**/*.{js,jsx,ts,tsx}  -> All JS/TS files
```

## Combining Patterns

Use commas to combine multiple distinct patterns:

```
src/**/*.ts, tests/**/*.test.ts
```

## Common Use Cases

### Frontend Rules
```yaml
paths: src/**/*.{ts,tsx,css,scss}
```

### Backend Rules
```yaml
paths: src/api/**/*.ts, src/services/**/*.ts
```

### Test Files Only
```yaml
paths: **/*.{test,spec}.{ts,tsx,js,jsx}
```

### Configuration Files
```yaml
paths: "*.config.{js,ts,json}"
```

### Documentation
```yaml
paths: "**/*.md, docs/**/*"
```
