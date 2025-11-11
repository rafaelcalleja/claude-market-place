# Tasks: Phase 1 - Discovery CLI Implementation

**Fecha:** 2025-11-11
**Objetivo:** Desarrollar CLI funcional con sistema de discovery completo (local + remoto)
**Duración Estimada:** 2 semanas (10 días laborables)
**Basado en:** SPEC-PLUGIN-CURATOR.md + CLARIFICATION-DISCOVERY-SERVICE.md

---

## Índice

1. [Visión General](#visión-general)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Tareas Detalladas](#tareas-detalladas)
4. [Criterios de Aceptación](#criterios-de-aceptación)
5. [Testing Strategy](#testing-strategy)
6. [Orden de Implementación](#orden-de-implementación)

---

## Visión General

### Objetivo de la Fase
Crear un CLI funcional (`claude-curator`) que pueda:
- ✅ Descubrir plugins de directorios locales
- ✅ Descubrir marketplaces locales
- ✅ Clonar y descubrir marketplaces remotos (Git/GitHub)
- ✅ Listar plugins y marketplaces
- ✅ Buscar plugins por nombre/keywords
- ✅ Mostrar detalles de plugins
- ✅ Gestionar marketplaces remotos

### Deliverables
- [ ] CLI ejecutable: `claude-curator`
- [ ] Comandos implementados: `discover`, `list`, `search`, `show`, `add-marketplace`, `list-marketplaces`
- [ ] Discovery Service completo con soporte local + remoto
- [ ] Git Client para operaciones remotas
- [ ] Sistema de caché para marketplaces
- [ ] 80%+ test coverage
- [ ] Documentación de usuario

---

## Estructura del Proyecto

### Directorio Target

```
claude-curator/
├── package.json
├── tsconfig.json
├── .eslintrc.json
├── .prettierrc
├── README.md
├── LICENSE
│
├── src/
│   ├── index.ts                      # Entry point
│   ├── cli/
│   │   ├── index.ts                  # CLI setup (Commander.js)
│   │   ├── commands/
│   │   │   ├── discover.ts           # discover command
│   │   │   ├── list.ts               # list command
│   │   │   ├── search.ts             # search command
│   │   │   ├── show.ts               # show command
│   │   │   ├── add-marketplace.ts    # add-marketplace command
│   │   │   └── list-marketplaces.ts  # list-marketplaces command
│   │   └── output/
│   │       ├── formatter.ts          # Output formatting
│   │       ├── table.ts              # Table display
│   │       └── logger.ts             # CLI logging
│   │
│   ├── core/
│   │   ├── discovery/
│   │   │   ├── DiscoveryService.ts
│   │   │   ├── PluginScanner.ts
│   │   │   ├── MarketplaceScanner.ts
│   │   │   └── DiscoveryCache.ts
│   │   └── git/
│   │       ├── GitClient.ts
│   │       └── GitError.ts
│   │
│   ├── utils/
│   │   ├── FileOperations.ts
│   │   ├── PathResolver.ts
│   │   ├── HashUtils.ts
│   │   ├── Logger.ts
│   │   └── Config.ts
│   │
│   ├── types/
│   │   ├── index.ts
│   │   ├── Discovery.ts
│   │   ├── Plugin.ts
│   │   ├── Marketplace.ts
│   │   └── Config.ts
│   │
│   └── schemas/
│       ├── plugin.schema.json
│       └── marketplace.schema.json
│
├── tests/
│   ├── unit/
│   │   ├── discovery/
│   │   ├── git/
│   │   └── utils/
│   ├── integration/
│   │   ├── cli/
│   │   └── discovery/
│   ├── fixtures/
│   │   ├── plugins/
│   │   └── marketplaces/
│   └── helpers/
│       └── test-utils.ts
│
├── docs/
│   ├── cli-reference.md
│   ├── getting-started.md
│   └── examples.md
│
└── examples/
    ├── basic-discovery.ts
    └── remote-marketplace.ts
```

---

## Tareas Detalladas

### Sprint 1: Semana 1 (Días 1-5) - Foundation & Core Discovery

---

#### **Día 1: Configuración del Proyecto** (6-8 horas)

##### Task 1.1: Inicializar Proyecto Node.js/TypeScript
**Prioridad:** 🔴 Alta | **Estimación:** 2h

```bash
# Tareas específicas:
- [ ] Crear directorio claude-curator/
- [ ] npm init -y
- [ ] Instalar TypeScript: npm install -D typescript @types/node
- [ ] Crear tsconfig.json con configuración strict
- [ ] Configurar build script en package.json
- [ ] Verificar compilación: npm run build
```

**tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

**Criterio de Aceptación:**
- ✅ `npm run build` compila sin errores
- ✅ Genera archivos .d.ts y .js en dist/

---

##### Task 1.2: Configurar Linting y Formatting
**Prioridad:** 🔴 Alta | **Estimación:** 1h

```bash
# Instalar dependencias
- [ ] npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
- [ ] npm install -D prettier eslint-config-prettier eslint-plugin-prettier
- [ ] Crear .eslintrc.json
- [ ] Crear .prettierrc
- [ ] Agregar scripts: lint, format
- [ ] Ejecutar: npm run lint
```

**.eslintrc.json:**
```json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2020,
    "sourceType": "module"
  },
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/explicit-function-return-type": "off",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }]
  }
}
```

**Criterio de Aceptación:**
- ✅ `npm run lint` ejecuta sin errores
- ✅ `npm run format` formatea código correctamente

---

##### Task 1.3: Configurar Testing con Vitest
**Prioridad:** 🔴 Alta | **Estimación:** 2h

```bash
# Instalar vitest
- [ ] npm install -D vitest @vitest/ui
- [ ] Crear vitest.config.ts
- [ ] Crear tests/helpers/test-utils.ts
- [ ] Agregar scripts: test, test:watch, test:ui, test:coverage
- [ ] Crear test de ejemplo
- [ ] Ejecutar: npm test
```

**vitest.config.ts:**
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['tests/**', 'dist/**', '**/*.d.ts']
    }
  }
});
```

**Criterio de Aceptación:**
- ✅ `npm test` ejecuta tests
- ✅ `npm run test:coverage` genera reporte
- ✅ Test de ejemplo pasa

---

##### Task 1.4: Configurar Husky + Lint-Staged
**Prioridad:** 🟡 Media | **Estimación:** 1h

```bash
# Pre-commit hooks
- [ ] npm install -D husky lint-staged
- [ ] npx husky-init
- [ ] Configurar lint-staged en package.json
- [ ] Crear pre-commit hook: lint + test
- [ ] Probar: git commit
```

**package.json (partial):**
```json
{
  "lint-staged": {
    "*.ts": [
      "eslint --fix",
      "prettier --write",
      "vitest related --run"
    ]
  }
}
```

**Criterio de Aceptación:**
- ✅ Pre-commit ejecuta lint + test automáticamente
- ✅ Commit bloqueado si hay errores

---

##### Task 1.5: Crear Estructura de Directorios
**Prioridad:** 🔴 Alta | **Estimación:** 30min

```bash
# Crear estructura completa
- [ ] mkdir -p src/{cli/commands,cli/output,core/discovery,core/git,utils,types,schemas}
- [ ] mkdir -p tests/{unit,integration,fixtures,helpers}
- [ ] mkdir -p docs examples
- [ ] Crear archivos index.ts vacíos
- [ ] Verificar estructura con tree
```

**Criterio de Aceptación:**
- ✅ Estructura de directorios completa
- ✅ Todos los archivos index.ts creados

---

##### Task 1.6: Configurar Package.json Completo
**Prioridad:** 🔴 Alta | **Estimación:** 1h

```json
{
  "name": "claude-curator",
  "version": "0.1.0",
  "description": "Plugin curator and marketplace builder for Claude Code",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "bin": {
    "claude-curator": "./dist/index.js"
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage",
    "clean": "rm -rf dist",
    "prepublishOnly": "npm run clean && npm run build && npm test",
    "link": "npm link"
  },
  "keywords": ["claude", "claude-code", "plugin", "curator", "marketplace"],
  "author": "Your Name",
  "license": "MIT",
  "dependencies": {
    "commander": "^11.1.0",
    "chalk": "^5.3.0",
    "ora": "^7.0.1",
    "fs-extra": "^11.2.0",
    "fast-glob": "^3.3.2",
    "minimatch": "^9.0.3",
    "js-yaml": "^4.1.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "@types/fs-extra": "^11.0.4",
    "@types/js-yaml": "^4.0.9",
    "typescript": "^5.3.3",
    "vitest": "^1.0.4",
    "@vitest/ui": "^1.0.4",
    "eslint": "^8.56.0",
    "@typescript-eslint/parser": "^6.15.0",
    "@typescript-eslint/eslint-plugin": "^6.15.0",
    "prettier": "^3.1.1",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-prettier": "^5.0.1",
    "husky": "^8.0.3",
    "lint-staged": "^15.2.0"
  }
}
```

**Tareas:**
```bash
- [ ] Instalar todas las dependencias: npm install
- [ ] Verificar bin ejecutable: chmod +x dist/index.js (después de build)
- [ ] Probar link local: npm link && claude-curator --version
```

**Criterio de Aceptación:**
- ✅ Todas las dependencias instaladas sin conflictos
- ✅ Scripts funcionan correctamente

---

#### **Día 2: TypeScript Types & Core Utilities** (6-8 horas)

##### Task 2.1: Definir Types/Interfaces Core
**Prioridad:** 🔴 Alta | **Estimación:** 2h

**src/types/Discovery.ts:**
```typescript
export interface DiscoverySource {
  type: 'directory' | 'marketplace-local' | 'marketplace-remote';
  path: string;
  priority: number;
}

