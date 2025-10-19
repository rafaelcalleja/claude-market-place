# Makefile Best Practices

Guidelines for writing maintainable, portable, and efficient Makefiles.

## .PHONY Declaration

### Why Use .PHONY

`.PHONY` tells Make that a target doesn't create a file with that name.

**Without .PHONY:**
```makefile
clean:
	rm -rf build/
```

If a file named `clean` exists, Make won't run the recipe!

**With .PHONY:**
```makefile
.PHONY: clean
clean:
	rm -rf build/
```

Now `make clean` always runs, even if `clean` file exists.

### When to Use .PHONY

Use `.PHONY` for:
- ✅ Cleanup targets (`clean`, `distclean`)
- ✅ Test targets (`test`, `test-unit`)
- ✅ Build commands (`build`, `install`)
- ✅ Development workflow (`dev`, `serve`, `watch`)
- ✅ Any target that doesn't create a file with its name

Don't use `.PHONY` for:
- ❌ Targets that actually create files
- ❌ Pattern rules (`%.o: %.c`)

### Best Practice

Declare all `.PHONY` targets together at the top of each file:

```makefile
.PHONY: test test-unit test-integration clean help

test:
	pytest tests/

test-unit:
	pytest tests/unit/

clean:
	rm -rf build/

help:
	@echo "Available targets..."
```

## Nomenclature

### Target Naming

**Use lowercase with hyphens:**
```makefile
✅ test-unit
✅ docker-build
✅ clean-all
❌ test_unit
❌ testUnit
❌ TEST_UNIT
```

**Be descriptive:**
```makefile
✅ deploy-staging
✅ test-coverage
❌ deploy  # deploy where?
❌ test    # which tests?
```

**Group related targets with prefixes:**
```makefile
# Testing targets
test
test-unit
test-integration
test-coverage

# Docker targets
docker-build
docker-run
docker-stop
docker-clean
```

### Variable Naming

**Use UPPERCASE for constants:**
```makefile
PYTHON := python3
PROJECT_NAME := myapp
VERSION := 1.0.0
```

**Use lowercase for internal variables:**
```makefile
sources := $(wildcard src/*.py)
objects := $(patsubst %.py,%.pyc,$(sources))
```

### File Naming

**Category files use singular nouns:**
```makefile
✅ testing.mk
✅ docker.mk
✅ build.mk
❌ tests.mk
❌ dockers.mk
```

## Portability

### Use Standard Commands

**Prefer POSIX-compliant commands:**
```makefile
✅ rm -rf build/
✅ mkdir -p dist/
✅ test -f file.txt
❌ del /s build\     # Windows-specific
❌ mkdir dist        # No -p flag
```

### Handle Spaces in Paths

**Quote paths with spaces:**
```makefile
✅ cd "$(PROJECT_DIR)" && npm run build
❌ cd $(PROJECT_DIR) && npm run build
```

### Use Variables for Commands

**Define commands as variables:**
```makefile
PYTHON ?= python3
NPM ?= npm
DOCKER ?= docker

test:
	$(PYTHON) -m pytest

build:
	$(NPM) run build
```

Benefits:
- Easy to override: `make PYTHON=python3.11 test`
- Portable across systems
- Single source of truth

### Shell Compatibility

**Avoid bash-specific features:**
```makefile
# ❌ Bash-specific
test:
	[[ -f .env ]] && source .env

# ✅ POSIX-compatible
test:
	test -f .env && . .env
```

**Or specify shell explicitly:**
```makefile
SHELL := /bin/bash

test:
	[[ -f .env ]] && source .env
```

## Tabs vs Spaces

### The Golden Rule

**Recipes MUST use tabs, not spaces.**

```makefile
# ✅ Tab character
test:
	pytest tests/

# ❌ Spaces (will fail!)
test:
    pytest tests/
```

### Editor Configuration

**VS Code (.editorconfig):**
```ini
[Makefile]
indent_style = tab
```

**Vim:**
```vim
autocmd FileType make setlocal noexpandtab
```

### Visual Indicators

Most editors show tabs differently than spaces. Enable whitespace visualization to catch errors.

## Output and Verbosity

### Silent Commands

**Use @ to suppress command echo:**
```makefile
# Verbose (shows command)
test:
	pytest tests/

# Silent (only shows output)
test:
	@pytest tests/
```

### Informative Messages

**Add echo statements for clarity:**
```makefile
build:
	@echo "Building project..."
	@npm run build
	@echo "✅ Build complete!"
```

### Error Messages

**Provide clear errors:**
```makefile
check-env:
	@test -f .env || (echo "❌ Error: .env file not found" && exit 1)
	@echo "✅ Environment file found"
```

## Error Handling

### Fail Fast

**Stop on errors (default behavior):**
```makefile
build:
	npm run lint
	npm run build
	npm run test
# If any command fails, make stops
```

### Ignore Errors

**Continue despite errors with -:**
```makefile
clean:
	-rm -rf build/
	-rm -rf dist/
	-rm *.log
# Continues even if files don't exist
```

### Conditional Execution

