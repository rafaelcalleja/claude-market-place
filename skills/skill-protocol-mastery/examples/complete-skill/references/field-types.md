# PDF Form Field Types

Reference for supported PDF form field types and their properties.

## Text Fields

Standard text input fields.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| type | "text" | Field type identifier |
| value | string | Text content to fill |
| maxLength | number | Maximum characters (optional) |
| multiline | boolean | Allow multiple lines |

### Example

```json
{
  "customer_name": {
    "type": "text",
    "value": "John Doe"
  },
  "address": {
    "type": "text",
    "value": "123 Main St\nApt 4B",
    "multiline": true
  }
}
```

## Checkbox Fields

Boolean selection fields.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| type | "checkbox" | Field type identifier |
| checked | boolean | Whether box is checked |

### Example

```json
{
  "agree_terms": {
    "type": "checkbox",
    "checked": true
  },
  "subscribe_newsletter": {
    "type": "checkbox",
    "checked": false
  }
}
```

## Dropdown Fields

Selection from predefined options.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| type | "dropdown" | Field type identifier |
| selected | string | Selected option value |
| options | array | Available options (read-only) |

### Example

```json
{
  "country": {
    "type": "dropdown",
    "selected": "USA",
    "options": ["USA", "Canada", "Mexico"]
  }
}
```

## Signature Fields

Digital signature placeholders.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| type | "signature" | Field type identifier |
| image | string | Path to signature image (optional) |

### Example

```json
{
  "customer_signature": {
    "type": "signature",
    "image": "signatures/john_doe.png"
  }
}
```

## Common Properties

Properties available on all field types.

| Property | Type | Description |
|----------|------|-------------|
| page | number | Page number (1-indexed) |
| x | number | X coordinate on page |
| y | number | Y coordinate on page |
| width | number | Field width |
| height | number | Field height |
| readonly | boolean | Prevent modification |
| required | boolean | Must have value |

## Field Discovery

Use `analyze_form.py` to discover fields:

```bash
python scripts/analyze_form.py form.pdf
```

Output includes:
- Field names
- Field types
- Positions (x, y, width, height)
- Page numbers
