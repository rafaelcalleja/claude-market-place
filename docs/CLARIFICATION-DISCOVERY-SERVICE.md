# Clarificación: Discovery Service Architecture

**Fecha:** 2025-11-11
**Versión:** 1.0.0
**Basado en:** Investigación de documentación oficial y análisis del proyecto actual

---

## Tabla de Contenidos

1. [Conceptos Clave](#conceptos-clave)
2. [Jerarquía de Conceptos](#jerarquía-de-conceptos)
3. [Estructura de Directorios](#estructura-de-directorios)
4. [Discovery Service Rediseñado](#discovery-service-rediseñado)
5. [Soporte para Repositorios Remotos](#soporte-para-repositorios-remotos)
6. [Interfaces y Modelos de Datos](#interfaces-y-modelos-de-datos)
7. [Ejemplos de Uso](#ejemplos-de-uso)

---

## Conceptos Clave

### 1. Plugin
Un **plugin** es una unidad de funcionalidad que extiende Claude Code. Cada plugin:

- Tiene su propio directorio con estructura `.claude-plugin/plugin.json`
- Puede contener: commands, agents, skills, hooks, MCP servers
- Es la unidad mínima instalable/habilitadable
- Tiene su propio versionado (semver)
- Puede funcionar de forma independiente

**Ejemplo de estructura:**
```
superclaude-framework/
├── .claude-plugin/
│   ├── plugin.json         # Manifiesto del plugin
│   ├── hooks.json          # (opcional)
│   └── .mcp.json           # (opcional)
├── commands/
│   ├── help.md
│   └── design.md
├── agents/
│   ├── frontend-architect.md
│   └── backend-architect.md
└── skills/
    └── superclaude-rules/
```

### 2. Marketplace
Un **marketplace** es un catálogo/índice que agrupa múltiples plugins. Es fundamentalmente:

- Un archivo `marketplace.json` dentro de `.claude-plugin/`
- Una **lista de plugins disponibles** con metadata
- **NO contiene** los plugins en sí, solo referencias a ellos
- Puede estar en: repositorio Git, GitHub, URL arbitraria, o directorio local

**Marketplace vs Plugin:**
```
MARKETPLACE                          PLUGIN
━━━━━━━━━━━                         ━━━━━━
├── .claude-plugin/                  ├── .claude-plugin/
│   └── marketplace.json    ←──ref─→│   └── plugin.json
└── plugins/                         ├── commands/
    ├── plugin-a/            ←──────┤├── agents/
    ├── plugin-b/            ←──────┤└── skills/
    └── plugin-c/
```

**Analogía:**
- **Marketplace** = Catálogo de aplicaciones (como App Store)
- **Plugin** = Aplicación individual

### 3. PluginSource (Concepto Problemático)

El término `PluginSource` en la especificación original era **ambiguo** porque mezclaba dos conceptos:

❌ **Problema Original:**
```typescript
interface PluginSource {
  name: string;           // ¿Es el nombre del marketplace o del plugin?
  path: string;           // ¿Es la ruta al marketplace o al plugin?
  type: 'user' | 'project' | 'marketplace';  // Confuso
  manifest: PluginManifest;  // ¿Qué manifest? ¿plugin o marketplace?
  discovered: Date;
}
```

✅ **Solución: Separar en dos conceptos distintos**

---

## Jerarquía de Conceptos

```
┌─────────────────────────────────────────────────────────────┐
│                    DISCOVERY SOURCES                        │
│  (Lugares donde buscar plugins)                             │
└────────┬────────────────────────────────────────────────────┘
         │
         ├─── 1. User Global Plugins
         │    └─ ~/.claude/plugins/
         │       ├── plugin-a/
         │       └── plugin-b/
         │
         ├─── 2. Project Local Plugins
         │    └─ <project>/.claude/plugins/
         │       ├── plugin-c/
         │       └── plugin-d/
         │
         ├─── 3. Local Marketplaces
         │    └─ <project>/.claude-plugin/marketplace.json
         │       ├── plugins:
         │       │   ├── { source: "./plugins/plugin-e" }
         │       │   └── { source: "./plugins/plugin-f" }
         │
         └─── 4. Remote Marketplaces (Git/GitHub)
              └─ https://github.com/user/marketplace.git
                 └─ .claude-plugin/marketplace.json
                    └── plugins:
                        ├── { source: "./plugins/plugin-g" }
                        └── { source: "./plugins/plugin-h" }
```

### Flujo de Descubrimiento

```
1. SCAN SOURCES
   ↓
   ├─ ~/.claude/plugins/         → [plugin-a, plugin-b]
   ├─ ./.claude/plugins/          → [plugin-c, plugin-d]
   └─ Marketplaces
      ├─ Local marketplace        → [plugin-e, plugin-f]
      └─ Remote marketplace       → [plugin-g, plugin-h]
                                      (clonado localmente)
   ↓
2. RESOLVE ALL PLUGINS
   → Total: [plugin-a, plugin-b, plugin-c, plugin-d,
             plugin-e, plugin-f, plugin-g, plugin-h]
   ↓
3. DEDUPLICATE
   → Si plugin-a aparece en múltiples fuentes, usar prioridad:
      1. Project local (más alta)
      2. User global
      3. Marketplaces (por orden de registro)
   ↓
4. INDEX COMPONENTS
   → Para cada plugin: indexar commands, agents, skills, hooks, MCPs
```

---

## Estructura de Directorios

### Caso Real: Este Proyecto

```
claude-market-place/
├── .claude-plugin/
│   └── marketplace.json          ← MARKETPLACE (índice)
│
└── plugins/                      ← PLUGINS (contenido)
    ├── superclaude-framework/
    │   ├── .claude-plugin/
    │   │   └── plugin.json       ← Plugin individual
    │   ├── commands/
    │   ├── agents/
    │   └── skills/
    │
    ├── claudekit-skills/
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   ├── commands/
    │   └── skills/
    │
    └── personal-ai-infrastructure/
        ├── .claude-plugin/
        │   └── plugin.json
        ├── commands/
        └── agents/
```

### Tipos de Fuentes de Plugins

#### 1. Plugins Directos (Sin Marketplace)
```
~/.claude/plugins/
├── my-plugin/
│   ├── .claude-plugin/plugin.json
│   └── commands/
└── another-plugin/
    ├── .claude-plugin/plugin.json
    └── agents/
```

#### 2. Marketplace Local
```
project/
├── .claude-plugin/
│   └── marketplace.json    ← Define plugins disponibles
└── plugins/
    ├── plugin-a/           ← Plugin referenciado por marketplace
    └── plugin-b/           ← Plugin referenciado por marketplace
```

#### 3. Marketplace Remoto (GitHub)
```
# Repositorio: https://github.com/user/marketplace.git

marketplace/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/
    ├── plugin-x/
    └── plugin-y/

# Claude Code lo clona a:
~/.claude/marketplaces/user-marketplace/
```

---

## Discovery Service Rediseñado

### Nuevas Interfaces

```typescript
/**
 * Representa una fuente donde buscar plugins
 */
interface DiscoverySource {
  type: 'directory' | 'marketplace-local' | 'marketplace-remote';
  path: string;                    // Ruta local o URL
  priority: number;                // Para resolución de conflictos
}

/**
 * Un plugin descubierto con su metadata
 */
interface DiscoveredPlugin {
  // Identificación
  id: string;                      // nombre único (ej: "superclaude-framework")
  name: string;                    // nombre del plugin
  version: string;                 // versión semver

  // Ubicación
  path: string;                    // ruta absoluta al directorio del plugin
  sourceType: 'user' | 'project' | 'marketplace';
  sourcePath: string;              // ruta de la fuente original

  // Metadata
  manifest: PluginManifest;        // contenido de plugin.json
  marketplace?: string;            // nombre del marketplace (si aplica)

  // Tracking
  discovered: Date;                // cuándo fue descubierto
  hash?: string;                   // hash del directorio (para cambios)
}

/**
 * Un marketplace descubierto
 */
interface DiscoveredMarketplace {
  // Identificación
  name: string;                    // nombre del marketplace

  // Ubicación
  path: string;                    // ruta local al marketplace
  isRemote: boolean;               // si fue clonado de remoto
  remoteUrl?: string;              // URL original (si es remoto)

  // Metadata
  manifest: MarketplaceManifest;   // contenido de marketplace.json
  plugins: MarketplacePluginRef[]; // referencias a plugins

  // Tracking
  discovered: Date;
  lastUpdated?: Date;              // última actualización (para remotos)
}

/**
 * Referencia a un plugin dentro de un marketplace
 */
interface MarketplacePluginRef {
  name: string;
  source: string;                  // ruta relativa o absoluta
  version?: string;
  description?: string;
  // ... otros campos opcionales de plugin.json
}

/**
 * Resultado del proceso de discovery
 */
interface DiscoveryResult {
  // Fuentes escaneadas
  sources: DiscoverySource[];

  // Marketplaces encontrados
  marketplaces: DiscoveredMarketplace[];

  // Plugins encontrados (ya deduplicados)
  plugins: DiscoveredPlugin[];

  // Estadísticas
  stats: {
    totalPluginsFound: number;
    duplicatesResolved: number;
    marketplacesScanned: number;
    directPlugins: number;          // plugins sin marketplace
    marketplacePlugins: number;     // plugins de marketplaces
  };

  // Problemas encontrados
  warnings: Warning[];
  errors: Error[];
}
```

### Implementación del Discovery Service

```typescript
interface DiscoveryService {
  /**
   * Descubre todos los plugins de todas las fuentes configuradas
   */
  discoverAll(): Promise<DiscoveryResult>;

  /**
   * Descubre plugins de una fuente específica
   */
  discoverFrom(source: DiscoverySource): Promise<DiscoveredPlugin[]>;

  /**
   * Descubre marketplaces (locales y remotos)
   */
  discoverMarketplaces(): Promise<DiscoveredMarketplace[]>;

  /**
   * Clona y descubre un marketplace remoto
   */
  discoverRemoteMarketplace(url: string): Promise<DiscoveredMarketplace>;

  /**
   * Obtiene las fuentes de discovery configuradas
   */
  getDiscoverySources(): DiscoverySource[];

  /**
   * Resuelve conflictos cuando el mismo plugin aparece en múltiples fuentes
   */
  resolvePluginConflicts(plugins: DiscoveredPlugin[]): DiscoveredPlugin[];
}
```

### Implementación Detallada

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
      cacheTTL: 3600000, // 1 hora
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

    // 1. Obtener todas las fuentes de discovery
    result.sources = this.getDiscoverySources();

    // 2. Descubrir marketplaces (locales y remotos)
    result.marketplaces = await this.discoverMarketplaces();
    result.stats.marketplacesScanned = result.marketplaces.length;

    // 3. Descubrir plugins de cada fuente
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

    // 4. Descubrir plugins de marketplaces
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

    // 5. Resolver duplicados
    result.stats.totalPluginsFound = allPlugins.length;
    result.plugins = this.resolvePluginConflicts(allPlugins);
    result.stats.duplicatesResolved = allPlugins.length - result.plugins.length;

    return result;
  }

  getDiscoverySources(): DiscoverySource[] {
    const sources: DiscoverySource[] = [];

    // 1. Project local plugins (más alta prioridad)
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

    // 3. Local marketplace (en el proyecto actual)
    const projectMarketplace = path.join(process.cwd(), '.claude-plugin', 'marketplace.json');
    if (fs.existsSync(projectMarketplace)) {
      sources.push({
        type: 'marketplace-local',
        path: path.dirname(projectMarketplace),
        priority: 75
      });
    }

    // 4. Remote marketplaces (configurados en settings)
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

  async discoverFrom(source: DiscoverySource): Promise<DiscoveredPlugin[]> {
    switch (source.type) {
      case 'directory':
        return this.discoverFromDirectory(source.path, this.inferSourceType(source.path));

      case 'marketplace-local':
        const localMarketplace = await this.loadLocalMarketplace(source.path);
        return this.discoverFromMarketplace(localMarketplace);

      case 'marketplace-remote':
        const remoteMarketplace = await this.discoverRemoteMarketplace(source.path);
        return this.discoverFromMarketplace(remoteMarketplace);

      default:
        throw new Error(`Unknown source type: ${source.type}`);
    }
  }

  private async discoverFromDirectory(
    dir: string,
    sourceType: 'user' | 'project'
  ): Promise<DiscoveredPlugin[]> {
    const plugins: DiscoveredPlugin[] = [];

    // Escanear subdirectorios buscando plugin.json
    const entries = await fs.readdir(dir, { withFileTypes: true });

    for (const entry of entries) {
      if (!entry.isDirectory()) continue;

      const pluginDir = path.join(dir, entry.name);
      const manifestPath = path.join(pluginDir, '.claude-plugin', 'plugin.json');

      if (await fs.pathExists(manifestPath)) {
        try {
          const manifest = await fs.readJSON(manifestPath);

          plugins.push({
            id: manifest.name || entry.name,
            name: manifest.name || entry.name,
            version: manifest.version || '0.0.0',
            path: pluginDir,
            sourceType,
            sourcePath: dir,
            manifest,
            discovered: new Date()
          });
        } catch (error) {
          // Log warning pero continuar
          console.warn(`Failed to load plugin from ${pluginDir}:`, error.message);
        }
      }
    }

    return plugins;
  }

  async discoverMarketplaces(): Promise<DiscoveredMarketplace[]> {
    const marketplaces: DiscoveredMarketplace[] = [];

    // 1. Local marketplace (en proyecto actual)
    const projectMarketplacePath = path.join(process.cwd(), '.claude-plugin', 'marketplace.json');
    if (await fs.pathExists(projectMarketplacePath)) {
      const marketplace = await this.loadLocalMarketplace(path.dirname(projectMarketplacePath));
      marketplaces.push(marketplace);
    }

    // 2. Remote marketplaces (ya clonados)
    const marketplacesDir = this.config.marketplacesDir;
    if (await fs.pathExists(marketplacesDir)) {
      const entries = await fs.readdir(marketplacesDir, { withFileTypes: true });

      for (const entry of entries) {
        if (!entry.isDirectory()) continue;

        const marketplacePath = path.join(marketplacesDir, entry.name);
        const manifestPath = path.join(marketplacePath, '.claude-plugin', 'marketplace.json');

        if (await fs.pathExists(manifestPath)) {
          const marketplace = await this.loadLocalMarketplace(marketplacePath);
          marketplace.isRemote = true;

          // Intentar obtener URL remota de git
          const gitRemote = await this.gitClient.getRemoteUrl(marketplacePath);
          if (gitRemote) {
            marketplace.remoteUrl = gitRemote;
          }

          marketplaces.push(marketplace);
        }
      }
    }

    return marketplaces;
  }

  async discoverRemoteMarketplace(url: string): Promise<DiscoveredMarketplace> {
    // 1. Verificar si ya está en caché
    const cacheKey = this.cache.getMarketplaceCacheKey(url);
    const cached = await this.cache.get(cacheKey);

    if (cached && !this.cache.isStale(cached)) {
      return cached.data;
    }

    // 2. Clonar repositorio
    const marketplaceName = this.extractMarketplaceName(url);
    const localPath = path.join(this.config.marketplacesDir, marketplaceName);

    if (await fs.pathExists(localPath)) {
      // Ya existe, hacer pull
      await this.gitClient.pull(localPath);
    } else {
      // Clonar por primera vez
      await fs.ensureDir(this.config.marketplacesDir);
      await this.gitClient.clone(url, localPath);
    }

    // 3. Cargar marketplace
    const marketplace = await this.loadLocalMarketplace(localPath);
    marketplace.isRemote = true;
    marketplace.remoteUrl = url;
    marketplace.lastUpdated = new Date();

    // 4. Cachear
    await this.cache.set(cacheKey, marketplace);

    return marketplace;
  }

  private async loadLocalMarketplace(marketplacePath: string): Promise<DiscoveredMarketplace> {
    const manifestPath = path.join(marketplacePath, '.claude-plugin', 'marketplace.json');
    const manifest = await fs.readJSON(manifestPath);

    return {
      name: manifest.name,
      path: marketplacePath,
      isRemote: false,
      manifest,
      plugins: manifest.plugins || [],
      discovered: new Date()
    };
  }

  private async discoverFromMarketplace(
    marketplace: DiscoveredMarketplace
  ): Promise<DiscoveredPlugin[]> {
    const plugins: DiscoveredPlugin[] = [];

    for (const pluginRef of marketplace.plugins) {
      try {
        // Resolver ruta del plugin (puede ser relativa o absoluta)
        let pluginPath: string;

        if (path.isAbsolute(pluginRef.source)) {
          pluginPath = pluginRef.source;
        } else {
          pluginPath = path.join(marketplace.path, pluginRef.source);
        }

        // Verificar que existe
        if (!await fs.pathExists(pluginPath)) {
          console.warn(`Plugin path not found: ${pluginPath}`);
          continue;
        }

        // Cargar manifest del plugin (si existe)
        const manifestPath = path.join(pluginPath, '.claude-plugin', 'plugin.json');
        let manifest: PluginManifest;

        if (await fs.pathExists(manifestPath)) {
          manifest = await fs.readJSON(manifestPath);
        } else if (!marketplace.manifest.strict) {
          // Si strict=false, usar data del marketplace como manifest
          manifest = {
            name: pluginRef.name,
            version: pluginRef.version || '0.0.0',
            description: pluginRef.description,
            ...pluginRef as any
          };
        } else {
          console.warn(`Plugin manifest not found and strict mode enabled: ${pluginPath}`);
          continue;
        }

        plugins.push({
          id: manifest.name || pluginRef.name,
          name: manifest.name || pluginRef.name,
          version: manifest.version || pluginRef.version || '0.0.0',
          path: pluginPath,
          sourceType: 'marketplace',
          sourcePath: marketplace.path,
          marketplace: marketplace.name,
          manifest,
          discovered: new Date()
        });
      } catch (error) {
        console.error(`Failed to discover plugin ${pluginRef.name}:`, error);
      }
    }

    return plugins;
  }

  resolvePluginConflicts(plugins: DiscoveredPlugin[]): DiscoveredPlugin[] {
    // Agrupar por ID (nombre del plugin)
    const grouped = new Map<string, DiscoveredPlugin[]>();

    for (const plugin of plugins) {
      if (!grouped.has(plugin.id)) {
        grouped.set(plugin.id, []);
      }
      grouped.get(plugin.id)!.push(plugin);
    }

    // Para cada grupo, seleccionar uno según prioridad
    const resolved: DiscoveredPlugin[] = [];

    for (const [id, candidates] of grouped) {
      if (candidates.length === 1) {
        resolved.push(candidates[0]);
        continue;
      }

      // Múltiples candidatos - resolver por prioridad
      const sorted = candidates.sort((a, b) => {
        const priorityA = this.getSourcePriority(a.sourceType);
        const priorityB = this.getSourcePriority(b.sourceType);
        return priorityB - priorityA; // Mayor primero
      });

      resolved.push(sorted[0]);

      console.log(`Plugin "${id}" found in multiple sources, using: ${sorted[0].sourcePath}`);
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

  private inferSourceType(sourcePath: string): 'user' | 'project' {
    if (sourcePath.startsWith(os.homedir())) {
      return 'user';
    }
    return 'project';
  }

  private extractMarketplaceName(url: string): string {
    // De "https://github.com/user/repo.git" → "user-repo"
    const match = url.match(/([^/]+)\/([^/]+?)(?:\.git)?$/);
    if (match) {
      return `${match[1]}-${match[2]}`;
    }
    return url.replace(/[^a-zA-Z0-9-]/g, '-');
  }

  private getConfiguredRemoteMarketplaces(): Array<{ url: string }> {
    // TODO: Leer de ~/.claude/settings.json o configuración
    return [];
  }
}
```

### Cliente Git Simplificado

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

---

## Soporte para Repositorios Remotos

### Flujo Completo

```
1. Usuario ejecuta:
   → claude-curator add-marketplace https://github.com/user/plugins.git

2. DiscoveryService.discoverRemoteMarketplace()
   ↓
   a. Verificar caché local
   b. Si no existe: git clone a ~/.claude/marketplaces/user-plugins/
   c. Si existe: git pull para actualizar
   ↓
3. Cargar marketplace.json del repositorio clonado
   ↓
4. Resolver plugins referenciados:
   marketplace.json:
   {
     "plugins": [
       { "name": "plugin-a", "source": "./plugins/plugin-a" },
       { "name": "plugin-b", "source": "./plugins/plugin-b" }
     ]
   }
   ↓
5. Para cada plugin:
   → Ruta completa: ~/.claude/marketplaces/user-plugins/plugins/plugin-a/
   → Cargar .claude-plugin/plugin.json
   → Agregar a DiscoveredPlugin[]
   ↓
6. Retornar lista de plugins descubiertos
```

### Manejo de Actualizaciones

```typescript
interface MarketplaceUpdateManager {
  /**
   * Verifica si hay actualizaciones en marketplaces remotos
   */
  checkForUpdates(): Promise<MarketplaceUpdate[]>;

  /**
   * Actualiza un marketplace específico
   */
  updateMarketplace(marketplaceName: string): Promise<void>;

  /**
   * Actualiza todos los marketplaces remotos
   */
  updateAll(): Promise<void>;
}

interface MarketplaceUpdate {
  marketplace: string;
  currentCommit: string;
  latestCommit: string;
  pluginsAdded: string[];
  pluginsRemoved: string[];
  pluginsUpdated: string[];
}

class MarketplaceUpdateManagerImpl implements MarketplaceUpdateManager {
  async checkForUpdates(): Promise<MarketplaceUpdate[]> {
    const updates: MarketplaceUpdate[] = [];
    const marketplaces = await this.discoveryService.discoverMarketplaces();

    for (const marketplace of marketplaces.filter(m => m.isRemote)) {
      const currentCommit = await this.gitClient.getCommitHash(marketplace.path);

      // Fetch para ver si hay cambios
      await this.gitClient.fetch(marketplace.path);
      const latestCommit = await this.gitClient.getRemoteCommitHash(marketplace.path);

      if (currentCommit !== latestCommit) {
        // Hay actualizaciones
        const diff = await this.analyzeMarketplaceDiff(marketplace, currentCommit, latestCommit);
        updates.push({
          marketplace: marketplace.name,
          currentCommit,
          latestCommit,
          ...diff
        });
      }
    }

    return updates;
  }

  async updateMarketplace(marketplaceName: string): Promise<void> {
    const marketplace = await this.findMarketplaceByName(marketplaceName);
    if (!marketplace || !marketplace.isRemote) {
      throw new Error(`Remote marketplace "${marketplaceName}" not found`);
    }

    // Git pull
    await this.gitClient.pull(marketplace.path);

    // Invalidar caché
    await this.cache.invalidate(marketplace.name);

    // Re-discovery
    await this.discoveryService.discoverMarketplaces();
  }
}
```

---

## Interfaces y Modelos de Datos

### Archivo de Configuración

```typescript
// ~/.claude/curator.config.json
interface CuratorConfig {
  discovery: {
    sources: DiscoverySourceConfig[];
    cache: {
      enabled: boolean;
      ttl: number;              // milisegundos
      path?: string;            // ruta al directorio de caché
    };
    remoteMarketplaces: RemoteMarketplaceConfig[];
  };

  indexing: {
    parallel: boolean;
    maxConcurrency: number;
  };
}

interface DiscoverySourceConfig {
  type: 'directory' | 'marketplace';
  path: string;
  enabled: boolean;
  priority?: number;
}

interface RemoteMarketplaceConfig {
  name: string;
  url: string;
  enabled: boolean;
  autoUpdate: boolean;          // auto-update en cada discovery
  updateInterval?: number;      // milisegundos
}
```

### Ejemplo de Configuración

```json
{
  "discovery": {
    "sources": [
      {
        "type": "directory",
        "path": "~/.claude/plugins",
        "enabled": true,
        "priority": 50
      },
      {
        "type": "directory",
        "path": "./.claude/plugins",
        "enabled": true,
        "priority": 100
      }
    ],
    "cache": {
      "enabled": true,
      "ttl": 3600000,
      "path": "~/.claude/curator/cache"
    },
    "remoteMarketplaces": [
      {
        "name": "jeremylongshore-plugins",
        "url": "https://github.com/jeremylongshore/claude-code-plugins-plus.git",
        "enabled": true,
        "autoUpdate": false,
        "updateInterval": 86400000
      },
      {
        "name": "ccplugins-marketplace",
        "url": "https://github.com/ccplugins/marketplace.git",
        "enabled": true,
        "autoUpdate": true
      }
    ]
  },
  "indexing": {
    "parallel": true,
    "maxConcurrency": 5
  }
}
```

---

## Ejemplos de Uso

### 1. Discovery Básico

```typescript
const discoveryService = new DiscoveryServiceImpl();

// Descubrir todos los plugins
const result = await discoveryService.discoverAll();

console.log(`Found ${result.plugins.length} plugins`);
console.log(`  - ${result.stats.directPlugins} direct plugins`);
console.log(`  - ${result.stats.marketplacePlugins} marketplace plugins`);
console.log(`  - ${result.stats.duplicatesResolved} duplicates resolved`);

// Listar plugins
for (const plugin of result.plugins) {
  console.log(`- ${plugin.name} v${plugin.version}`);
  console.log(`  Source: ${plugin.sourceType} (${plugin.sourcePath})`);
  if (plugin.marketplace) {
    console.log(`  Marketplace: ${plugin.marketplace}`);
  }
}
```

### 2. Agregar Marketplace Remoto

```typescript
// Agregar marketplace desde GitHub
const marketplace = await discoveryService.discoverRemoteMarketplace(
  'https://github.com/jeremylongshore/claude-code-plugins-plus.git'
);

console.log(`Added marketplace: ${marketplace.name}`);
console.log(`  Plugins available: ${marketplace.plugins.length}`);

// Descubrir plugins del marketplace
const plugins = await discoveryService.discoverFromMarketplace(marketplace);

console.log(`Discovered ${plugins.length} plugins from ${marketplace.name}`);
for (const plugin of plugins) {
  console.log(`  - ${plugin.name}: ${plugin.manifest.description}`);
}
```

### 3. Búsqueda de Plugins

```typescript
// Buscar plugins por nombre
function searchPlugins(query: string, plugins: DiscoveredPlugin[]): DiscoveredPlugin[] {
  const lowerQuery = query.toLowerCase();
  return plugins.filter(p =>
    p.name.toLowerCase().includes(lowerQuery) ||
    p.manifest.description?.toLowerCase().includes(lowerQuery) ||
    p.manifest.keywords?.some(k => k.toLowerCase().includes(lowerQuery))
  );
}

const result = await discoveryService.discoverAll();
const securityPlugins = searchPlugins('security', result.plugins);

console.log(`Found ${securityPlugins.length} security-related plugins`);
```

### 4. Actualizar Marketplaces

```typescript
const updateManager = new MarketplaceUpdateManagerImpl(discoveryService);

// Verificar actualizaciones
const updates = await updateManager.checkForUpdates();

if (updates.length > 0) {
  console.log(`${updates.length} marketplace(s) have updates:`);

  for (const update of updates) {
    console.log(`\n${update.marketplace}:`);
    console.log(`  Current: ${update.currentCommit.substring(0, 7)}`);
    console.log(`  Latest: ${update.latestCommit.substring(0, 7)}`);

    if (update.pluginsAdded.length > 0) {
      console.log(`  + Added: ${update.pluginsAdded.join(', ')}`);
    }
    if (update.pluginsRemoved.length > 0) {
      console.log(`  - Removed: ${update.pluginsRemoved.join(', ')}`);
    }
    if (update.pluginsUpdated.length > 0) {
      console.log(`  ↻ Updated: ${update.pluginsUpdated.join(', ')}`);
    }
  }

  // Actualizar todos
  await updateManager.updateAll();
  console.log('\nAll marketplaces updated!');
}
```

### 5. CLI de Usuario

```bash
# Descubrir e indexar todos los plugins
claude-curator discover

# Output:
# ✓ Discovered 25 plugins from 3 sources
#   - 5 direct plugins (~/.claude/plugins)
#   - 8 direct plugins (./.claude/plugins)
#   - 12 marketplace plugins (2 marketplaces)
# ✓ Indexed 247 components
#   - 89 commands
#   - 45 agents
#   - 78 skills
#   - 23 hooks
#   - 12 MCP servers

# Agregar marketplace remoto
claude-curator add-marketplace https://github.com/user/plugins.git

# Output:
# ✓ Cloning marketplace from GitHub...
# ✓ Marketplace "user-plugins" added
# ✓ Found 10 plugins in marketplace

# Listar marketplaces
claude-curator list-marketplaces

# Output:
# Marketplaces (3):
#
# 1. claude-market-place (local)
#    Path: /home/user/projects/claude-market-place
#    Plugins: 10
#
# 2. jeremylongshore-plugins (remote)
#    URL: https://github.com/jeremylongshore/claude-code-plugins-plus.git
#    Path: ~/.claude/marketplaces/jeremylongshore-plugins
#    Plugins: 20
#    Last updated: 2025-11-10

# Actualizar marketplaces
claude-curator update-marketplaces

# Output:
# Checking for updates...
# ✓ jeremylongshore-plugins: Up to date
# ✓ ccplugins-marketplace: 3 new plugins available
#   + devops-automation-pack
#   + ai-ml-engineering-pack
#   + testing-toolkit
#
# Update marketplaces? [Y/n] y
# ✓ Updated ccplugins-marketplace
```

---

## Comparación: Antes vs Después

### ❌ Antes (Especificación Original)

```typescript
// Ambiguo: ¿Es marketplace o plugin?
interface PluginSource {
  name: string;
  path: string;
  type: 'user' | 'project' | 'marketplace';
  manifest: PluginManifest;  // ¿Qué manifest?
  discovered: Date;
}

// No hay distinción clara entre marketplace y plugin
async function discoverAll(): Promise<PluginSource[]> {
  // ¿Cómo saber si es marketplace o plugin?
  // ¿Cómo manejar plugins dentro de marketplaces?
}
```

### ✅ Después (Especificación Clarificada)

```typescript
// Claro: Representan conceptos diferentes
interface DiscoveredMarketplace {
  name: string;
  path: string;
  isRemote: boolean;
  remoteUrl?: string;
  manifest: MarketplaceManifest;  // ← Específico
  plugins: MarketplacePluginRef[];
}

interface DiscoveredPlugin {
  id: string;
  name: string;
  path: string;
  sourceType: 'user' | 'project' | 'marketplace';
  marketplace?: string;           // ← Si viene de marketplace
  manifest: PluginManifest;       // ← Específico
}

// Distinción clara en el resultado
interface DiscoveryResult {
  marketplaces: DiscoveredMarketplace[];  // ← Índices
  plugins: DiscoveredPlugin[];            // ← Contenido real
}
```

---

## Resumen de Cambios Clave

### 1. Conceptos Separados
- **Marketplace**: Índice/catálogo (marketplace.json)
- **Plugin**: Unidad de funcionalidad (plugin.json)

### 2. Jerarquía Clara
```
Marketplace (índice)
    └── plugins[] (referencias)
        └── Plugin (directorio con .claude-plugin/plugin.json)
            └── Components (commands, agents, skills, hooks, MCPs)
```

### 3. Tipos de Fuentes
1. **Directorios directos**: `~/.claude/plugins/`
2. **Marketplaces locales**: `project/.claude-plugin/marketplace.json`
3. **Marketplaces remotos**: `https://github.com/user/marketplace.git`

### 4. Flujo de Discovery
```
Scan Sources
    ↓
Discover Marketplaces
    ↓
Discover Plugins (directos + de marketplaces)
    ↓
Resolver Duplicados
    ↓
Index Components
```

### 5. Soporte Remoto
- Clonar repositorios Git/GitHub
- Caché local en `~/.claude/marketplaces/`
- Actualizaciones con `git pull`
- Tracking de commits para versioning

---

## Próximos Pasos

1. **Actualizar SPEC-PLUGIN-CURATOR.md**
   - Reemplazar `PluginSource` con `DiscoveredPlugin` y `DiscoveredMarketplace`
   - Agregar sección de repositorios remotos
   - Actualizar algoritmos de discovery

2. **Implementar GitClient**
   - Wrapper sobre comandos Git
   - Manejo de errores y autenticación
   - Soporte para SSH y HTTPS

3. **Implementar DiscoveryCache**
   - Caché de marketplaces remotos
   - TTL configurable
   - Invalidación inteligente

4. **CLI Commands**
   - `discover` - Discovery básico
   - `add-marketplace <url>` - Agregar marketplace remoto
   - `list-marketplaces` - Listar marketplaces
   - `update-marketplaces` - Actualizar remotos

5. **Testing**
   - Unit tests para cada service
   - Integration tests con repos remotos reales
   - Fixtures para testing offline

---

**Documento creado:** 2025-11-11
**Última actualización:** 2025-11-11
**Estado:** ✅ Listo para implementación
