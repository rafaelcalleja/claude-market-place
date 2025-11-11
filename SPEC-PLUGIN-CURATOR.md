# Technical Specification: Plugin Curator & Marketplace Builder

**Version:** 1.0.0
**Created:** 2025-11-11
**Status:** Draft - For Implementation
**Based on:** [PRD-PLUGIN-CURATOR.md](docs/PRD-PLUGIN-CURATOR.md)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [System Architecture](#system-architecture)
3. [Component Specifications](#component-specifications)
4. [Data Models & Schemas](#data-models--schemas)
5. [API Specifications](#api-specifications)
6. [CLI Interface](#cli-interface)
7. [File System Layout](#file-system-layout)
8. [Algorithms & Logic](#algorithms--logic)
9. [Dependencies & Technology Stack](#dependencies--technology-stack)
10. [Performance Requirements](#performance-requirements)
11. [Security Specifications](#security-specifications)
12. [Testing Strategy](#testing-strategy)
13. [Error Handling](#error-handling)
14. [Implementation Roadmap](#implementation-roadmap)

---

## Executive Summary

### Purpose
This specification defines the technical implementation for a **Plugin Curator & Marketplace Builder** system that enables composition of new Claude Code plugins from existing components across multiple installed plugins.

### Scope
- **In Scope**: Discovery, indexing, curation, composition, versioning, validation, marketplace building
- **Out of Scope**: Runtime plugin hot-reloading, web-based UI, hosted marketplace service

### Key Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Runtime | Node.js 18+ | Matches Claude Code ecosystem |
| CLI Framework | Commander.js | Industry standard, extensible |
| TUI Framework | Ink (React for CLI) | Rich interactions, component-based |
| Schema Validation | Ajv + JSON Schema | Standards-compliant, fast |
| File Operations | fs-extra | Reliable, promise-based |
| Pattern Matching | fast-glob | Performance, cross-platform |
| Configuration | YAML (js-yaml) | Human-readable, comments |
| Hashing | Node crypto | Built-in, secure |
| Version Control | simple-git | Git integration |

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLI Layer                               │
│  (Commander.js + Ink TUI)                                       │
└────────────┬────────────────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────────────────┐
│                      Application Layer                          │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  Discovery  │  │  Curation   │  │ Marketplace │            │
│  │  Service    │  │  Service    │  │  Builder    │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  Indexer    │  │  Composer   │  │  Validator  │            │
│  │  Service    │  │  Service    │  │  Service    │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │ Dependency  │  │   Version   │  │  Conflict   │            │
│  │  Resolver   │  │   Tracker   │  │  Detector   │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└────────────┬────────────────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────────────────┐
│                        Data Layer                               │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  Component  │  │  Curation   │  │ Marketplace │            │
│  │   Index     │  │  Manifest   │  │  Manifest   │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   Plugin    │  │   Hooks     │  │     MCP     │            │
│  │  Manifests  │  │   Config    │  │   Config    │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└────────────┬────────────────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────────────────┐
│                     File System Layer                           │
│  ~/.claude/plugins, .claude/plugins, marketplaces              │
└─────────────────────────────────────────────────────────────────┘
```

### Module Dependency Graph

```
┌─────────────┐
│  CLI Entry  │
└──────┬──────┘
       │
       ├──────────┬─────────────┬──────────────┬────────────┐
       ▼          ▼             ▼              ▼            ▼
  ┌─────────┐ ┌─────────┐ ┌───────────┐ ┌──────────┐ ┌────────────┐
  │Discover │ │ Create  │ │Marketplace│ │Provenance│ │   Update   │
  │ Command │ │ Command │ │  Builder  │ │  Viewer  │ │   Manager  │
  └────┬────┘ └────┬────┘ └─────┬─────┘ └────┬─────┘ └──────┬─────┘
       │           │            │            │              │
       ├───────────┴────────────┴────────────┴──────────────┤
       ▼                                                     ▼
  ┌─────────────────────────────────────────────────────────────┐
  │                    Core Services Layer                       │
  │                                                              │
  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
  │  │ Indexer  │  │ Curator  │  │Composer  │  │Validator │   │
  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
  │       │             │             │             │          │
  │       └─────────────┴─────────────┴─────────────┘          │
  │                          ▼                                  │
  │       ┌──────────────────────────────────────┐             │
  │       │        Utility Services              │             │
  │       │  • DependencyResolver                │             │
  │       │  • ConflictDetector                  │             │
  │       │  • VersionTracker                    │             │
  │       │  • FileOperations                    │             │
  │       │  • SchemaValidator                   │             │
  │       └──────────────────────────────────────┘             │
  └─────────────────────────────────────────────────────────────┘
```

---

## Component Specifications

### 1. Discovery Service

**Responsibility:** Scan file system and remote repositories for Claude Code plugins and marketplaces.

> **📚 See Also:** [CLARIFICATION-DISCOVERY-SERVICE.md](docs/CLARIFICATION-DISCOVERY-SERVICE.md) for complete architecture details, remote repository support, and marketplace vs plugin distinction.

#### Key Concepts

- **Plugin**: Individual unit of functionality with `.claude-plugin/plugin.json`
- **Marketplace**: Catalog/index of plugins with `.claude-plugin/marketplace.json`
- **Discovery Source**: Location to search for plugins (directories, local/remote marketplaces)

#### Interface
```typescript
interface DiscoveryService {
  /**
   * Discover all plugins from configured sources
   */
  discoverAll(): Promise<DiscoveryResult>;

  /**
   * Discover plugins from specific source
   */
  discoverFrom(source: DiscoverySource): Promise<DiscoveredPlugin[]>;

  /**
   * Discover marketplaces (local and remote)
   */
  discoverMarketplaces(): Promise<DiscoveredMarketplace[]>;

  /**
   * Clone and discover remote marketplace
   */
  discoverRemoteMarketplace(url: string): Promise<DiscoveredMarketplace>;

  /**
   * Get configured discovery sources
   */
  getDiscoverySources(): DiscoverySource[];

  /**
   * Resolve conflicts when same plugin appears in multiple sources
   */
  resolvePluginConflicts(plugins: DiscoveredPlugin[]): DiscoveredPlugin[];
}

/**
 * A discovery source (where to look for plugins)
 */
interface DiscoverySource {
  type: 'directory' | 'marketplace-local' | 'marketplace-remote';
  path: string;                    // Local path or URL
  priority: number;                // For conflict resolution
}

/**
 * A discovered plugin with metadata
 */
interface DiscoveredPlugin {
  // Identification
  id: string;                      // Unique name (e.g., "superclaude-framework")
  name: string;
  version: string;

  // Location
  path: string;                    // Absolute path to plugin directory
  sourceType: 'user' | 'project' | 'marketplace';
  sourcePath: string;              // Source origin path

  // Metadata
  manifest: PluginManifest;
  marketplace?: string;            // Marketplace name (if from marketplace)

  // Tracking
  discovered: Date;
  hash?: string;                   // Directory hash for change detection
}

/**
 * A discovered marketplace
 */
interface DiscoveredMarketplace {
  // Identification
  name: string;

  // Location
  path: string;                    // Local path to marketplace
  isRemote: boolean;               // If cloned from remote
  remoteUrl?: string;              // Original URL (if remote)

  // Metadata
  manifest: MarketplaceManifest;
  plugins: MarketplacePluginRef[]; // Plugin references

  // Tracking
  discovered: Date;
  lastUpdated?: Date;              // Last update (for remote)
}

/**
 * Plugin reference in marketplace
 */
interface MarketplacePluginRef {
  name: string;
  source: string;                  // Relative or absolute path
  version?: string;
  description?: string;
}

/**
 * Discovery result
 */
interface DiscoveryResult {
  sources: DiscoverySource[];
  marketplaces: DiscoveredMarketplace[];
  plugins: DiscoveredPlugin[];     // Already deduplicated

  stats: {
    totalPluginsFound: number;
    duplicatesResolved: number;
    marketplacesScanned: number;
    directPlugins: number;
    marketplacePlugins: number;
  };

  warnings: Warning[];
  errors: Error[];
}
```

#### Implementation Details

> **💡 Note:** See [CLARIFICATION-DISCOVERY-SERVICE.md](docs/CLARIFICATION-DISCOVERY-SERVICE.md) for complete implementation with remote marketplace support.

```typescript
class DiscoveryServiceImpl implements DiscoveryService {
  private readonly config: DiscoveryConfig;
  private readonly gitClient: GitClient;
  private readonly cache: DiscoveryCache;

  constructor(config?: Partial<DiscoveryConfig>) {
    this.config = {
      userPluginsDir: path.join(os.homedir(), '.claude', 'plugins'),
      projectPluginsDir: path.join(process.cwd(), '.claude', 'plugins'),
      marketplacesDir: path.join(os.homedir(), '.claude', 'marketplaces'),
      enableCache: true,
      cacheTTL: 3600000, // 1 hour
      ...config
    };

    this.gitClient = new GitClient();
    this.cache = new DiscoveryCache(this.config.marketplacesDir);
  }

  async discoverAll(): Promise<DiscoveryResult> {
    const result: DiscoveryResult = {
      sources: [],
      marketplaces: [],
      plugins: [],
      stats: {
        totalPluginsFound: 0,
        duplicatesResolved: 0,
        marketplacesScanned: 0,
        directPlugins: 0,
        marketplacePlugins: 0
      },
      warnings: [],
      errors: []
    };

    // 1. Get all discovery sources
    result.sources = this.getDiscoverySources();

    // 2. Discover marketplaces (local and remote)
    result.marketplaces = await this.discoverMarketplaces();
    result.stats.marketplacesScanned = result.marketplaces.length;

    // 3. Discover plugins from each source
    const allPlugins: DiscoveredPlugin[] = [];

    for (const source of result.sources) {
      try {
        const plugins = await this.discoverFrom(source);
        allPlugins.push(...plugins);

        if (source.type === 'directory') {
          result.stats.directPlugins += plugins.length;
        }
      } catch (error) {
        result.errors.push({
          source: source.path,
          message: `Failed to discover from ${source.path}: ${error.message}`
        });
      }
    }

    // 4. Discover plugins from marketplaces
    for (const marketplace of result.marketplaces) {
      try {
        const plugins = await this.discoverFromMarketplace(marketplace);
        allPlugins.push(...plugins);
        result.stats.marketplacePlugins += plugins.length;
      } catch (error) {
        result.errors.push({
          source: marketplace.path,
          message: `Failed to discover from marketplace ${marketplace.name}: ${error.message}`
        });
      }
    }

    // 5. Resolve duplicates
    result.stats.totalPluginsFound = allPlugins.length;
    result.plugins = this.resolvePluginConflicts(allPlugins);
    result.stats.duplicatesResolved = allPlugins.length - result.plugins.length;

    return result;
  }

  getDiscoverySources(): DiscoverySource[] {
    const sources: DiscoverySource[] = [];

    // 1. Project local plugins (highest priority)
    if (fs.existsSync(this.config.projectPluginsDir)) {
      sources.push({
        type: 'directory',
        path: this.config.projectPluginsDir,
        priority: 100
      });
    }

    // 2. User global plugins
    if (fs.existsSync(this.config.userPluginsDir)) {
      sources.push({
        type: 'directory',
        path: this.config.userPluginsDir,
        priority: 50
      });
    }

    // 3. Local marketplace (current project)
    const projectMarketplace = path.join(process.cwd(), '.claude-plugin', 'marketplace.json');
    if (fs.existsSync(projectMarketplace)) {
      sources.push({
        type: 'marketplace-local',
        path: path.dirname(projectMarketplace),
        priority: 75
      });
    }

    // 4. Remote marketplaces (from config)
    const remoteMarketplaces = this.getConfiguredRemoteMarketplaces();
    for (const marketplace of remoteMarketplaces) {
      sources.push({
        type: 'marketplace-remote',
        path: marketplace.url,
        priority: 25
      });
    }

    return sources;
  }

  async discoverRemoteMarketplace(url: string): Promise<DiscoveredMarketplace> {
    // 1. Check cache
    const cacheKey = this.cache.getMarketplaceCacheKey(url);
    const cached = await this.cache.get(cacheKey);

    if (cached && !this.cache.isStale(cached)) {
      return cached.data;
    }

    // 2. Clone or pull repository
    const marketplaceName = this.extractMarketplaceName(url);
    const localPath = path.join(this.config.marketplacesDir, marketplaceName);

    if (await fs.pathExists(localPath)) {
      await this.gitClient.pull(localPath);
    } else {
      await fs.ensureDir(this.config.marketplacesDir);
      await this.gitClient.clone(url, localPath);
    }

    // 3. Load marketplace
    const marketplace = await this.loadLocalMarketplace(localPath);
    marketplace.isRemote = true;
    marketplace.remoteUrl = url;
    marketplace.lastUpdated = new Date();

    // 4. Cache
    await this.cache.set(cacheKey, marketplace);

    return marketplace;
  }

  resolvePluginConflicts(plugins: DiscoveredPlugin[]): DiscoveredPlugin[] {
    // Group by ID
    const grouped = new Map<string, DiscoveredPlugin[]>();

    for (const plugin of plugins) {
      if (!grouped.has(plugin.id)) {
        grouped.set(plugin.id, []);
      }
      grouped.get(plugin.id)!.push(plugin);
    }

    // Resolve conflicts by priority
    const resolved: DiscoveredPlugin[] = [];

    for (const [id, candidates] of grouped) {
      if (candidates.length === 1) {
        resolved.push(candidates[0]);
        continue;
      }

      // Sort by source priority (project > user > marketplace)
      const sorted = candidates.sort((a, b) => {
        const priorityA = this.getSourcePriority(a.sourceType);
        const priorityB = this.getSourcePriority(b.sourceType);
        return priorityB - priorityA;
      });

      resolved.push(sorted[0]);
    }

    return resolved;
  }

  private getSourcePriority(sourceType: string): number {
    switch (sourceType) {
      case 'project': return 100;
      case 'user': return 50;
      case 'marketplace': return 25;
      default: return 0;
    }
  }
}
```

#### Git Client for Remote Repositories

```typescript
class GitClient {
  async clone(url: string, targetPath: string): Promise<void> {
    await execPromise(`git clone "${url}" "${targetPath}"`);
  }

  async pull(repoPath: string): Promise<void> {
    await execPromise(`git -C "${repoPath}" pull`);
  }

  async getRemoteUrl(repoPath: string): Promise<string | null> {
    try {
      const result = await execPromise(`git -C "${repoPath}" remote get-url origin`);
      return result.stdout.trim();
    } catch {
      return null;
    }
  }

  async getCommitHash(repoPath: string): Promise<string | null> {
    try {
      const result = await execPromise(`git -C "${repoPath}" rev-parse HEAD`);
      return result.stdout.trim();
    } catch {
      return null;
    }
  }
}
```

#### Configuration
```typescript
interface DiscoveryConfig {
  userPluginsDir: string;
  projectPluginsDir: string;
  marketplacesDir: string;
  enableCache: boolean;
  cacheTTL: number;
  remoteMarketplaces: RemoteMarketplaceConfig[];
}

interface RemoteMarketplaceConfig {
  name: string;
  url: string;
  enabled: boolean;
  autoUpdate: boolean;
  updateInterval?: number;
}
```

```yaml
# ~/.claude/curator.config.yaml
discovery:
  sources:
    - type: directory
      path: ~/.claude/plugins
      enabled: true
      priority: 50
    - type: directory
      path: ./.claude/plugins
      enabled: true
      priority: 100

  cache:
    enabled: true
    ttl: 3600000  # 1 hour
    path: ~/.claude/curator/cache

  remoteMarketplaces:
    - name: jeremylongshore-plugins
      url: https://github.com/jeremylongshore/claude-code-plugins-plus.git
      enabled: true
      autoUpdate: false
      updateInterval: 86400000  # 24 hours

    - name: ccplugins-marketplace
      url: https://github.com/ccplugins/marketplace.git
      enabled: true
      autoUpdate: true
```

---

### 2. Indexer Service

**Responsibility:** Parse plugin components and build searchable index.

#### Interface
```typescript
interface IndexerService {
  /**
   * Index all components from discovered plugins
   */
  indexPlugins(sources: PluginSource[]): Promise<ComponentIndex>;

  /**
   * Index single plugin
   */
  indexPlugin(source: PluginSource): Promise<PluginComponents>;

  /**
   * Rebuild index from scratch
   */
  rebuildIndex(): Promise<ComponentIndex>;

  /**
   * Load cached index
   */
  loadIndex(): Promise<ComponentIndex | null>;

  /**
   * Save index to cache
   */
  saveIndex(index: ComponentIndex): Promise<void>;
}

interface PluginComponents {
  commands: CommandMeta[];
  agents: AgentMeta[];
  skills: SkillMeta[];
  hooks: HookMeta[];
  mcpServers: McpServerMeta[];
}
```

#### Implementation Details
```typescript
class IndexerServiceImpl implements IndexerService {
  private readonly cache: IndexCache;

  async indexPlugin(source: PluginSource): Promise<PluginComponents> {
    const components: PluginComponents = {
      commands: await this.indexCommands(source),
      agents: await this.indexAgents(source),
      skills: await this.indexSkills(source),
      hooks: await this.indexHooks(source),
      mcpServers: await this.indexMcpServers(source)
    };

    return components;
  }

  private async indexCommands(source: PluginSource): Promise<CommandMeta[]> {
    const commandFiles = await glob('commands/**/*.md', {
      cwd: source.path,
      absolute: true
    });

    const commands: CommandMeta[] = [];

    for (const file of commandFiles) {
      const content = await fs.readFile(file, 'utf8');
      const { frontmatter, body } = this.parseFrontmatter(content);

      commands.push({
        id: `${source.name}:${path.relative(source.path, file)}`,
        sourcePlugin: source.name,
        path: file,
        relativePath: path.relative(source.path, file),
        name: frontmatter.name || this.extractCommandName(file),
        description: frontmatter.description || '',
        allowedTools: frontmatter['allowed-tools'] || [],
        argumentHint: frontmatter['argument-hint'],
        requires: frontmatter.requires,
        tags: frontmatter.tags || [],
        content: body,
        sha256: this.hashContent(content)
      });
    }

    return commands;
  }

  private async indexAgents(source: PluginSource): Promise<AgentMeta[]> {
    const agentFiles = await glob('agents/**/*.md', {
      cwd: source.path,
      absolute: true
    });

    const agents: AgentMeta[] = [];

    for (const file of agentFiles) {
      const content = await fs.readFile(file, 'utf8');
      const { frontmatter, body } = this.parseFrontmatter(content);

      agents.push({
        id: `${source.name}:${path.relative(source.path, file)}`,
        sourcePlugin: source.name,
        path: file,
        relativePath: path.relative(source.path, file),
        name: frontmatter.name || this.extractAgentName(file),
        description: frontmatter.description || '',
        tools: frontmatter.tools || 'all',
        requires: frontmatter.requires,
        tags: frontmatter.tags || [],
        content: body,
        sha256: this.hashContent(content)
      });
    }

    return agents;
  }

  private async indexSkills(source: PluginSource): Promise<SkillMeta[]> {
    const skillDirs = await glob('skills/*/', {
      cwd: source.path,
      absolute: true
    });

    const skills: SkillMeta[] = [];

    for (const dir of skillDirs) {
      const skillFile = path.join(dir, 'SKILL.md');
      if (!await fs.pathExists(skillFile)) continue;

      const content = await fs.readFile(skillFile, 'utf8');
      const { frontmatter, body } = this.parseFrontmatter(content);

      skills.push({
        id: `${source.name}:${path.relative(source.path, dir)}`,
        sourcePlugin: source.name,
        path: dir,
        relativePath: path.relative(source.path, dir),
        name: frontmatter.name || path.basename(dir),
        description: frontmatter.description || '',
        tags: frontmatter.tags || [],
        content: body,
        sha256: this.hashDirectory(dir)
      });
    }

    return skills;
  }

  private async indexHooks(source: PluginSource): Promise<HookMeta[]> {
    const hooksFile = path.join(source.path, '.claude-plugin', 'hooks.json');
    if (!await fs.pathExists(hooksFile)) return [];

    const hooksConfig = await fs.readJSON(hooksFile);
    const hooks: HookMeta[] = [];

    for (const [event, eventHooks] of Object.entries(hooksConfig)) {
      for (const hook of eventHooks as any[]) {
        hooks.push({
          id: `${source.name}:hook:${event}:${hooks.length}`,
          sourcePlugin: source.name,
          event,
          matcher: hook.matcher,
          command: hook.command,
          priority: hook.priority || 0
        });
      }
    }

    return hooks;
  }

  private async indexMcpServers(source: PluginSource): Promise<McpServerMeta[]> {
    const mcpFile = path.join(source.path, '.mcp.json');
    if (!await fs.pathExists(mcpFile)) return [];

    const mcpConfig = await fs.readJSON(mcpFile);
    const servers: McpServerMeta[] = [];

    for (const [name, config] of Object.entries(mcpConfig.mcpServers || {})) {
      servers.push({
        id: `${source.name}:mcp:${name}`,
        sourcePlugin: source.name,
        name,
        config: config as any
      });
    }

    return servers;
  }

  private parseFrontmatter(content: string): { frontmatter: any; body: string } {
    const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
    if (!match) return { frontmatter: {}, body: content };

    const frontmatter = yaml.load(match[1]);
    const body = match[2];

    return { frontmatter, body };
  }

  private hashContent(content: string): string {
    return crypto.createHash('sha256').update(content).digest('hex');
  }

  private hashDirectory(dir: string): string {
    // Hash all files in directory
    const files = glob.sync('**/*', { cwd: dir, nodir: true });
    const hash = crypto.createHash('sha256');

    for (const file of files.sort()) {
      const content = fs.readFileSync(path.join(dir, file));
      hash.update(file);
      hash.update(content);
    }

    return hash.digest('hex');
  }
}
```

#### Index Cache
```typescript
class IndexCache {
  private readonly cacheDir: string;
  private readonly cacheFile: string;

  constructor() {
    this.cacheDir = path.join(os.homedir(), '.claude', 'curator', 'cache');
    this.cacheFile = path.join(this.cacheDir, 'component-index.json');
  }

  async load(): Promise<ComponentIndex | null> {
    if (!await fs.pathExists(this.cacheFile)) return null;

    const cached = await fs.readJSON(this.cacheFile);

    // Check if cache is stale (> 1 hour)
    const cacheAge = Date.now() - new Date(cached.generated).getTime();
    if (cacheAge > 3600000) return null;

    return cached;
  }

  async save(index: ComponentIndex): Promise<void> {
    await fs.ensureDir(this.cacheDir);
    await fs.writeJSON(this.cacheFile, index, { spaces: 2 });
  }

  async clear(): Promise<void> {
    await fs.remove(this.cacheFile);
  }
}
```

---

### 3. Curator Service

**Responsibility:** Manage component selection and curation configuration.

#### Interface
```typescript
interface CuratorService {
  /**
   * Create new curation from config
   */
  createCuration(config: CurationConfig): Promise<Curation>;

  /**
   * Load curation from file
   */
  loadCuration(file: string): Promise<Curation>;

  /**
   * Save curation to file
   */
  saveCuration(curation: Curation, file: string): Promise<void>;

  /**
   * Add component to curation
   */
  addComponent(curation: Curation, componentId: string): Promise<void>;

  /**
   * Remove component from curation
   */
  removeComponent(curation: Curation, componentId: string): Promise<void>;

  /**
   * Validate curation
   */
  validate(curation: Curation): Promise<ValidationResult>;
}

interface CurationConfig {
  name: string;
  version: string;
  description: string;
  author?: {
    name: string;
    email: string;
  };
  components: ComponentSelection[];
  rename?: Record<string, string>;
  overrides?: Partial<PluginManifest>;
  dependencies?: DependencyConfig;
}

interface ComponentSelection {
  source: string;
  type: 'commands' | 'agents' | 'skills' | 'hooks' | 'mcp';
  select: string[];
  exclude?: string[];
}
```

#### Implementation Details
```typescript
class CuratorServiceImpl implements CuratorService {
  constructor(
    private readonly indexer: IndexerService,
    private readonly validator: ValidatorService
  ) {}

  async createCuration(config: CurationConfig): Promise<Curation> {
    // Load component index
    const index = await this.indexer.loadIndex();
    if (!index) throw new Error('Component index not found. Run discovery first.');

    // Resolve component selections
    const selectedComponents = await this.resolveSelections(config.components, index);

    // Apply renames
    const renamedComponents = this.applyRenames(selectedComponents, config.rename || {});

    // Create curation object
    const curation: Curation = {
      version: '1',
      name: config.name,
      pluginVersion: config.version,
      description: config.description,
      author: config.author,
      created: new Date(),
      components: renamedComponents,
      overrides: config.overrides,
      dependencies: config.dependencies
    };

    return curation;
  }

  private async resolveSelections(
    selections: ComponentSelection[],
    index: ComponentIndex
  ): Promise<SelectedComponent[]> {
    const selected: SelectedComponent[] = [];

    for (const selection of selections) {
      const sourceComponents = this.getComponentsBySource(
        index,
        selection.source,
        selection.type
      );

      for (const pattern of selection.select) {
        const matching = this.matchComponents(sourceComponents, pattern);

        // Filter exclusions
        const filtered = selection.exclude
          ? matching.filter(c => !this.matchesAny(c.relativePath, selection.exclude!))
          : matching;

        selected.push(...filtered.map(c => ({
          id: c.id,
          type: selection.type,
          sourcePlugin: c.sourcePlugin,
          originalPath: c.path,
          relativePath: c.relativePath,
          curated Path: c.relativePath, // Can be renamed later
          sha256: c.sha256,
          metadata: c
        })));
      }
    }

    return selected;
  }

  private getComponentsBySource(
    index: ComponentIndex,
    source: string,
    type: string
  ): any[] {
    switch (type) {
      case 'commands':
        return index.components.commands.filter(c => c.sourcePlugin === source);
      case 'agents':
        return index.components.agents.filter(c => c.sourcePlugin === source);
      case 'skills':
        return index.components.skills.filter(c => c.sourcePlugin === source);
      case 'hooks':
        return index.components.hooks.filter(c => c.sourcePlugin === source);
      case 'mcp':
        return index.components.mcpServers.filter(c => c.sourcePlugin === source);
      default:
        return [];
    }
  }

  private matchComponents(components: any[], pattern: string): any[] {
    const matcher = minimatch.makeRe(pattern);
    return components.filter(c => matcher.test(c.relativePath));
  }

  private applyRenames(
    components: SelectedComponent[],
    renames: Record<string, string>
  ): SelectedComponent[] {
    return components.map(c => {
      const renamed = renames[c.relativePath];
      if (renamed) {
        return { ...c, curatedPath: renamed };
      }
      return c;
    });
  }
}
```

---

### 4. Composer Service

**Responsibility:** Generate plugin from curation by copying components and creating manifests.

#### Interface
```typescript
interface ComposerService {
  /**
   * Compose plugin from curation
   */
  compose(curation: Curation, outputPath: string): Promise<CompositionResult>;

  /**
   * Generate plugin manifest
   */
  generateManifest(curation: Curation): PluginManifest;

  /**
   * Generate hooks configuration
   */
  generateHooks(curation: Curation): HooksConfig;

  /**
   * Generate MCP configuration
   */
  generateMcpConfig(curation: Curation): McpConfig;

  /**
   * Generate README
   */
  generateReadme(curation: Curation): string;

  /**
   * Generate provenance manifest
   */
  generateProvenance(curation: Curation): ProvenanceManifest;
}

interface CompositionResult {
  plugin: {
    name: string;
    path: string;
    manifest: PluginManifest;
  };
  components: {
    copied: Array<{ source: string; destination: string }>;
    renamed: Array<{ from: string; to: string }>;
    skipped: Array<{ component: string; reason: string }>;
  };
  dependencies: {
    resolved: Dependency[];
    missing: Dependency[];
    conflicts: Conflict[];
  };
  warnings: Warning[];
  errors: Error[];
}
```

#### Implementation Details
```typescript
class ComposerServiceImpl implements ComposerService {
  constructor(
    private readonly dependencyResolver: DependencyResolver,
    private readonly conflictDetector: ConflictDetector,
    private readonly fileOps: FileOperations
  ) {}

  async compose(curation: Curation, outputPath: string): Promise<CompositionResult> {
    const result: CompositionResult = {
      plugin: {
        name: curation.name,
        path: outputPath,
        manifest: this.generateManifest(curation)
      },
      components: {
        copied: [],
        renamed: [],
        skipped: []
      },
      dependencies: {
        resolved: [],
        missing: [],
        conflicts: []
      },
      warnings: [],
      errors: []
    };

    // Create plugin directory structure
    await this.createPluginStructure(outputPath);

    // Copy components
    for (const component of curation.components) {
      try {
        const destination = path.join(outputPath, component.curatedPath);
        await this.fileOps.copy(component.originalPath, destination);

        result.components.copied.push({
          source: component.originalPath,
          destination
        });

        if (component.curatedPath !== component.relativePath) {
          result.components.renamed.push({
            from: component.relativePath,
            to: component.curatedPath
          });
        }
      } catch (error) {
        result.components.skipped.push({
          component: component.id,
          reason: (error as Error).message
        });
        result.errors.push(error as Error);
      }
    }

    // Resolve dependencies
    const depResult = await this.dependencyResolver.resolve(curation.components);
    result.dependencies.resolved = depResult.resolved;
    result.dependencies.missing = depResult.missing;

    if (depResult.missing.length > 0) {
      result.warnings.push({
        type: 'missing-dependencies',
        message: `${depResult.missing.length} missing dependencies`,
        details: depResult.missing
      });
    }

    // Detect conflicts
    const conflicts = await this.conflictDetector.detect(curation.components);
    result.dependencies.conflicts = conflicts;

    if (conflicts.length > 0) {
      result.errors.push(new Error(`${conflicts.length} conflicts detected`));
    }

    // Generate manifests
    await this.writeManifest(outputPath, result.plugin.manifest);
    await this.writeHooks(outputPath, this.generateHooks(curation));
    await this.writeMcpConfig(outputPath, this.generateMcpConfig(curation));
    await this.writeReadme(outputPath, this.generateReadme(curation));
    await this.writeProvenance(outputPath, this.generateProvenance(curation));

    return result;
  }

  private async createPluginStructure(outputPath: string): Promise<void> {
    const dirs = [
      '.claude-plugin',
      'commands',
      'agents',
      'skills',
      'hooks'
    ];

    for (const dir of dirs) {
      await fs.ensureDir(path.join(outputPath, dir));
    }
  }

  generateManifest(curation: Curation): PluginManifest {
    const commands = curation.components
      .filter(c => c.type === 'commands')
      .map(c => c.curatedPath);

    const agents = curation.components
      .filter(c => c.type === 'agents')
      .map(c => c.curatedPath);

    const skills = curation.components
      .filter(c => c.type === 'skills')
      .map(c => c.curatedPath);

    return {
      name: curation.name,
      version: curation.pluginVersion,
      description: curation.description,
      author: curation.author,
      commands: commands.length > 0 ? commands : undefined,
      agents: agents.length > 0 ? agents : undefined,
      skills: skills.length > 0 ? skills : undefined,
      ...curation.overrides
    };
  }

  generateHooks(curation: Curation): HooksConfig {
    const hooks: HooksConfig = {};

    const hookComponents = curation.components.filter(c => c.type === 'hooks');

    for (const component of hookComponents) {
      const meta = component.metadata as HookMeta;
      if (!hooks[meta.event]) {
        hooks[meta.event] = [];
      }
      hooks[meta.event].push({
        matcher: meta.matcher,
        command: meta.command,
        priority: meta.priority
      });
    }

    // Apply dependency hooks
    if (curation.dependencies?.hooks) {
      for (const [event, eventHooks] of Object.entries(curation.dependencies.hooks)) {
        if (!hooks[event]) {
          hooks[event] = [];
        }
        hooks[event].push(...eventHooks);
      }
    }

    return hooks;
  }

  generateMcpConfig(curation: Curation): McpConfig {
    const mcpServers: Record<string, any> = {};

    const mcpComponents = curation.components.filter(c => c.type === 'mcp');

    for (const component of mcpComponents) {
      const meta = component.metadata as McpServerMeta;
      mcpServers[meta.name] = meta.config;
    }

    // Apply dependency MCPs
    if (curation.dependencies?.mcpServers?.include) {
      for (const serverName of curation.dependencies.mcpServers.include) {
        if (!mcpServers[serverName]) {
          // TODO: Fetch from index
        }
      }
    }

    // Exclude specified MCPs
    if (curation.dependencies?.mcpServers?.exclude) {
      for (const serverName of curation.dependencies.mcpServers.exclude) {
        delete mcpServers[serverName];
      }
    }

    return { mcpServers };
  }

  generateReadme(curation: Curation): string {
    const template = `# ${curation.name}

${curation.description}

## Components

### Commands (${curation.components.filter(c => c.type === 'commands').length})
${curation.components
  .filter(c => c.type === 'commands')
  .map(c => `- \`${c.curatedPath}\` (from ${c.sourcePlugin})`)
  .join('\n')}

### Agents (${curation.components.filter(c => c.type === 'agents').length})
${curation.components
  .filter(c => c.type === 'agents')
  .map(c => `- \`${c.curatedPath}\` (from ${c.sourcePlugin})`)
  .join('\n')}

### Skills (${curation.components.filter(c => c.type === 'skills').length})
${curation.components
  .filter(c => c.type === 'skills')
  .map(c => `- \`${c.curatedPath}\` (from ${c.sourcePlugin})`)
  .join('\n')}

## Installation

\`\`\`bash
claude plugin install .
\`\`\`

## Provenance

This plugin was curated on ${curation.created.toISOString()} by ${curation.author?.name || 'Unknown'}.

See \`.claude-plugin/curation.json\` for full provenance information.

---

*Generated by Claude Plugin Curator*
`;

    return template;
  }

  generateProvenance(curation: Curation): ProvenanceManifest {
    // Group components by source plugin
    const sourceMap = new Map<string, SelectedComponent[]>();

    for (const component of curation.components) {
      if (!sourceMap.has(component.sourcePlugin)) {
        sourceMap.set(component.sourcePlugin, []);
      }
      sourceMap.get(component.sourcePlugin)!.push(component);
    }

    const sources = Array.from(sourceMap.entries()).map(([plugin, components]) => ({
      plugin,
      version: 'unknown', // TODO: Get from plugin manifest
      commit: undefined,
      components: components.map(c => ({
        type: c.type,
        original: c.relativePath,
        curated: c.curatedPath,
        sha256: c.sha256,
        modified: false
      }))
    }));

    return {
      version: '1',
      name: curation.name,
      curated: curation.created.toISOString(),
      curator: curation.author,
      sources,
      dependencies: {
        mcpServers: Object.keys(this.generateMcpConfig(curation).mcpServers),
        requiredBy: {} // TODO: Extract from component requires
      },
      changeLog: [
        {
          date: curation.created.toISOString().split('T')[0],
          version: curation.pluginVersion,
          changes: ['Initial curation']
        }
      ]
    };
  }
}
```

---

### 5. Dependency Resolver

**Responsibility:** Analyze and resolve component dependencies.

#### Interface
```typescript
interface DependencyResolver {
  /**
   * Resolve dependencies for components
   */
  resolve(components: SelectedComponent[]): Promise<DependencyResult>;

  /**
   * Extract dependencies from component
   */
  extractDependencies(component: SelectedComponent): Dependency[];

  /**
   * Check if dependency is satisfied
   */
  isSatisfied(dependency: Dependency, available: SelectedComponent[]): boolean;
}

interface DependencyResult {
  resolved: Dependency[];
  missing: Dependency[];
  graph: Map<string, Dependency[]>;
}

interface Dependency {
  type: 'mcp' | 'agent' | 'command' | 'skill';
  name: string;
  required By: string;
  optional: boolean;
}
```

#### Implementation
```typescript
class DependencyResolverImpl implements DependencyResolver {
  async resolve(components: SelectedComponent[]): Promise<DependencyResult> {
    const graph = new Map<string, Dependency[]>();
    const allDeps: Dependency[] = [];

    // Extract dependencies from all components
    for (const component of components) {
      const deps = this.extractDependencies(component);
      graph.set(component.id, deps);
      allDeps.push(...deps);
    }

    // Check which are satisfied
    const resolved: Dependency[] = [];
    const missing: Dependency[] = [];

    for (const dep of allDeps) {
      if (this.isSatisfied(dep, components)) {
        resolved.push(dep);
      } else if (!dep.optional) {
        missing.push(dep);
      }
    }

    return { resolved, missing, graph };
  }

  extractDependencies(component: SelectedComponent): Dependency[] {
    const deps: Dependency[] = [];
    const meta = component.metadata;

    // From frontmatter requires
    if (meta.requires) {
      if (meta.requires.mcpServers) {
        deps.push(...meta.requires.mcpServers.map(name => ({
          type: 'mcp' as const,
          name,
          requiredBy: component.id,
          optional: false
        })));
      }

      if (meta.requires.agents) {
        deps.push(...meta.requires.agents.map(name => ({
          type: 'agent' as const,
          name,
          requiredBy: component.id,
          optional: false
        })));
      }

      if (meta.requires.commands) {
        deps.push(...meta.requires.commands.map(name => ({
          type: 'command' as const,
          name,
          requiredBy: component.id,
          optional: false
        })));
      }
    }

    // Infer from content (optional heuristic)
    if (meta.content) {
      const inferred = this.inferDependencies(meta.content);
      deps.push(...inferred.map(d => ({ ...d, optional: true })));
    }

    return deps;
  }

  private inferDependencies(content: string): Partial<Dependency>[] {
    const deps: Partial<Dependency>[] = [];

    // Look for agent invocations: "use the X agent"
    const agentMatches = content.matchAll(/use the (\w+[\w-]*) agent/gi);
    for (const match of agentMatches) {
      deps.push({
        type: 'agent',
        name: match[1]
      });
    }

    // Look for MCP calls: "mcp__X__"
    const mcpMatches = content.matchAll(/mcp__(\w+)__/g);
    for (const match of mcpMatches) {
      deps.push({
        type: 'mcp',
        name: match[1]
      });
    }

    return deps as Dependency[];
  }

  isSatisfied(dependency: Dependency, available: SelectedComponent[]): boolean {
    switch (dependency.type) {
      case 'mcp':
        return available.some(c =>
          c.type === 'mcp' && (c.metadata as McpServerMeta).name === dependency.name
        );
      case 'agent':
        return available.some(c =>
          c.type === 'agents' && c.relativePath.includes(dependency.name)
        );
      case 'command':
        return available.some(c =>
          c.type === 'commands' && c.relativePath.includes(dependency.name)
        );
      case 'skill':
        return available.some(c =>
          c.type === 'skills' && c.relativePath.includes(dependency.name)
        );
      default:
        return false;
    }
  }
}
```

---

### 6. Conflict Detector

**Responsibility:** Detect naming conflicts and incompatibilities.

#### Interface
```typescript
interface ConflictDetector {
  /**
   * Detect conflicts in component selection
   */
  detect(components: SelectedComponent[]): Promise<Conflict[]>;

  /**
   * Detect command name conflicts
   */
  detectCommandConflicts(commands: SelectedComponent[]): Conflict[];

  /**
   * Detect MCP server conflicts
   */
  detectMcpConflicts(mcpServers: SelectedComponent[]): Conflict[];

  /**
   * Detect hook conflicts
   */
  detectHookConflicts(hooks: SelectedComponent[]): Conflict[];
}

interface Conflict {
  type: 'command-collision' | 'mcp-duplicate' | 'hook-overlap' | 'version-mismatch';
  severity: 'error' | 'warning';
  message: string;
  components: string[];
  suggestion?: string;
}
```

#### Implementation
```typescript
class ConflictDetectorImpl implements ConflictDetector {
  async detect(components: SelectedComponent[]): Promise<Conflict[]> {
    const conflicts: Conflict[] = [];

    const commands = components.filter(c => c.type === 'commands');
    const mcpServers = components.filter(c => c.type === 'mcp');
    const hooks = components.filter(c => c.type === 'hooks');

    conflicts.push(...this.detectCommandConflicts(commands));
    conflicts.push(...this.detectMcpConflicts(mcpServers));
    conflicts.push(...this.detectHookConflicts(hooks));

    return conflicts;
  }

  detectCommandConflicts(commands: SelectedComponent[]): Conflict[] {
    const conflicts: Conflict[] = [];
    const nameMap = new Map<string, string[]>();

    for (const cmd of commands) {
      const name = this.extractCommandName(cmd.curatedPath);
      if (!nameMap.has(name)) {
        nameMap.set(name, []);
      }
      nameMap.get(name)!.push(cmd.id);
    }

    for (const [name, componentIds] of nameMap) {
      if (componentIds.length > 1) {
        conflicts.push({
          type: 'command-collision',
          severity: 'error',
          message: `Command name "${name}" is used by multiple components`,
          components: componentIds,
          suggestion: `Rename one of the commands using the 'rename' configuration`
        });
      }
    }

    return conflicts;
  }

  detectMcpConflicts(mcpServers: SelectedComponent[]): Conflict[] {
    const conflicts: Conflict[] = [];
    const nameMap = new Map<string, string[]>();

    for (const mcp of mcpServers) {
      const meta = mcp.metadata as McpServerMeta;
      if (!nameMap.has(meta.name)) {
        nameMap.set(meta.name, []);
      }
      nameMap.get(meta.name)!.push(mcp.id);
    }

    for (const [name, componentIds] of nameMap) {
      if (componentIds.length > 1) {
        conflicts.push({
          type: 'mcp-duplicate',
          severity: 'warning',
          message: `MCP server "${name}" is defined in multiple plugins`,
          components: componentIds,
          suggestion: `This may be intentional if configurations are identical`
        });
      }
    }

    return conflicts;
  }

  detectHookConflicts(hooks: SelectedComponent[]): Conflict[] {
    const conflicts: Conflict[] = [];
    const eventMap = new Map<string, HookMeta[]>();

    for (const hook of hooks) {
      const meta = hook.metadata as HookMeta;
      if (!eventMap.has(meta.event)) {
        eventMap.set(meta.event, []);
      }
      eventMap.get(meta.event)!.push(meta);
    }

    for (const [event, eventHooks] of eventMap) {
      // Check for overlapping matchers
      for (let i = 0; i < eventHooks.length; i++) {
        for (let j = i + 1; j < eventHooks.length; j++) {
          if (this.matchersOverlap(eventHooks[i].matcher, eventHooks[j].matcher)) {
            conflicts.push({
              type: 'hook-overlap',
              severity: 'warning',
              message: `Hooks for event "${event}" have overlapping matchers`,
              components: [eventHooks[i].id, eventHooks[j].id],
              suggestion: `Review hook priorities or matcher patterns`
            });
          }
        }
      }
    }

    return conflicts;
  }

  private extractCommandName(path: string): string {
    const match = path.match(/commands\/(.+)\.md$/);
    return match ? match[1] : path;
  }

  private matchersOverlap(matcher1: any, matcher2: any): boolean {
    // TODO: Implement proper matcher overlap detection
    return JSON.stringify(matcher1) === JSON.stringify(matcher2);
  }
}
```

---

## Data Models & Schemas

### Component Index Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ComponentIndex",
  "type": "object",
  "required": ["version", "generated", "components"],
  "properties": {
    "version": {
      "type": "string",
      "const": "1"
    },
    "generated": {
      "type": "string",
      "format": "date-time"
    },
    "sources": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["name", "path"],
        "properties": {
          "name": { "type": "string" },
          "path": { "type": "string" },
          "type": {
            "enum": ["user", "project", "marketplace"]
          },
          "version": { "type": "string" },
          "manifest": { "type": "object" }
        }
      }
    },
    "components": {
      "type": "object",
      "properties": {
        "commands": {
          "type": "array",
          "items": { "$ref": "#/definitions/CommandMeta" }
        },
        "agents": {
          "type": "array",
          "items": { "$ref": "#/definitions/AgentMeta" }
        },
        "skills": {
          "type": "array",
          "items": { "$ref": "#/definitions/SkillMeta" }
        },
        "hooks": {
          "type": "array",
          "items": { "$ref": "#/definitions/HookMeta" }
        },
        "mcpServers": {
          "type": "array",
          "items": { "$ref": "#/definitions/McpServerMeta" }
        }
      }
    }
  },
  "definitions": {
    "CommandMeta": {
      "type": "object",
      "required": ["id", "sourcePlugin", "path", "name"],
      "properties": {
        "id": { "type": "string" },
        "sourcePlugin": { "type": "string" },
        "path": { "type": "string" },
        "relativePath": { "type": "string" },
        "name": { "type": "string" },
        "description": { "type": "string" },
        "allowedTools": {
          "type": "array",
          "items": { "type": "string" }
        },
        "argumentHint": { "type": "string" },
        "requires": { "$ref": "#/definitions/Requires" },
        "tags": {
          "type": "array",
          "items": { "type": "string" }
        },
        "sha256": { "type": "string" }
      }
    },
    "AgentMeta": {
      "type": "object",
      "required": ["id", "sourcePlugin", "path", "name"],
      "properties": {
        "id": { "type": "string" },
        "sourcePlugin": { "type": "string" },
        "path": { "type": "string" },
        "relativePath": { "type": "string" },
        "name": { "type": "string" },
        "description": { "type": "string" },
        "tools": {
          "oneOf": [
            { "type": "string", "const": "all" },
            { "type": "array", "items": { "type": "string" } }
          ]
        },
        "requires": { "$ref": "#/definitions/Requires" },
        "tags": {
          "type": "array",
          "items": { "type": "string" }
        },
        "sha256": { "type": "string" }
      }
    },
    "SkillMeta": {
      "type": "object",
      "required": ["id", "sourcePlugin", "path", "name"],
      "properties": {
        "id": { "type": "string" },
        "sourcePlugin": { "type": "string" },
        "path": { "type": "string" },
        "relativePath": { "type": "string" },
        "name": { "type": "string" },
        "description": { "type": "string" },
        "tags": {
          "type": "array",
          "items": { "type": "string" }
        },
        "sha256": { "type": "string" }
      }
    },
    "HookMeta": {
      "type": "object",
      "required": ["id", "sourcePlugin", "event"],
      "properties": {
        "id": { "type": "string" },
        "sourcePlugin": { "type": "string" },
        "event": { "type": "string" },
        "matcher": { "type": "object" },
        "command": { "type": "string" },
        "priority": { "type": "number" }
      }
    },
    "McpServerMeta": {
      "type": "object",
      "required": ["id", "sourcePlugin", "name"],
      "properties": {
        "id": { "type": "string" },
        "sourcePlugin": { "type": "string" },
        "name": { "type": "string" },
        "config": { "type": "object" }
      }
    },
    "Requires": {
      "type": "object",
      "properties": {
        "mcpServers": {
          "type": "array",
          "items": { "type": "string" }
        },
        "agents": {
          "type": "array",
          "items": { "type": "string" }
        },
        "commands": {
          "type": "array",
          "items": { "type": "string" }
        },
        "skills": {
          "type": "array",
          "items": { "type": "string" }
        }
      }
    }
  }
}
```

### Curation Config Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CurationConfig",
  "type": "object",
  "required": ["name", "version", "components"],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    },
    "description": {
      "type": "string"
    },
    "author": {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "email": {
          "type": "string",
          "format": "email"
        }
      }
    },
    "components": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["source", "type", "select"],
        "properties": {
          "source": {
            "type": "string",
            "description": "Source plugin name"
          },
          "type": {
            "enum": ["commands", "agents", "skills", "hooks", "mcp"]
          },
          "select": {
            "type": "array",
            "items": { "type": "string" },
            "minItems": 1,
            "description": "Glob patterns or paths"
          },
          "exclude": {
            "type": "array",
            "items": { "type": "string" },
            "description": "Exclusion patterns"
          }
        }
      }
    },
    "rename": {
      "type": "object",
      "additionalProperties": { "type": "string" },
      "description": "Path renames: original -> new"
    },
    "overrides": {
      "type": "object",
      "description": "Plugin manifest overrides"
    },
    "dependencies": {
      "type": "object",
      "properties": {
        "mcpServers": {
          "type": "object",
          "properties": {
            "include": {
              "type": "array",
              "items": { "type": "string" }
            },
            "exclude": {
              "type": "array",
              "items": { "type": "string" }
            }
          }
        },
        "hooks": {
          "type": "object",
          "additionalProperties": {
            "type": "array",
            "items": { "type": "object" }
          }
        }
      }
    }
  }
}
```

### Provenance Manifest Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ProvenanceManifest",
  "type": "object",
  "required": ["version", "name", "curated", "sources"],
  "properties": {
    "version": {
      "type": "string",
      "const": "1"
    },
    "name": {
      "type": "string"
    },
    "curated": {
      "type": "string",
      "format": "date-time"
    },
    "curator": {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "email": {
          "type": "string",
          "format": "email"
        }
      }
    },
    "sources": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["plugin", "version", "components"],
        "properties": {
          "plugin": { "type": "string" },
          "version": { "type": "string" },
          "commit": { "type": "string" },
          "components": {
            "type": "array",
            "items": {
              "type": "object",
              "required": ["type", "original", "curated", "sha256"],
              "properties": {
                "type": {
                  "enum": ["command", "agent", "skill", "hook", "mcp"]
                },
                "original": { "type": "string" },
                "curated": { "type": "string" },
                "sha256": { "type": "string" },
                "modified": { "type": "boolean" }
              }
            }
          }
        }
      }
    },
    "dependencies": {
      "type": "object",
      "properties": {
        "mcpServers": {
          "type": "array",
          "items": { "type": "string" }
        },
        "requiredBy": {
          "type": "object",
          "additionalProperties": { "type": "object" }
        }
      }
    },
    "changeLog": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["date", "version", "changes"],
        "properties": {
          "date": { "type": "string" },
          "version": { "type": "string" },
          "changes": {
            "type": "array",
            "items": { "type": "string" }
          }
        }
      }
    }
  }
}
```

---

## CLI Interface

### Command Structure

```
claude-curator <command> [options]

Commands:
  discover              Discover and index all installed plugins
  list [type]           List components by type
  search <query>        Search for components
  show <id>             Show component details
  create                Create a new curated plugin
  provenance            Show provenance information
  update [component]    Update components from source
  validate              Validate curation
  marketplace           Marketplace commands

Options:
  --version             Show version number
  --help                Show help
  --debug               Enable debug logging
  --config <file>       Config file path
```

### Command Specifications

#### 1. `discover`

```bash
claude-curator discover [options]

Discover and index all installed Claude Code plugins

Options:
  --rebuild             Force rebuild of index
  --cache-dir <path>    Cache directory (default: ~/.claude/curator/cache)
  --json                Output as JSON
  --verbose, -v         Verbose output
```

**Output:**
```
✓ Discovered 15 plugins
✓ Indexed 247 components
  - 89 commands
  - 45 agents
  - 78 skills
  - 23 hooks
  - 12 MCP servers

Index saved to: ~/.claude/curator/cache/component-index.json
```

#### 2. `list`

```bash
claude-curator list [type] [options]

List components by type

Arguments:
  type                  Component type (commands|agents|skills|hooks|mcp)

Options:
  --plugin <name>       Filter by plugin name
  --tag <tag>           Filter by tag
  --json                Output as JSON
  --limit <n>           Limit results (default: 50)
```

**Output:**
```
Commands (89 total):

superclaude-framework:
  - commands/help.md: SC Agent session controller
  - commands/design.md: Design system architecture
  - commands/implement.md: Feature and code implementation

claudekit-skills:
  - commands/git-cm.md: Stage all files and create commit
  - commands/git-cp.md: Stage, commit and push
```

#### 3. `create`

```bash
claude-curator create [options]

Create a new curated plugin

Options:
  --config <file>       Curation config file (YAML/JSON)
  --interactive, -i     Interactive TUI mode
  --output <path>       Output directory (default: ./curated-plugins/<name>)
  --dry-run             Preview without creating files
  --force, -f           Overwrite existing plugin
```

**Interactive Mode Flow:**
```
┌─────────────────────────────────────────────────────────────┐
│ Claude Plugin Curator                                       │
│ Create a new curated plugin from existing components        │
└─────────────────────────────────────────────────────────────┘

Plugin Name: [                    ]
Description: [                    ]
Author: [                    ]

┌─ Select Components ─────────────────────────────────────────┐
│ Source Plugins                                              │
│ ☑ superclaude-framework (4.1.5)                             │
│ ☐ fabric-helper (1.2.0)                                     │
│ ☑ claudekit-skills (2.0.1)                                  │
│                                                              │
│ [j/k] Navigate  [Space] Toggle  [Enter] Next  [q] Quit     │
└─────────────────────────────────────────────────────────────┘
```

#### 4. `provenance`

```bash
claude-curator provenance [options]

Show provenance information for curated plugin

Options:
  --plugin <path>       Plugin directory (default: current dir)
  --json                Output as JSON
  --detail              Show detailed component info
```

**Output:**
```
Curation Provenance:
├─ Plugin: my-curated-plugin v1.0.0
├─ Created: 2025-11-11 10:30:00
├─ Curator: Your Name <you@example.com>
│
└─ Components (12):
   ├─ commands/help.md
   │  ├─ Source: superclaude-framework v4.1.5
   │  ├─ SHA256: abc123...
   │  └─ Modified: No
   │
   └─ agents/frontend-architect.md
      ├─ Source: superclaude-framework v4.1.5
      ├─ SHA256: def456...
      └─ Modified: No
```

#### 5. `update`

```bash
claude-curator update [component] [options]

Update components from source plugins

Arguments:
  component             Specific component to update (optional)

Options:
  --check               Check for updates without applying
  --all                 Update all components
  --auto                Auto-update patch versions
  --dry-run             Preview changes
```

**Output:**
```
Checking for updates...

Updates available (3):
  ✓ commands/help.md: v4.1.5 → v4.1.6 (patch)
  ⚠ agents/frontend-architect.md: v4.1.5 → v4.2.0 (minor)
  ⚠ skills/better-auth/: v2.0.1 → v3.0.0 (major - breaking)

Apply updates? [y/N]
```

#### 6. `marketplace`

```bash
claude-curator marketplace <command> [options]

Marketplace commands

Commands:
  create                Create a new marketplace
  add <plugin>          Add plugin to marketplace
  remove <plugin>       Remove plugin from marketplace
  validate              Validate marketplace
  build                 Build distribution package
  docs                  Generate documentation
```

---

## File System Layout

### Project Structure

```
claude-curator/
├── package.json
├── tsconfig.json
├── README.md
├── LICENSE
│
├── src/
│   ├── index.ts                    # Main entry point
│   │
│   ├── cli/
│   │   ├── index.ts                # CLI setup (Commander)
│   │   ├── discover.ts             # Discover command
│   │   ├── list.ts                 # List command
│   │   ├── create.ts               # Create command
│   │   ├── provenance.ts           # Provenance command
│   │   ├── update.ts               # Update command
│   │   ├── marketplace.ts          # Marketplace command
│   │   └── ui/
│   │       ├── interactive.tsx     # Interactive TUI (Ink)
│   │       ├── components/
│   │       │   ├── PluginSelector.tsx
│   │       │   ├── ComponentBrowser.tsx
│   │       │   ├── DependencyViewer.tsx
│   │       │   └── ValidationDisplay.tsx
│   │       └── hooks/
│   │           └── useComponentSelection.ts
│   │
│   ├── core/
│   │   ├── discovery/
│   │   │   ├── DiscoveryService.ts
│   │   │   └── PluginScanner.ts
│   │   ├── indexing/
│   │   │   ├── IndexerService.ts
│   │   │   ├── ComponentParser.ts
│   │   │   └── IndexCache.ts
│   │   ├── curation/
│   │   │   ├── CuratorService.ts
│   │   │   ├── ConfigParser.ts
│   │   │   └── ComponentSelector.ts
│   │   ├── composition/
│   │   │   ├── ComposerService.ts
│   │   │   ├── ManifestGenerator.ts
│   │   │   └── FileComposer.ts
│   │   ├── validation/
│   │   │   ├── ValidatorService.ts
│   │   │   └── SchemaValidator.ts
│   │   ├── versioning/
│   │   │   ├── VersionTracker.ts
│   │   │   ├── ProvenanceGenerator.ts
│   │   │   └── UpdateManager.ts
│   │   └── marketplace/
│   │       ├── MarketplaceBuilder.ts
│   │       └── DistributionPackager.ts
│   │
│   ├── utils/
│   │   ├── DependencyResolver.ts
│   │   ├── ConflictDetector.ts
│   │   ├── FileOperations.ts
│   │   ├── HashUtils.ts
│   │   ├── PatternMatcher.ts
│   │   └── Logger.ts
│   │
│   ├── types/
│   │   ├── index.ts
│   │   ├── Component.ts
│   │   ├── Curation.ts
│   │   ├── Plugin.ts
│   │   └── Marketplace.ts
│   │
│   └── schemas/
│       ├── component-index.schema.json
│       ├── curation-config.schema.json
│       ├── provenance-manifest.schema.json
│       └── marketplace-config.schema.json
│
├── templates/
│   ├── plugin.json.hbs
│   ├── README.md.hbs
│   ├── marketplace.json.hbs
│   └── CHANGELOG.md.hbs
│
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── fixtures/
│   └── helpers/
│
├── docs/
│   ├── getting-started.md
│   ├── cli-reference.md
│   ├── config-reference.md
│   └── api-reference.md
│
└── examples/
    ├── curation-frontend.yaml
    ├── curation-security.yaml
    └── marketplace-devtools.yaml
```

### User Data Directories

```
~/.claude/curator/
├── cache/
│   └── component-index.json        # Cached component index
├── config/
│   └── curator.yaml                # Global curator config
└── templates/
    └── custom-template.yaml        # Custom curation templates

./curated-plugins/                  # Output directory
├── my-curated-plugin/
│   ├── .claude-plugin/
│   │   ├── plugin.json
│   │   ├── curation.json
│   │   └── components.lock.json
│   ├── commands/
│   ├── agents/
│   ├── skills/
│   ├── hooks/
│   │   └── hooks.json
│   ├── .mcp.json
│   ├── README.md
│   └── CHANGELOG.md
└── another-plugin/
```

---

## Algorithms & Logic

### 1. Component Discovery Algorithm

```typescript
async function discoverComponents(rootPath: string): Promise<ComponentIndex> {
  // 1. Find all plugin directories
  const pluginDirs = await findPluginDirectories(rootPath);

  // 2. Parse each plugin manifest
  const plugins: PluginSource[] = [];
  for (const dir of pluginDirs) {
    const manifest = await loadPluginManifest(dir);
    if (manifest) {
      plugins.push({ path: dir, manifest });
    }
  }

  // 3. Index components from each plugin
  const components: ComponentIndex = {
    version: '1',
    generated: new Date().toISOString(),
    sources: plugins,
    components: {
      commands: [],
      agents: [],
      skills: [],
      hooks: [],
      mcpServers: []
    }
  };

  for (const plugin of plugins) {
    const pluginComponents = await indexPlugin(plugin);
    components.components.commands.push(...pluginComponents.commands);
    components.components.agents.push(...pluginComponents.agents);
    components.components.skills.push(...pluginComponents.skills);
    components.components.hooks.push(...pluginComponents.hooks);
    components.components.mcpServers.push(...pluginComponents.mcpServers);
  }

  // 4. Sort and deduplicate
  components.components.commands.sort((a, b) => a.id.localeCompare(b.id));
  components.components = deduplicateComponents(components.components);

  return components;
}

// Time complexity: O(n * m) where n = plugins, m = avg components per plugin
// Space complexity: O(n * m)
```

### 2. Dependency Resolution Algorithm

```typescript
function resolveDependencies(
  components: SelectedComponent[],
  index: ComponentIndex
): DependencyResult {
  const graph = new Map<string, Set<string>>();
  const resolved = new Set<string>();
  const missing = new Set<string>();

  // Build dependency graph
  for (const component of components) {
    graph.set(component.id, new Set());
    const deps = extractDependencies(component);

    for (const dep of deps) {
      graph.get(component.id)!.add(dep.name);

      // Check if dependency exists in selection
      const depExists = components.some(c => matchesDependency(c, dep));
      if (depExists) {
        resolved.add(dep.name);
      } else if (!dep.optional) {
        missing.add(dep.name);
      }
    }
  }

  // Detect circular dependencies using DFS
  const visited = new Set<string>();
  const stack = new Set<string>();

  function hasCycle(node: string): boolean {
    visited.add(node);
    stack.add(node);

    const neighbors = graph.get(node) || new Set();
    for (const neighbor of neighbors) {
      if (!visited.has(neighbor)) {
        if (hasCycle(neighbor)) return true;
      } else if (stack.has(neighbor)) {
        return true; // Cycle detected
      }
    }

    stack.delete(node);
    return false;
  }

  for (const node of graph.keys()) {
    if (!visited.has(node)) {
      if (hasCycle(node)) {
        throw new Error(`Circular dependency detected involving ${node}`);
      }
    }
  }

  return {
    resolved: Array.from(resolved),
    missing: Array.from(missing),
    graph
  };
}

// Time complexity: O(V + E) where V = components, E = dependencies
// Space complexity: O(V + E)
```

### 3. Conflict Detection Algorithm

```typescript
function detectConflicts(components: SelectedComponent[]): Conflict[] {
  const conflicts: Conflict[] = [];

  // Group by type
  const grouped = groupBy(components, c => c.type);

  // Check command name collisions
  if (grouped.commands) {
    const nameMap = new Map<string, SelectedComponent[]>();

    for (const cmd of grouped.commands) {
      const name = extractCommandName(cmd.curatedPath);
      if (!nameMap.has(name)) {
        nameMap.set(name, []);
      }
      nameMap.get(name)!.push(cmd);
    }

    for (const [name, cmds] of nameMap) {
      if (cmds.length > 1) {
        conflicts.push({
          type: 'command-collision',
          severity: 'error',
          message: `Command "${name}" defined in multiple components`,
          components: cmds.map(c => c.id),
          suggestion: `Rename using 'rename' config`
        });
      }
    }
  }

  // Check MCP duplicates
  if (grouped.mcp) {
    // Similar logic for MCP servers
  }

  // Check hook overlaps
  if (grouped.hooks) {
    // Check for matcher overlaps
  }

  return conflicts;
}

// Time complexity: O(n²) worst case for pairwise comparisons
// Space complexity: O(n)
```

---

## Dependencies & Technology Stack

### Core Dependencies

```json
{
  "dependencies": {
    "commander": "^11.1.0",
    "ink": "^4.4.1",
    "react": "^18.2.0",
    "fs-extra": "^11.2.0",
    "fast-glob": "^3.3.2",
    "minimatch": "^9.0.3",
    "js-yaml": "^4.1.0",
    "ajv": "^8.12.0",
    "ajv-formats": "^2.1.1",
    "simple-git": "^3.21.0",
    "chalk": "^5.3.0",
    "ora": "^7.0.1",
    "inquirer": "^9.2.12",
    "table": "^6.8.1",
    "boxen": "^7.1.1",
    "cli-ux": "^6.0.9"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "@types/fs-extra": "^11.0.4",
    "@types/js-yaml": "^4.0.9",
    "typescript": "^5.3.3",
    "ts-node": "^10.9.2",
    "vitest": "^1.0.4",
    "@vitest/ui": "^1.0.4",
    "eslint": "^8.56.0",
    "prettier": "^3.1.1",
    "husky": "^8.0.3",
    "lint-staged": "^15.2.0"
  }
}
```

### Dependency Justification

| Package | Purpose | Alternatives Considered |
|---------|---------|------------------------|
| Commander.js | CLI framework | yargs, oclif |
| Ink | Terminal UI | blessed, ink-terminal |
| fs-extra | File operations | node:fs/promises |
| fast-glob | Pattern matching | glob, globby |
| Ajv | JSON Schema validation | joi, zod |
| simple-git | Git operations | nodegit, isomorphic-git |

---

## Performance Requirements

### Benchmarks

| Operation | Target | Acceptable | Unacceptable |
|-----------|--------|------------|--------------|
| Plugin discovery (10 plugins) | < 1s | < 3s | > 5s |
| Component indexing (200 components) | < 2s | < 5s | > 10s |
| Curation composition | < 3s | < 10s | > 20s |
| Validation | < 1s | < 3s | > 5s |
| Interactive TUI response | < 100ms | < 500ms | > 1s |

### Optimization Strategies

1. **Caching**
   - Cache component index (TTL: 1 hour)
   - Cache parsed frontmatter
   - Cache dependency graphs

2. **Parallel Processing**
   - Index multiple plugins concurrently
   - Parse components in parallel
   - Validate schemas concurrently

3. **Lazy Loading**
   - Load component content only when needed
   - Defer hash calculation until composition
   - Stream large file operations

4. **Incremental Updates**
   - Only re-index modified plugins
   - Track file mtimes for change detection
   - Partial index updates

---

## Security Specifications

### Component Integrity

1. **SHA256 Hashing**
   - Hash all component files during indexing
   - Verify hashes during composition
   - Detect modifications in provenance

2. **Source Verification**
   - Track plugin source (user/project/marketplace)
   - Record Git commit hashes when available
   - Validate plugin manifest signatures (future)

3. **Dependency Validation**
   - Static analysis of component requires
   - Validate MCP server configurations
   - Warn about unverified dependencies

### File System Safety

1. **Path Validation**
   - Prevent path traversal attacks
   - Validate all file paths are within plugin directories
   - Sanitize user inputs in file operations

2. **Permission Checks**
   - Verify read/write permissions before operations
   - Respect file ownership
   - Never modify source plugins

3. **Isolation**
   - Curated plugins in separate directory
   - No automatic modification of source plugins
   - Clear separation of cache and output

---

## Testing Strategy

### Unit Tests

```typescript
describe('DependencyResolver', () => {
  describe('resolve', () => {
    it('should resolve all satisfied dependencies', async () => {
      const components = [
        createMockCommand({ requires: { mcpServers: ['test-mcp'] } }),
        createMockMcp({ name: 'test-mcp' })
      ];

      const result = await resolver.resolve(components);

      expect(result.resolved).toHaveLength(1);
      expect(result.missing).toHaveLength(0);
    });

    it('should detect missing dependencies', async () => {
      const components = [
        createMockCommand({ requires: { mcpServers: ['missing-mcp'] } })
      ];

      const result = await resolver.resolve(components);

      expect(result.resolved).toHaveLength(0);
      expect(result.missing).toHaveLength(1);
      expect(result.missing[0].name).toBe('missing-mcp');
    });

    it('should detect circular dependencies', async () => {
      const components = [
        createMockCommand({ id: 'a', requires: { commands: ['b'] } }),
        createMockCommand({ id: 'b', requires: { commands: ['a'] } })
      ];

      await expect(resolver.resolve(components)).rejects.toThrow('Circular dependency');
    });
  });
});
```

### Integration Tests

```typescript
describe('Curation Workflow', () => {
  it('should create complete plugin from config', async () => {
    // Setup test environment
    const testDir = await createTestEnvironment();
    await installTestPlugins(testDir);

    // Run discovery
    await discoveryService.discoverAll();

    // Create curation
    const config = loadTestCuration('frontend-toolkit');
    const curation = await curatorService.createCuration(config);

    // Compose plugin
    const outputPath = path.join(testDir, 'output', 'frontend-toolkit');
    const result = await composerService.compose(curation, outputPath);

    // Validate results
    expect(result.errors).toHaveLength(0);
    expect(await fs.pathExists(path.join(outputPath, '.claude-plugin', 'plugin.json'))).toBe(true);
    expect(await fs.pathExists(path.join(outputPath, '.claude-plugin', 'curation.json'))).toBe(true);

    // Validate plugin
    const validation = await validatePlugin(outputPath);
    expect(validation.valid).toBe(true);
  });
});
```

### E2E Tests

```typescript
describe('CLI E2E', () => {
  it('should complete full curation flow', async () => {
    // Run discover
    const discoverResult = await exec('claude-curator discover');
    expect(discoverResult.stdout).toContain('Indexed');

    // Create curation
    const createResult = await exec('claude-curator create --config test-curation.yaml');
    expect(createResult.stdout).toContain('Plugin created successfully');

    // Validate
    const validateResult = await exec('claude-curator validate');
    expect(validateResult.exitCode).toBe(0);

    // Show provenance
    const provenanceResult = await exec('claude-curator provenance');
    expect(provenanceResult.stdout).toContain('Curation Provenance');
  });
});
```

---

## Error Handling

### Error Categories

1. **User Errors** (400-level)
   - Invalid configuration
   - Missing required fields
   - Component not found
   - **Action**: Show helpful error message, suggest fix

2. **System Errors** (500-level)
   - File system errors
   - Permission denied
   - Out of disk space
   - **Action**: Log error, show generic message, suggest contact support

3. **Dependency Errors**
   - Missing dependencies
   - Circular dependencies
   - Version conflicts
   - **Action**: Show dependency tree, suggest resolution

4. **Validation Errors**
   - Schema validation failures
   - Naming conflicts
   - Invalid manifests
   - **Action**: Show validation details, highlight issues

### Error Messages

```typescript
class CuratorError extends Error {
  constructor(
    public code: string,
    public message: string,
    public details?: any,
    public suggestions?: string[]
  ) {
    super(message);
  }
}

// Usage
throw new CuratorError(
  'COMPONENT_NOT_FOUND',
  'Component "superclaude:commands/missing.md" not found in index',
  { componentId: 'superclaude:commands/missing.md' },
  [
    'Run "claude-curator discover" to rebuild index',
    'Check component path spelling',
    'Verify plugin is installed'
  ]
);
```

### Error Recovery

```typescript
async function safeCompose(curation: Curation, outputPath: string): Promise<CompositionResult> {
  try {
    return await composerService.compose(curation, outputPath);
  } catch (error) {
    // Attempt recovery
    if (error instanceof CuratorError) {
      switch (error.code) {
        case 'DEPENDENCY_MISSING':
          // Offer to auto-include dependencies
          const shouldInclude = await confirm('Include missing dependencies?');
          if (shouldInclude) {
            const withDeps = await addMissingDependencies(curation);
            return await composerService.compose(withDeps, outputPath);
          }
          break;

        case 'CONFLICT_DETECTED':
          // Offer rename suggestions
          const conflicts = error.details.conflicts;
          const renames = await promptForRenames(conflicts);
          const resolved = applyRenames(curation, renames);
          return await composerService.compose(resolved, outputPath);
      }
    }

    // Cleanup on failure
    await fs.remove(outputPath);
    throw error;
  }
}
```

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)

**Goal**: Basic discovery, indexing, and simple curation

**Tasks**:
- [ ] Project setup (TypeScript, build, tests)
- [ ] Discovery service implementation
- [ ] Indexer service (commands, agents, skills)
- [ ] CLI commands: discover, list, search
- [ ] Component index schema and validation
- [ ] File operations utilities
- [ ] Basic curation config parser

**Deliverables**:
- `claude-curator discover` working
- `claude-curator list` showing components
- Component index JSON output
- Unit tests for core services

**Success Criteria**:
- Discovers all test plugins (10)
- Indexes 200+ components
- Index generation < 3s
- 80% test coverage

---

### Phase 2: Curation & Composition (Weeks 3-4)

**Goal**: Create curated plugins from config

**Tasks**:
- [ ] Curator service implementation
- [ ] Component selection logic
- [ ] Composer service implementation
- [ ] Manifest generation
- [ ] Provenance tracking
- [ ] File copying with renames
- [ ] CLI commands: create, validate

**Deliverables**:
- `claude-curator create --config` working
- Generated plugins pass `claude plugin validate`
- Provenance manifest generated
- Integration tests

**Success Criteria**:
- Create plugin from config < 5s
- Generated plugins validate successfully
- All components copied correctly
- Provenance tracks all sources

---

### Phase 3: Dependencies & Validation (Weeks 5-6)

**Goal**: Dependency resolution and conflict detection

**Tasks**:
- [ ] Dependency resolver implementation
- [ ] Conflict detector implementation
- [ ] Hooks configuration generation
- [ ] MCP configuration generation
- [ ] Validation reporting
- [ ] Error recovery mechanisms

**Deliverables**:
- Dependency resolution working
- Conflict detection working
- Generated hooks.json and .mcp.json
- Validation reports

**Success Criteria**:
- Resolves 100% of declared dependencies
- Detects all name collisions
- Missing dependencies reported
- Circular dependencies detected

---

### Phase 4: Interactive TUI (Weeks 7-8)

**Goal**: Rich interactive curation experience

**Tasks**:
- [ ] Ink TUI framework setup
- [ ] Plugin selector component
- [ ] Component browser component
- [ ] Multi-select with checkboxes
- [ ] Real-time dependency preview
- [ ] Conflict warnings in UI
- [ ] CLI command: create --interactive

**Deliverables**:
- Full interactive TUI
- Component selection workflow
- Real-time validation feedback

**Success Criteria**:
- TUI renders correctly
- Navigation responsive < 100ms
- Multi-select works smoothly
- Dependency preview accurate

---

### Phase 5: Versioning & Updates (Weeks 9-10)

**Goal**: Version tracking and update management

**Tasks**:
- [ ] Version tracker implementation
- [ ] SHA256 hashing for components
- [ ] Update checker
- [ ] Update applier
- [ ] Component diff viewer
- [ ] CLI commands: provenance, update

**Deliverables**:
- Provenance tracking complete
- Update detection working
- Selective updates working
- Diff viewer

**Success Criteria**:
- Provenance shows all sources
- Updates detected correctly
- Selective updates work
- No data loss on updates

---

### Phase 6: Marketplace Builder (Weeks 11-12)

**Goal**: Multi-plugin marketplace composition

**Tasks**:
- [ ] Marketplace builder implementation
- [ ] Cross-plugin validation
- [ ] Distribution packager
- [ ] Documentation generator
- [ ] CLI commands: marketplace *

**Deliverables**:
- Marketplace creation working
- Distribution packages
- Generated documentation

**Success Criteria**:
- Create marketplace from plugins
- No cross-plugin conflicts
- Valid marketplace.json
- Complete documentation

---

### Phase 7: Polish & Release (Weeks 13-14)

**Goal**: Production-ready release

**Tasks**:
- [ ] Comprehensive error handling
- [ ] Performance optimization
- [ ] Documentation (user + dev)
- [ ] Example curations
- [ ] Tutorial videos
- [ ] npm package setup
- [ ] CI/CD pipeline

**Deliverables**:
- 1.0.0 release
- Complete documentation
- 5+ example plugins
- npm package published

**Success Criteria**:
- All tests passing
- Documentation complete
- Performance targets met
- No critical bugs

---

## Appendices

### A. Configuration Examples

#### Example: Frontend Toolkit Curation

```yaml
name: frontend-toolkit
version: 1.0.0
description: Complete toolkit for modern frontend development
author:
  name: Your Name
  email: you@example.com

components:
  - source: superclaude-framework
    type: commands
    select:
      - commands/design.md
      - commands/implement.md

  - source: superclaude-framework
    type: agents
    select:
      - agents/frontend-architect.md
      - agents/technical-writer.md

  - source: claudekit-skills
    type: skills
    select:
      - skills/better-auth/
      - skills/chrome-devtools/

dependencies:
  mcpServers:
    include:
      - sequential-thinking
      - playwright
```

#### Example: Security Toolkit Curation

```yaml
name: security-toolkit
version: 1.0.0
description: Security testing and analysis toolkit
author:
  name: Security Team
  email: security@example.com

components:
  - source: superclaude-framework
    type: agents
    select:
      - agents/security-engineer.md
      - agents/root-cause-analyst.md

  - source: personal-ai-infrastructure
    type: commands
    select:
      - commands/pentester.md

dependencies:
  mcpServers:
    include:
      - tavily-remote
```

---

### B. API Reference

See [api-reference.md](docs/api-reference.md) for complete API documentation.

---

### C. Glossary

- **Component**: Individual plugin element (command, agent, skill, hook, MCP)
- **Curation**: Process of selecting components for new plugin
- **Composition**: Combining selected components into plugin structure
- **Provenance**: Origin and history tracking of components
- **Marketplace**: Collection of curated plugins
- **Index**: Searchable catalog of available components
- **Dependency**: Required component for another component to function
- **Conflict**: Incompatibility between selected components

---

**END OF SPECIFICATION**

---

## Document Control

| Revision | Date | Author | Changes |
|----------|------|--------|---------|
| 1.0.0 | 2025-11-11 | System Architect | Initial specification |

**Review Status**: ⏳ Pending Technical Review

**Next Steps**:
1. Technical review by development team
2. Security review by security team
3. Approval by technical lead
4. Begin Phase 1 implementation