export interface DiscoveredPlugin {
  id: string;
  name: string;
  version: string;
  path: string;
  sourceType: 'user' | 'project' | 'marketplace';
  sourcePath: string;
  manifest: PluginManifest;
  marketplace?: string;
  discovered: Date;
  hash?: string;
}

export interface DiscoveredMarketplace {
  name: string;
  path: string;
  isRemote: boolean;
  remoteUrl?: string;
  manifest: MarketplaceManifest;
  plugins: MarketplacePluginRef[];
  discovered: Date;
  lastUpdated?: Date;
}

export interface MarketplacePluginRef {
  name: string;
  source: string;
  version?: string;
  description?: string;
}

export interface DiscoveryResult {
  sources: DiscoverySource[];
  marketplaces: DiscoveredMarketplace[];
  plugins: DiscoveredPlugin[];
  stats: DiscoveryStats;
  warnings: Warning[];
  errors: Error[];
}

export interface DiscoveryStats {
  totalPluginsFound: number;
  duplicatesResolved: number;
  marketplacesScanned: number;
  directPlugins: number;
  marketplacePlugins: number;
}

export interface Warning {
  type: string;
  message: string;
  details?: any;
}
```

**src/types/Plugin.ts:**
```typescript
export interface PluginManifest {
  name: string;
  version: string;
  description?: string;
  author?: {
    name: string;
    email?: string;
    url?: string;
  };
  homepage?: string;
  repository?: string;
  keywords?: string[];
  hooks?: string;
  mcpServers?: string;
  commands?: string[];
  agents?: string[];
  skills?: string[];
}
```

**src/types/Marketplace.ts:**
```typescript
export interface MarketplaceManifest {
  name: string;
  metadata?: {
    description?: string;
    version?: string;
  };
  owner?: {
    name: string;
    email?: string;
  };
  plugins: MarketplacePluginEntry[];
  strict?: boolean;
}