**Use && for dependent commands:**
```makefile
deploy:
	@test -f .env && \
	npm run build && \
	./deploy.sh || \
	(echo "❌ Deploy failed" && exit 1)
```

## Performance

### Avoid Excessive Shell Calls

**Bad - calls shell every time:**
```makefile
VERSION = $(shell git describe --tags)

all:
	@echo $(VERSION)  # Calls git
	@echo $(VERSION)  # Calls git again
```

**Good - calls shell once:**
```makefile
VERSION := $(shell git describe --tags)

all:
	@echo $(VERSION)  # Uses cached value
	@echo $(VERSION)  # Uses cached value
```

### Use Built-in Functions

**Prefer Make functions over shell:**
```makefile
# ❌ Slow - uses shell
sources := $(shell find src -name '*.py')

# ✅ Fast - uses Make wildcard
sources := $(wildcard src/**/*.py)
```

### Parallel Execution

**Enable with -j flag:**
```bash
make -j4 test lint build
```

**Design targets for parallelization:**
```makefile
.PHONY: all test lint build

all: test lint build  # Can run in parallel

test:
	pytest tests/

lint:
	pylint src/

build:
	npm run build
```

## Documentation

### Comment Every Target

**Use "When to use" pattern:**
```makefile
# test-coverage
# When to use: Generate HTML coverage report for CI/CD
test-coverage:
	pytest tests/ --cov=src --cov-report=html
```

### Document Variables

```makefile
# Python interpreter (override with PYTHON=python3.11)
PYTHON ?= python3

# Minimum code coverage threshold
COVERAGE_MIN := 80

# Test directory
TEST_DIR := tests
```

### Add Help Target

```makefile
.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
```

## Dependencies

### Explicit Dependencies

```makefile
test: build  # Test requires build first
	pytest tests/

build: clean  # Build requires clean first
	npm run build

clean:
	rm -rf dist/
```

### Order-Only Prerequisites

```makefile
# Normal prerequisite
build/%.o: src/%.c build
	gcc -c $< -o $@

# Order-only prerequisite
build/%.o: src/%.c | build
	gcc -c $< -o $@

build:
	mkdir -p build
```

Order-only (`|`) means:
- Target only needs prerequisite to exist
- Doesn't rebuild if prerequisite changes

## Variables Best Practices

### Use ?= for Overridable Defaults

```makefile
# Can be overridden from command line
PYTHON ?= python3
PORT ?= 8000

serve:
	$(PYTHON) -m http.server $(PORT)
```

Usage:
```bash
make serve              # Uses python3, port 8000
make serve PORT=9000    # Uses python3, port 9000
make serve PYTHON=python3.11  # Uses python3.11, port 8000
```

### Use := for Performance

```makefile
# := Evaluated once (fast)
FILES := $(wildcard src/*.py)

# = Evaluated every use (slow)
FILES = $(wildcard src/*.py)
```

### Avoid Hardcoding Paths

```makefile
# ❌ Hardcoded
test:
	pytest /home/user/project/tests

# ✅ Relative or variable
TEST_DIR := tests
test:
	pytest $(TEST_DIR)
```

## Common Patterns

### Multi-Stage Build

```makefile
.PHONY: all clean build test

all: clean build test

clean:
	rm -rf dist/

build:
	npm run build

test:
	npm test
```

### Development Workflow

```makefile
.PHONY: dev install format lint test

dev: install
	npm run dev

install:
	npm install

format:
	prettier --write .

lint: format
	eslint src/

test: lint
	jest
```

### Environment Setup

```makefile
.PHONY: setup venv deps

setup: venv deps

venv:
	python3 -m venv venv

deps: venv
	./venv/bin/pip install -r requirements.txt
```

## Anti-Patterns to Avoid

### ❌ Don't Mix Tabs and Spaces
```makefile
test:
	pytest tests/  # Tab
    npm test       # Spaces - ERROR!
```

### ❌ Don't Use Shell-Specific Syntax Without SHELL Declaration
```makefile
# Will fail on non-bash shells
test:
	source venv/bin/activate && pytest
```

### ❌ Don't Hardcode Absolute Paths
```makefile
build:
	/usr/local/bin/npm run build  # What if npm is elsewhere?
```

### ❌ Don't Skip .PHONY for Non-File Targets
```makefile
# If 'test' file exists, this won't run
test:
	pytest tests/
```

### ❌ Don't Overcomplicate
```makefile
# Too complex
test:
	@for file in $(shell find tests -name '*.py'); do \
		$(PYTHON) -m pytest $$file || exit 1; \
	done

# Better - let pytest handle it
test:
	pytest tests/
```

## Summary Checklist

- ✅ Use `.PHONY` for all non-file targets
- ✅ Use lowercase-with-hyphens for target names
- ✅ Document targets with "When to use" comments
- ✅ Use tabs (not spaces) for recipes
- ✅ Use @ for silent commands where appropriate
- ✅ Define overridable variables with ?=
- ✅ Use := for expensive operations (shell calls)
- ✅ Quote paths that might have spaces
- ✅ Provide clear error messages
- ✅ Keep targets focused and single-purpose
- ✅ Group related targets together
- ✅ Include a help target
