# Makefile Composition Guide

This guide explains how to organize `.claude/makefiles/` for maintainability and clarity.

## Directory Structure

```
project/
├── Makefile (root)
└── .claude/
    └── makefiles/
        ├── testing.mk
        ├── linting.mk
        ├── docker.mk
        ├── build.mk
        ├── database.mk
        ├── deploy.mk
        ├── dev.mk
        ├── clean.mk
        └── misc.mk
```

## Root Makefile

The root `Makefile` should be minimal and include all `.mk` files:

```makefile
# Include all Claude-generated makefiles
include .claude/makefiles/*.mk

.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Available targets from Claude:"
	@grep -h "^# " .claude/makefiles/*.mk | sed 's/^# //'
```

## Category Files

### testing.mk - Test-related targets

```makefile
.PHONY: test test-unit test-integration test-coverage

# test
# When to use: Run all tests quickly
test:
	pytest tests/

# test-unit
# When to use: Run unit tests only
test-unit:
	pytest tests/unit/ -v

# test-integration
# When to use: Run integration tests against local services
test-integration:
	pytest tests/integration/ -v

# test-coverage
# When to use: Run tests with HTML coverage report
test-coverage:
	pytest tests/ --cov=src --cov-report=html
```

### linting.mk - Code quality targets

```makefile
.PHONY: lint format typecheck

# lint
# When to use: Check code for style issues without fixing
lint:
	pylint src/
	flake8 src/

# format
# When to use: Auto-format code with black and isort
format:
	black .
	isort .

# typecheck
# When to use: Run static type checking with mypy
typecheck:
	mypy src/
```

### docker.mk - Container-related targets

```makefile
.PHONY: docker-build docker-run docker-stop docker-clean

# docker-build
# When to use: Build Docker image for local development
docker-build:
	docker build -t myapp:dev -f Dockerfile.dev .

# docker-run
# When to use: Run application in Docker container locally
docker-run:
	docker run -p 8000:8000 myapp:dev

# docker-stop
# When to use: Stop all running containers for this project
docker-stop:
	docker-compose down

# docker-clean
# When to use: Remove all images and containers for this project
docker-clean:
	docker-compose down -v --rmi all
```

### build.mk - Build and compilation targets

```makefile
.PHONY: build build-prod build-dev clean-build

# build
# When to use: Build project for development
build:
	npm run build

# build-prod
# When to use: Build optimized production bundle
build-prod:
	NODE_ENV=production npm run build

# build-dev
# When to use: Build with source maps and watch mode
build-dev:
	npm run build:dev -- --watch

# clean-build
# When to use: Remove all build artifacts
clean-build:
	rm -rf dist/ build/ *.egg-info/
```

### database.mk - Database operations

```makefile
.PHONY: db-migrate db-rollback db-reset db-seed

# db-migrate
# When to use: Apply pending database migrations
db-migrate:
	alembic upgrade head

# db-rollback
# When to use: Rollback last database migration
db-rollback:
	alembic downgrade -1

# db-reset
# When to use: Reset database to clean state (DESTRUCTIVE)
db-reset:
	alembic downgrade base && alembic upgrade head

# db-seed
# When to use: Populate database with test data
db-seed:
	python scripts/seed_db.py
```

### deploy.mk - Deployment targets

```makefile
.PHONY: deploy-staging deploy-prod deploy-rollback

# deploy-staging
# When to use: Deploy to staging environment
deploy-staging:
	./deploy.sh staging

# deploy-prod
# When to use: Deploy to production (requires confirmation)
deploy-prod:
	@echo "Deploying to PRODUCTION. Continue? [y/N]" && read ans && [ $${ans:-N} = y ]
	./deploy.sh production

# deploy-rollback
# When to use: Rollback last deployment
deploy-rollback:
	./deploy.sh rollback
```

### dev.mk - Development workflow targets