export interface MarketplacePluginEntry {
  name: string;
  source: string;
  description?: string;
  version?: string;
  author?: {
    name: string;
    email?: string;
    url?: string;
  };
  category?: string;
  keywords?: string[];
  license?: string;
  homepage?: string;
}
```

**src/types/Config.ts:**
```typescript
export interface DiscoveryConfig {
  userPluginsDir: string;
  projectPluginsDir: string;
  marketplacesDir: string;
  enableCache: boolean;
  cacheTTL: number;
  remoteMarketplaces: RemoteMarketplaceConfig[];
}

export interface RemoteMarketplaceConfig {
  name: string;
  url: string;
  enabled: boolean;
  autoUpdate: boolean;
  updateInterval?: number;
}

export interface CuratorConfig {
  discovery: DiscoveryConfig;
}
```

**Tareas:**
```bash
- [ ] Crear todos los archivos de types
- [ ] Crear src/types/index.ts exportando todos
- [ ] Verificar compilación: npm run build
- [ ] Crear tests básicos de types (validación TypeScript)
```

**Criterio de Aceptación:**
- ✅ Todos los types compilan sin errores
- ✅ Exports correctos desde index.ts
- ✅ No hay tipos `any` sin justificar

---

##### Task 2.2: Implementar FileOperations Utility
**Prioridad:** 🔴 Alta | **Estimación:** 2h

**src/utils/FileOperations.ts:**
```typescript
import * as fs from 'fs-extra';
import * as path from 'path';

export class FileOperations {
  /**
   * Check if path exists
   */
  async exists(filePath: string): Promise<boolean> {
    return fs.pathExists(filePath);
  }

  /**
   * Read JSON file
   */
  async readJSON<T = any>(filePath: string): Promise<T> {
    return fs.readJSON(filePath);
  }

  /**
   * Write JSON file
   */
  async writeJSON(filePath: string, data: any): Promise<void> {
    await fs.writeJSON(filePath, data, { spaces: 2 });
  }

  /**
   * Read directory entries
   */
  async readDir(dirPath: string): Promise<fs.Dirent[]> {
    return fs.readdir(dirPath, { withFileTypes: true });
  }

  /**
   * Ensure directory exists
   */
  async ensureDir(dirPath: string): Promise<void> {
    await fs.ensureDir(dirPath);
  }

  /**
   * Copy file or directory
   */
  async copy(src: string, dest: string): Promise<void> {
    await fs.copy(src, dest);
  }

  /**
   * Remove file or directory
   */
  async remove(pathToRemove: string): Promise<void> {
    await fs.remove(pathToRemove);
  }

  /**
   * Get file stats
   */
  async stat(filePath: string): Promise<fs.Stats> {
    return fs.stat(filePath);
  }
}

export const fileOps = new FileOperations();
```

**tests/unit/utils/FileOperations.test.ts:**
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { FileOperations } from '../../../src/utils/FileOperations';
import * as path from 'path';
import * as fs from 'fs-extra';

describe('FileOperations', () => {
  const fileOps = new FileOperations();
  const testDir = path.join(__dirname, '__test_files__');

  beforeEach(async () => {
    await fs.ensureDir(testDir);
  });

  afterEach(async () => {
    await fs.remove(testDir);
  });

  it('should check if file exists', async () => {
    const testFile = path.join(testDir, 'test.txt');
    await fs.writeFile(testFile, 'test');

    expect(await fileOps.exists(testFile)).toBe(true);
    expect(await fileOps.exists(path.join(testDir, 'nonexistent.txt'))).toBe(false);
  });

  it('should read and write JSON', async () => {
    const testFile = path.join(testDir, 'test.json');
    const data = { name: 'test', version: '1.0.0' };

    await fileOps.writeJSON(testFile, data);
    const read = await fileOps.readJSON(testFile);

    expect(read).toEqual(data);
  });

  // ... más tests
});
```

**Tareas:**
```bash
- [ ] Implementar FileOperations.ts
- [ ] Crear tests unitarios completos
- [ ] Ejecutar tests: npm test
- [ ] Coverage > 90% para esta clase
```

**Criterio de Aceptación:**
- ✅ Todas las operaciones funcionan correctamente
- ✅ Tests pasan con > 90% coverage
- ✅ Manejo de errores implementado

---

##### Task 2.3: Implementar PathResolver Utility
**Prioridad:** 🔴 Alta | **Estimación:** 1h

**src/utils/PathResolver.ts:**
```typescript
import * as path from 'path';
import * as os from 'os';

export class PathResolver {
  /**
   * Resolve home directory (~)
   */
  resolveHome(filePath: string): string {
    if (filePath.startsWith('~/') || filePath === '~') {
      return path.join(os.homedir(), filePath.slice(2));
    }
    return filePath;
  }

  /**
   * Resolve to absolute path
   */
  resolveAbsolute(filePath: string, basePath?: string): string {
    const resolved = this.resolveHome(filePath);

    if (path.isAbsolute(resolved)) {
      return resolved;
    }

    return path.resolve(basePath || process.cwd(), resolved);
  }

  /**
   * Get user plugins directory
   */
  getUserPluginsDir(): string {
    return path.join(os.homedir(), '.claude', 'plugins');
  }

  /**
   * Get project plugins directory
   */
  getProjectPluginsDir(projectPath?: string): string {
    const base = projectPath || process.cwd();
    return path.join(base, '.claude', 'plugins');
  }

  /**
   * Get marketplaces cache directory
   */
  getMarketplacesDir(): string {
    return path.join(os.homedir(), '.claude', 'marketplaces');
  }

  /**
   * Get curator config directory
   */
  getCuratorConfigDir(): string {
    return path.join(os.homedir(), '.claude', 'curator');
  }

  /**
   * Get relative path from base
   */
  getRelativePath(from: string, to: string): string {
    return path.relative(from, to);
  }
}

export const pathResolver = new PathResolver();
```

