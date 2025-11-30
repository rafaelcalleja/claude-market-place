# Template Discovery Skill v0.3.0

Interactive guide for discovering and building GitLab CI/CD pipelines using to-be-continuous templates with **cross-component variant learning**.

## 🎯 What This Skill Does

This is a **conversational expert** (not a command) that helps you discover the right to-be-continuous templates for your project. It:

- ✅ Shows real configurations from GitLab
- ✅ Catalogs 70+ variants across 62 components
- ✅ **Learns from other components** when variant doesn't exist
- ✅ Suggests compatible template combinations
- ✅ Asks "what else do you need?" conversationally
- ✅ Links to working sample projects
- ✅ Provides adaptation guidance for missing variants
- ❌ **NEVER generates or modifies files** (read-only guide)

## 🚀 How to Use It

The skill **activates automatically** when you ask questions about templates:

### Natural Language Queries

```
"What templates exist for Python and Docker?"
"Show me semantic-release configuration"
"I need S3 deployment"
"How do I set up Kubernetes deployment?"
```

### Trigger Phrases

The skill activates on these keywords:
- to-be-continuous
- gitlab ci template
- semantic-release
- what templates
- pipeline template
- deployment template
- build template
- **template variants** ⭐ NEW
- **vault integration** ⭐ NEW
- **OIDC authentication** ⭐ NEW

### Example Conversation

```
You: "I need semantic release for my Node.js project"

Skill: ✅ Sí, tenemos semantic-release en to-be-continuous

📖 Configuración:
[Shows real config from GitLab...]

💬 ¿Necesitas algo más para tu pipeline?
- 🔐 Autenticación (npm registry)
- 🔒 Seguridad (Gitleaks)
- 🧪 Testing (Jest, Mocha)

You: "authentication for npm"

Skill: Perfecto! Para semantic-release + npm:
[Shows npm authentication setup...]

💬 ¿Algo más?
[Continues conversationally until you say "ya está"]
```

## 📚 What's Included

### 110+ Templates Catalog + 70+ Variants ⭐ NEW

- **62 main templates**: Python, Node.js, Maven, Docker, Kubernetes, etc.
- **70+ variants**: standard, -vault, -oidc, -gcp, -aws, -eks, -ecr
- **31 sample projects**: Real working examples
- **17 tools**: Utilities and helpers
- **Cross-component learning**: Adapt missing variants from other components

### References

- `catalog.md` - Complete list of all templates with URLs
- `categories.md` - Template categorization and compatibility matrix
- **`variantes.md`** ⭐ NEW - 70+ variants across all components
- `usage-guide.md` - Official to-be-continuous usage documentation
- `best-practices.md` - Architecture patterns and decision matrices
- `faq.md` - Common questions and answers

## 🔍 Philosophy

This skill follows **DETERMINISTIC ONLY** principle:

- ✅ Uses WebFetch to get real docs from GitLab
- ✅ Shows only actual configurations that exist
- ✅ Links to real sample projects
- ❌ NEVER invents examples or configurations
- ❌ NEVER makes up variable names

## 🛠️ When NOT to Use

This skill is for **discovery and guidance**, not execution:

- ❌ Don't use for: Creating .gitlab-ci.yml files
- ❌ Don't use for: Modifying existing pipelines
- ❌ Don't use for: Running validations

For those tasks, you'll need different commands (future: `/create-pipeline`, `/validate-pipeline`)

## 💡 Tips

- **Be specific**: "python docker kubernetes" better than "build deploy"
- **Ask naturally**: The skill understands conversational queries
- **Explore samples**: Ask "show me the pipeline for python-on-kubernetes"
- **Build incrementally**: Start with one template, add more as needed

## 📖 Learn More

- [to-be-continuous docs](https://to-be-continuous.gitlab.io/doc)
- [GitLab Group](https://gitlab.com/to-be-continuous)
- [Sample Projects](https://gitlab.com/to-be-continuous/samples)

---

**Remember**: This is a READ-ONLY guide. It teaches you what exists and how to configure it, but doesn't modify your project.