```makefile
.PHONY: dev serve watch install-deps

# dev
# When to use: Start development server with hot-reload
dev:
	npm run dev

# serve
# When to use: Serve built application locally
serve:
	python -m http.server 8000 -d dist/

# watch
# When to use: Watch files and rebuild on changes
watch:
	npm run watch

# install-deps
# When to use: Install all project dependencies
install-deps:
	npm install
	pip install -r requirements.txt
```

### clean.mk - Cleanup targets

```makefile
.PHONY: clean clean-all clean-python clean-node

# clean
# When to use: Remove common build artifacts and cache files
clean:
	rm -rf dist/ build/ *.egg-info/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete

# clean-all
# When to use: Deep clean including dependencies (requires reinstall)
clean-all: clean
	rm -rf node_modules/ venv/

# clean-python
# When to use: Remove Python-specific cache and build files
clean-python:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete
	rm -rf .pytest_cache/ .mypy_cache/

# clean-node
# When to use: Remove Node.js build artifacts
clean-node:
	rm -rf node_modules/ dist/ .next/
```

### misc.mk - Uncategorized targets

```makefile
# For targets that don't fit other categories
# Keep this file small - recategorize targets when patterns emerge

.PHONY: docs

# docs
# When to use: Generate project documentation
docs:
	mkdocs build
```

## Naming Conventions

### Target Names
- Use lowercase with hyphens: `test-unit`, not `test_unit` or `testUnit`
- Be descriptive: `docker-build-dev` better than `db`
- Group related targets with prefix: `test-*`, `docker-*`, `db-*`

### File Names
- Use singular nouns: `testing.mk` not `tests.mk`
- Match domain: `docker.mk` for Docker-related targets
- Use `misc.mk` for uncategorized (temporary)

## When to Split Files

Split a category file when:
- More than 10-15 targets
- Multiple sub-domains emerge
- Targets have different lifecycle

Example: Split `docker.mk` into:
- `docker-build.mk` - Building images
- `docker-compose.mk` - Multi-container orchestration
- `docker-registry.mk` - Push/pull operations

## Include Patterns

### Include All (Recommended)
```makefile
include .claude/makefiles/*.mk
```

**Pros:** Simple, automatic
**Cons:** Includes everything

### Selective Include
```makefile
include .claude/makefiles/testing.mk
include .claude/makefiles/linting.mk
```

**Pros:** Explicit control
**Cons:** Must update when adding files

### Optional Include
```makefile
-include .claude/makefiles/local.mk
```

**Pros:** No error if file missing
**Cons:** Silently fails (can hide issues)

## Variable Sharing

### Shared Variables
Create `.claude/makefiles/variables.mk`:

```makefile
# Shared configuration
PYTHON := python3
PROJECT_NAME := myapp
VERSION := $(shell git describe --tags --always)
```

Include first:
```makefile
include .claude/makefiles/variables.mk
include .claude/makefiles/*.mk
```

### Per-File Variables
Keep variables local to category when possible:

```makefile
# testing.mk - local variables
TEST_DIR := tests
PYTEST_FLAGS := -v --tb=short

test:
	pytest $(TEST_DIR) $(PYTEST_FLAGS)
```

## Cross-Category Dependencies

When targets depend on targets from other files:

```makefile
# testing.mk
test: build  # Depends on target from build.mk
	pytest tests/

# build.mk
build:
	npm run build
```

This works because all files are included together.

## Best Practices

1. **One file per category** - Don't mix docker + testing in same file
2. **Use .PHONY liberally** - Declare all non-file targets
3. **Document with "When to use"** - Every target needs context
4. **Keep root Makefile minimal** - Logic goes in category files
5. **Group related targets** - test-unit, test-integration, test-coverage together
6. **Avoid deep nesting** - Flat structure easier to navigate
7. **Regular cleanup** - Move misc.mk targets to proper categories
8. **Consistent formatting** - Tabs for recipes, same comment style