**tests/unit/utils/PathResolver.test.ts:**
```typescript
import { describe, it, expect } from 'vitest';
import { PathResolver } from '../../../src/utils/PathResolver';
import * as os from 'os';
import * as path from 'path';

describe('PathResolver', () => {
  const resolver = new PathResolver();

  it('should resolve home directory', () => {
    const result = resolver.resolveHome('~/test');
    expect(result).toBe(path.join(os.homedir(), 'test'));
  });

  it('should resolve absolute paths', () => {
    const result = resolver.resolveAbsolute('./test', '/base');
    expect(result).toBe('/base/test');
  });

  it('should get standard directories', () => {
    expect(resolver.getUserPluginsDir()).toContain('.claude/plugins');
    expect(resolver.getMarketplacesDir()).toContain('.claude/marketplaces');
    expect(resolver.getCuratorConfigDir()).toContain('.claude/curator');
  });
});
```

**Tareas:**
```bash
- [ ] Implementar PathResolver.ts
- [ ] Crear tests unitarios
- [ ] Ejecutar tests: npm test
```

**Criterio de Aceptación:**
- ✅ Resolución de paths funciona correctamente
- ✅ Tests pasan
- ✅ Cross-platform compatible (Windows/Linux/macOS)

---

##### Task 2.4: Implementar HashUtils
**Prioridad:** 🟡 Media | **Estimación:** 1h

**src/utils/HashUtils.ts:**
```typescript
import * as crypto from 'crypto';
import * as fs from 'fs-extra';
import * as path from 'path';
import glob from 'fast-glob';

export class HashUtils {
  /**
   * Hash string content
   */
  hashString(content: string): string {
    return crypto.createHash('sha256').update(content).digest('hex');
  }

  /**
   * Hash file content
   */
  async hashFile(filePath: string): Promise<string> {
    const content = await fs.readFile(filePath);
    return crypto.createHash('sha256').update(content).digest('hex');
  }

  /**
   * Hash directory (all files)
   */
  async hashDirectory(dirPath: string): Promise<string> {
    const files = await glob('**/*', {
      cwd: dirPath,
      onlyFiles: true,
      dot: false
    });

    const hash = crypto.createHash('sha256');

    // Sort for consistency
    for (const file of files.sort()) {
      const fullPath = path.join(dirPath, file);
      const content = await fs.readFile(fullPath);
      hash.update(file); // Include filename
      hash.update(content);
    }

    return hash.digest('hex');
  }
}

export const hashUtils = new HashUtils();
```

**tests/unit/utils/HashUtils.test.ts:**
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { HashUtils } from '../../../src/utils/HashUtils';
import * as path from 'path';
import * as fs from 'fs-extra';

describe('HashUtils', () => {
  const hashUtils = new HashUtils();
  const testDir = path.join(__dirname, '__test_hash__');

  beforeEach(async () => {
    await fs.ensureDir(testDir);
  });

  afterEach(async () => {
    await fs.remove(testDir);
  });

  it('should hash string consistently', () => {
    const hash1 = hashUtils.hashString('test');
    const hash2 = hashUtils.hashString('test');
    expect(hash1).toBe(hash2);
    expect(hash1).toHaveLength(64); // SHA256 = 64 hex chars
  });

  it('should hash file', async () => {
    const testFile = path.join(testDir, 'test.txt');
    await fs.writeFile(testFile, 'test content');

    const hash = await hashUtils.hashFile(testFile);
    expect(hash).toHaveLength(64);
  });

  it('should hash directory', async () => {
    await fs.writeFile(path.join(testDir, 'file1.txt'), 'content1');
    await fs.writeFile(path.join(testDir, 'file2.txt'), 'content2');

    const hash = await hashUtils.hashDirectory(testDir);
    expect(hash).toHaveLength(64);
  });
});
```

**Tareas:**
```bash
- [ ] Implementar HashUtils.ts
- [ ] Crear tests unitarios
- [ ] Ejecutar tests: npm test
```

**Criterio de Aceptación:**
- ✅ Hashing consistente
- ✅ Tests pasan
- ✅ Coverage > 80%

---

##### Task 2.5: Implementar Logger Utility
**Prioridad:** 🟡 Media | **Estimación:** 1h

**src/utils/Logger.ts:**
```typescript
import chalk from 'chalk';

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  SILENT = 4
}

export class Logger {
  private level: LogLevel = LogLevel.INFO;

  setLevel(level: LogLevel) {
    this.level = level;
  }

  debug(message: string, ...args: any[]) {
    if (this.level <= LogLevel.DEBUG) {
      console.log(chalk.gray(`[DEBUG] ${message}`), ...args);
    }
  }

  info(message: string, ...args: any[]) {
    if (this.level <= LogLevel.INFO) {
      console.log(chalk.blue(`[INFO] ${message}`), ...args);
    }
  }

  success(message: string, ...args: any[]) {
    if (this.level <= LogLevel.INFO) {
      console.log(chalk.green(`✓ ${message}`), ...args);
    }
  }

  warn(message: string, ...args: any[]) {
    if (this.level <= LogLevel.WARN) {
      console.warn(chalk.yellow(`⚠ ${message}`), ...args);
    }
  }

  error(message: string, error?: Error) {
    if (this.level <= LogLevel.ERROR) {
      console.error(chalk.red(`✖ ${message}`));
      if (error && error.stack) {
        console.error(chalk.red(error.stack));
      }
    }
  }
}

export const logger = new Logger();
```

**Criterio de Aceptación:**
- ✅ Logger funcional con colores
- ✅ Niveles de log funcionan
- ✅ Sin tests necesarios (UI utility)

---

#### **Día 3: Git Client Implementation** (6-8 horas)

##### Task 3.1: Implementar GitClient Core
**Prioridad:** 🔴 Alta | **Estimación:** 3h

**src/core/git/GitError.ts:**
```typescript
export class GitError extends Error {
  constructor(
    message: string,
    public readonly command: string,
    public readonly exitCode?: number,
    public readonly stderr?: string
  ) {
    super(message);
    this.name = 'GitError';
  }
}
```

**src/core/git/GitClient.ts:**
```typescript
import { exec } from 'child_process';
import { promisify } from 'util';
import { GitError } from './GitError';
import { logger } from '../../utils/Logger';

const execPromise = promisify(exec);

export interface GitCloneOptions {
  branch?: string;
  depth?: number;
  quiet?: boolean;
}

export interface GitPullOptions {
  rebase?: boolean;
  quiet?: boolean;
}

export class GitClient {
  /**
   * Clone repository
   */
  async clone(
    url: string,
    targetPath: string,
    options: GitCloneOptions = {}
  ): Promise<void> {
    const args = ['clone'];

    if (options.branch) {
      args.push('--branch', options.branch);
    }

    if (options.depth) {
      args.push('--depth', options.depth.toString());
    }

    if (options.quiet) {
      args.push('--quiet');
    }

    args.push(url, targetPath);

    const command = `git ${args.map(a => `"${a}"`).join(' ')}`;

    try {
      logger.debug(`Executing: ${command}`);
      await execPromise(command);
      logger.success(`Cloned ${url} to ${targetPath}`);
    } catch (error: any) {
      throw new GitError(
        `Failed to clone repository: ${error.message}`,
        command,
        error.code,
        error.stderr
      );
    }
  }

  /**
   * Pull latest changes
   */
  async pull(
    repoPath: string,
    options: GitPullOptions = {}
  ): Promise<void> {
    const args = ['pull'];

    if (options.rebase) {
      args.push('--rebase');
    }

    if (options.quiet) {
      args.push('--quiet');
    }

    const command = `git -C "${repoPath}" ${args.join(' ')}`;

    try {
      logger.debug(`Executing: ${command}`);
      await execPromise(command);
      logger.success(`Pulled latest changes in ${repoPath}`);
    } catch (error: any) {
      throw new GitError(
        `Failed to pull repository: ${error.message}`,
        command,
        error.code,
        error.stderr
      );
    }
  }

  /**
   * Get remote URL
   */
  async getRemoteUrl(repoPath: string): Promise<string | null> {
    const command = `git -C "${repoPath}" remote get-url origin`;

    try {
      const { stdout } = await execPromise(command);
      return stdout.trim();
    } catch (error) {
      logger.debug(`No remote URL found for ${repoPath}`);
      return null;
    }
  }

  /**
   * Get current commit hash
   */
  async getCommitHash(repoPath: string): Promise<string | null> {
    const command = `git -C "${repoPath}" rev-parse HEAD`;

    try {
      const { stdout } = await execPromise(command);
      return stdout.trim();
    } catch (error) {
      logger.debug(`Failed to get commit hash for ${repoPath}`);
      return null;
    }
  }

  /**
   * Check if directory is a git repository
   */
  async isGitRepo(dirPath: string): Promise<boolean> {
    const command = `git -C "${dirPath}" rev-parse --git-dir`;

    try {
      await execPromise(command);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Fetch from remote (without merging)
   */
  async fetch(repoPath: string): Promise<void> {
    const command = `git -C "${repoPath}" fetch`;

    try {
      await execPromise(command);
      logger.debug(`Fetched updates for ${repoPath}`);
    } catch (error: any) {
      throw new GitError(
        `Failed to fetch: ${error.message}`,
        command,
        error.code,
        error.stderr
      );
    }
  }

  /**
   * Get remote commit hash (latest on remote)
   */
  async getRemoteCommitHash(repoPath: string, branch: string = 'main'): Promise<string | null> {
    const command = `git -C "${repoPath}" rev-parse origin/${branch}`;

    try {
      const { stdout } = await execPromise(command);
      return stdout.trim();
    } catch (error) {
      // Try 'master' if 'main' failed
      if (branch === 'main') {
        return this.getRemoteCommitHash(repoPath, 'master');
      }
      logger.debug(`Failed to get remote commit hash for ${repoPath}`);
      return null;
    }
  }
}
```

**Tareas:**
```bash
- [ ] Implementar GitClient.ts completo
- [ ] Implementar GitError.ts
- [ ] Crear index.ts exportando ambos
```

**Criterio de Aceptación:**
- ✅ Todas las operaciones Git implementadas
- ✅ Manejo de errores robusto
- ✅ Logging apropiado

---

##### Task 3.2: Tests de GitClient
**Prioridad:** 🔴 Alta | **Estimación:** 3h

**tests/integration/git/GitClient.test.ts:**
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { GitClient } from '../../../src/core/git/GitClient';
import { GitError } from '../../../src/core/git/GitError';
import * as path from 'path';
import * as fs from 'fs-extra';

describe('GitClient', () => {
  const gitClient = new GitClient();
  const testDir = path.join(__dirname, '__test_git__');

  beforeEach(async () => {
    await fs.ensureDir(testDir);
  });

  afterEach(async () => {
    await fs.remove(testDir);
  });

  it('should clone a repository', async () => {
    const targetPath = path.join(testDir, 'test-repo');

    // Clone a small public repo for testing
    await gitClient.clone(
      'https://github.com/anthropics/claude-code.git',
      targetPath,
      { depth: 1, quiet: true }
    );

    expect(await fs.pathExists(targetPath)).toBe(true);
    expect(await fs.pathExists(path.join(targetPath, '.git'))).toBe(true);
  }, 60000); // 60s timeout for network operation

  it('should detect if directory is git repo', async () => {
    const targetPath = path.join(testDir, 'test-repo');

    await gitClient.clone(
      'https://github.com/anthropics/claude-code.git',
      targetPath,
      { depth: 1, quiet: true }
    );

    expect(await gitClient.isGitRepo(targetPath)).toBe(true);
    expect(await gitClient.isGitRepo(testDir)).toBe(false);
  }, 60000);

  it('should get remote URL', async () => {
    const targetPath = path.join(testDir, 'test-repo');

    await gitClient.clone(
      'https://github.com/anthropics/claude-code.git',
      targetPath,
      { depth: 1, quiet: true }
    );

    const remoteUrl = await gitClient.getRemoteUrl(targetPath);
    expect(remoteUrl).toContain('anthropics/claude-code');
  }, 60000);

  it('should get commit hash', async () => {
    const targetPath = path.join(testDir, 'test-repo');

    await gitClient.clone(
      'https://github.com/anthropics/claude-code.git',
      targetPath,
      { depth: 1, quiet: true }
    );

    const hash = await gitClient.getCommitHash(targetPath);
    expect(hash).toMatch(/^[0-9a-f]{40}$/); // SHA1 hash format
  }, 60000);

  it('should throw GitError on invalid clone', async () => {
    await expect(
      gitClient.clone('https://invalid-url.git', path.join(testDir, 'invalid'))
    ).rejects.toThrow(GitError);
  }, 10000);
});
```

**Tareas:**
```bash
- [ ] Crear tests de integración con repo real
- [ ] Crear tests de error handling
- [ ] Ejecutar tests: npm run test:integration
- [ ] Verificar que todos pasan
```

**Criterio de Aceptación:**
- ✅ Tests de integración pasan
- ✅ Manejo de errores verificado
- ✅ Timeouts apropiados para operaciones de red

---

#### **Día 4-5: Discovery Service Core** (12-16 horas)

##### Task 4.1: Implementar PluginScanner
**Prioridad:** 🔴 Alta | **Estimación:** 4h

**src/core/discovery/PluginScanner.ts:**
```typescript
import { DiscoveredPlugin, PluginManifest } from '../../types';
import { fileOps } from '../../utils/FileOperations';
import { pathResolver } from '../../utils/PathResolver';
import { hashUtils } from '../../utils/HashUtils';
import { logger } from '../../utils/Logger';
import * as path from 'path';

export class PluginScanner {
  /**
   * Scan directory for plugins
   */
  async scanDirectory(
    dirPath: string,
    sourceType: 'user' | 'project' | 'marketplace'
  ): Promise<DiscoveredPlugin[]> {
    if (!await fileOps.exists(dirPath)) {
      logger.debug(`Directory not found: ${dirPath}`);
      return [];
    }

    const plugins: DiscoveredPlugin[] = [];
    const entries = await fileOps.readDir(dirPath);

    for (const entry of entries) {
      if (!entry.isDirectory()) continue;

      const pluginPath = path.join(dirPath, entry.name);
      const plugin = await this.scanPlugin(pluginPath, sourceType, dirPath);

      if (plugin) {
        plugins.push(plugin);
      }
    }

    logger.debug(`Found ${plugins.length} plugins in ${dirPath}`);
    return plugins;
  }

  /**
   * Scan single plugin directory
   */
  async scanPlugin(
    pluginPath: string,
    sourceType: 'user' | 'project' | 'marketplace',
    sourcePath: string,
    marketplace?: string
  ): Promise<DiscoveredPlugin | null> {
    const manifestPath = path.join(pluginPath, '.claude-plugin', 'plugin.json');

    if (!await fileOps.exists(manifestPath)) {
      logger.debug(`No manifest found: ${manifestPath}`);
      return null;
    }

    try {
      const manifest: PluginManifest = await fileOps.readJSON(manifestPath);

      // Validate required fields
      if (!manifest.name) {
        logger.warn(`Plugin manifest missing name: ${manifestPath}`);
        return null;
      }

      // Calculate hash for change detection
      const hash = await hashUtils.hashDirectory(pluginPath);

      const plugin: DiscoveredPlugin = {
        id: manifest.name,
        name: manifest.name,
        version: manifest.version || '0.0.0',
        path: pluginPath,
        sourceType,
        sourcePath,
        manifest,
        marketplace,
        discovered: new Date(),
        hash
      };

      logger.debug(`Scanned plugin: ${plugin.name}@${plugin.version}`);
      return plugin;
    } catch (error: any) {
      logger.error(`Failed to scan plugin at ${pluginPath}`, error);
      return null;
    }
  }
}
```

**tests/unit/discovery/PluginScanner.test.ts:**
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { PluginScanner } from '../../../src/core/discovery/PluginScanner';
import * as path from 'path';
import * as fs from 'fs-extra';

describe('PluginScanner', () => {
  const scanner = new PluginScanner();
  const testDir = path.join(__dirname, '__test_plugins__');

  beforeEach(async () => {
    await fs.ensureDir(testDir);
  });

  afterEach(async () => {
    await fs.remove(testDir);
  });

  async function createTestPlugin(name: string) {
    const pluginDir = path.join(testDir, name);
    await fs.ensureDir(path.join(pluginDir, '.claude-plugin'));
    await fs.writeJSON(path.join(pluginDir, '.claude-plugin', 'plugin.json'), {
      name,
      version: '1.0.0',
      description: `Test plugin ${name}`
    });
    return pluginDir;
  }

  it('should scan directory and find plugins', async () => {
    await createTestPlugin('plugin1');
    await createTestPlugin('plugin2');

    const plugins = await scanner.scanDirectory(testDir, 'user');

    expect(plugins).toHaveLength(2);
    expect(plugins[0].name).toBe('plugin1');
    expect(plugins[1].name).toBe('plugin2');
  });

  it('should scan single plugin', async () => {
    const pluginPath = await createTestPlugin('test-plugin');

    const plugin = await scanner.scanPlugin(pluginPath, 'user', testDir);

    expect(plugin).not.toBeNull();
    expect(plugin!.name).toBe('test-plugin');
    expect(plugin!.version).toBe('1.0.0');
    expect(plugin!.hash).toHaveLength(64);
  });

  it('should return null for directory without manifest', async () => {
    const emptyDir = path.join(testDir, 'empty');
    await fs.ensureDir(emptyDir);

    const plugin = await scanner.scanPlugin(emptyDir, 'user', testDir);

    expect(plugin).toBeNull();
  });

  it('should handle invalid JSON gracefully', async () => {
    const pluginDir = path.join(testDir, 'invalid');
    await fs.ensureDir(path.join(pluginDir, '.claude-plugin'));
    await fs.writeFile(
      path.join(pluginDir, '.claude-plugin', 'plugin.json'),
      'invalid json'
    );

    const plugin = await scanner.scanPlugin(pluginDir, 'user', testDir);

    expect(plugin).toBeNull();
  });
});
```

**Tareas:**
```bash
- [ ] Implementar PluginScanner.ts
- [ ] Crear tests unitarios completos
- [ ] Ejecutar tests: npm test
- [ ] Coverage > 85%
```

**Criterio de Aceptación:**
- ✅ Escaneo de directorios funciona
- ✅ Validación de manifests implementada
- ✅ Tests pasan con > 85% coverage
- ✅ Manejo de errores robusto

---

##### Task 4.2: Implementar MarketplaceScanner
**Prioridad:** 🔴 Alta | **Estimación:** 4h

**src/core/discovery/MarketplaceScanner.ts:**
```typescript
import {
  DiscoveredMarketplace,
  DiscoveredPlugin,
  MarketplaceManifest,
  MarketplacePluginRef
} from '../../types';
import { fileOps } from '../../utils/FileOperations';
import { logger } from '../../utils/Logger';
import { PluginScanner } from './PluginScanner';
import * as path from 'path';

export class MarketplaceScanner {
  private pluginScanner: PluginScanner;

  constructor() {
    this.pluginScanner = new PluginScanner();
  }

  /**
   * Scan and load local marketplace
   */
  async scanMarketplace(marketplacePath: string): Promise<DiscoveredMarketplace | null> {
    const manifestPath = path.join(marketplacePath, '.claude-plugin', 'marketplace.json');

    if (!await fileOps.exists(manifestPath)) {
      logger.debug(`No marketplace manifest found: ${manifestPath}`);
      return null;
    }

    try {
      const manifest: MarketplaceManifest = await fileOps.readJSON(manifestPath);

      // Validate required fields
      if (!manifest.name) {
        logger.warn(`Marketplace manifest missing name: ${manifestPath}`);
        return null;
      }

      const marketplace: DiscoveredMarketplace = {
        name: manifest.name,
        path: marketplacePath,
        isRemote: false,
        manifest,
        plugins: manifest.plugins || [],
        discovered: new Date()
      };

      logger.debug(`Scanned marketplace: ${marketplace.name} (${marketplace.plugins.length} plugins)`);
      return marketplace;
    } catch (error: any) {
      logger.error(`Failed to scan marketplace at ${marketplacePath}`, error);
      return null;
    }
  }

  /**
   * Discover plugins from marketplace
   */
  async discoverPluginsFromMarketplace(
    marketplace: DiscoveredMarketplace
  ): Promise<DiscoveredPlugin[]> {
    const plugins: DiscoveredPlugin[] = [];

    for (const pluginRef of marketplace.plugins) {
      try {
        const plugin = await this.resolvePluginRef(marketplace, pluginRef);
        if (plugin) {
          plugins.push(plugin);
        }
      } catch (error: any) {
        logger.error(`Failed to resolve plugin ${pluginRef.name} from ${marketplace.name}`, error);
      }
    }

    logger.debug(`Discovered ${plugins.length} plugins from marketplace ${marketplace.name}`);
    return plugins;
  }

  /**
   * Resolve plugin reference from marketplace
   */
  private async resolvePluginRef(
    marketplace: DiscoveredMarketplace,
    pluginRef: MarketplacePluginRef
  ): Promise<DiscoveredPlugin | null> {
    // Resolve plugin path (relative or absolute)
    let pluginPath: string;

    if (path.isAbsolute(pluginRef.source)) {
      pluginPath = pluginRef.source;
    } else {
      pluginPath = path.join(marketplace.path, pluginRef.source);
    }

    // Check if plugin directory exists
    if (!await fileOps.exists(pluginPath)) {
      logger.warn(`Plugin path not found: ${pluginPath}`);
      return null;
    }

    // Try to load plugin manifest
    const manifestPath = path.join(pluginPath, '.claude-plugin', 'plugin.json');

    if (await fileOps.exists(manifestPath)) {
      // Has plugin.json - use PluginScanner
      return this.pluginScanner.scanPlugin(
        pluginPath,
        'marketplace',
        marketplace.path,
        marketplace.name
      );
    } else if (!marketplace.manifest.strict) {
      // No plugin.json but strict=false - use marketplace data as manifest
      return this.createPluginFromMarketplaceRef(
        pluginRef,
        pluginPath,
        marketplace
      );
    } else {
      logger.warn(`Plugin manifest not found and strict mode enabled: ${pluginPath}`);
      return null;
    }
  }

  /**
   * Create plugin from marketplace reference (when strict=false)
   */
  private async createPluginFromMarketplaceRef(
    pluginRef: MarketplacePluginRef,
    pluginPath: string,
    marketplace: DiscoveredMarketplace
  ): Promise<DiscoveredPlugin> {
    const hash = await fileOps.exists(pluginPath)
      ? await this.hashDirectory(pluginPath)
      : undefined;

    return {
      id: pluginRef.name,
      name: pluginRef.name,
      version: pluginRef.version || '0.0.0',
      path: pluginPath,
      sourceType: 'marketplace',
      sourcePath: marketplace.path,
      marketplace: marketplace.name,
      manifest: {
        name: pluginRef.name,
        version: pluginRef.version || '0.0.0',
        description: pluginRef.description,
        ...pluginRef as any
      },
      discovered: new Date(),
      hash
    };
  }

  private async hashDirectory(dirPath: string): Promise<string> {
    const { hashUtils } = await import('../../utils/HashUtils');
    return hashUtils.hashDirectory(dirPath);
  }
}
```

**tests/unit/discovery/MarketplaceScanner.test.ts:**
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { MarketplaceScanner } from '../../../src/core/discovery/MarketplaceScanner';
import * as path from 'path';
import * as fs from 'fs-extra';

describe('MarketplaceScanner', () => {
  const scanner = new MarketplaceScanner();
  const testDir = path.join(__dirname, '__test_marketplace__');

  beforeEach(async () => {
    await fs.ensureDir(testDir);
  });

  afterEach(async () => {
    await fs.remove(testDir);
  });

  async function createTestMarketplace(name: string, plugins: any[] = []) {
    await fs.ensureDir(path.join(testDir, '.claude-plugin'));
    await fs.writeJSON(path.join(testDir, '.claude-plugin', 'marketplace.json'), {
      name,
      plugins
    });
  }

  async function createTestPlugin(name: string, inPluginsDir: boolean = true) {
    const pluginDir = inPluginsDir
      ? path.join(testDir, 'plugins', name)
      : path.join(testDir, name);

    await fs.ensureDir(path.join(pluginDir, '.claude-plugin'));
    await fs.writeJSON(path.join(pluginDir, '.claude-plugin', 'plugin.json'), {
      name,
      version: '1.0.0',
      description: `Test plugin ${name}`
    });

    return pluginDir;
  }

  it('should scan marketplace', async () => {
    await createTestMarketplace('test-marketplace', [
      { name: 'plugin1', source: './plugins/plugin1' }
    ]);

    const marketplace = await scanner.scanMarketplace(testDir);

    expect(marketplace).not.toBeNull();
    expect(marketplace!.name).toBe('test-marketplace');
    expect(marketplace!.plugins).toHaveLength(1);
  });

  it('should discover plugins from marketplace', async () => {
    await createTestMarketplace('test-marketplace', [
      { name: 'plugin1', source: './plugins/plugin1' },
      { name: 'plugin2', source: './plugins/plugin2' }
    ]);

    await createTestPlugin('plugin1');
    await createTestPlugin('plugin2');

    const marketplace = await scanner.scanMarketplace(testDir);
    const plugins = await scanner.discoverPluginsFromMarketplace(marketplace!);

    expect(plugins).toHaveLength(2);
    expect(plugins[0].name).toBe('plugin1');
    expect(plugins[0].marketplace).toBe('test-marketplace');
  });

  it('should handle plugins without manifest when strict=false', async () => {
    await createTestMarketplace('test-marketplace', [
      { name: 'plugin-no-manifest', source: './plugin-no-manifest', version: '2.0.0' }
    ]);

    // Create plugin directory without manifest
    await fs.ensureDir(path.join(testDir, 'plugin-no-manifest'));

    const marketplace = await scanner.scanMarketplace(testDir);
    marketplace!.manifest.strict = false;

    const plugins = await scanner.discoverPluginsFromMarketplace(marketplace!);

    expect(plugins).toHaveLength(1);
    expect(plugins[0].name).toBe('plugin-no-manifest');
    expect(plugins[0].version).toBe('2.0.0');
  });

  it('should skip plugins without manifest when strict=true', async () => {
    await createTestMarketplace('test-marketplace', [
      { name: 'plugin-no-manifest', source: './plugin-no-manifest' }
    ]);

    // Create plugin directory without manifest
    await fs.ensureDir(path.join(testDir, 'plugin-no-manifest'));

    const marketplace = await scanner.scanMarketplace(testDir);
    marketplace!.manifest.strict = true; // Explicitly set to true

    const plugins = await scanner.discoverPluginsFromMarketplace(marketplace!);

    expect(plugins).toHaveLength(0);
  });
});
```

**Tareas:**
```bash
- [ ] Implementar MarketplaceScanner.ts
- [ ] Crear tests unitarios completos
- [ ] Ejecutar tests: npm test
- [ ] Coverage > 85%
```

**Criterio de Aceptación:**
- ✅ Escaneo de marketplaces funciona
- ✅ Resolución de plugins funciona (strict y non-strict)
- ✅ Tests pasan con > 85% coverage

---

### [CONTINUARÁ...]

Este documento continúa con:
- Task 4.3: Implementar DiscoveryCache
- Task 4.4: Implementar DiscoveryService completo
- Día 6-7: CLI Commands Implementation
- Día 8-9: Integration Testing
- Día 10: Documentation & Polish

**¿Quieres que continúe con el resto del documento de tareas?**

## Resumen de lo que tenemos hasta ahora:

### ✅ Día 1: Setup Completo
- Proyecto Node.js + TypeScript configurado
- Linting, formatting, testing configurado
- Husky + pre-commit hooks
- Estructura de directorios definida

### ✅ Día 2: Types & Utilities
- Todas las interfaces TypeScript definidas
- FileOperations utility implementado
- PathResolver utility implementado
- HashUtils implementado
- Logger implementado

### ✅ Día 3: Git Client
- GitClient completo con todas las operaciones
- GitError para manejo de errores
- Tests de integración con repo real

### ✅ Día 4-5: Discovery Core (en progreso)
- PluginScanner implementado
- MarketplaceScanner implementado
- Tests unitarios completos

**Siguiente:** DiscoveryCache, DiscoveryService completo, y CLI commands.

¿Quieres que continúe con el resto de las tareas?
