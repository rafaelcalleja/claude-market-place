# Advanced Makefile Patterns

This reference covers advanced Makefile techniques for creating powerful, maintainable targets.

## Variables

### Basic Variables

```makefile
# Define variables
PYTHON := python3
TEST_DIR := tests
COVERAGE_MIN := 80

# Use variables
test:
	$(PYTHON) -m pytest $(TEST_DIR) --cov-fail-under=$(COVERAGE_MIN)
```

### Automatic Variables

```makefile
# $@ - The target name
# $< - First prerequisite
# $^ - All prerequisites
# $? - Prerequisites newer than target

%.o: %.c
	gcc -c $< -o $@  # $< is the .c file, $@ is the .o file
```

### Conditional Assignment

```makefile
# ?= Only set if not already defined
CC ?= gcc

# := Immediate assignment (evaluated once)
FILES := $(wildcard *.c)

# = Recursive assignment (evaluated each use)
BUILD_DIR = build/$(VERSION)
```

## Conditionals

```makefile
# Check if variable is defined
ifdef DEBUG
	CFLAGS += -g -O0
else
	CFLAGS += -O2
endif

# String comparison
ifeq ($(ENV),production)
	DEPLOY_FLAGS = --prod
else
	DEPLOY_FLAGS = --dev
endif
```

## Functions

### Built-in Functions

```makefile
# wildcard - find files matching pattern
SOURCES := $(wildcard src/*.py)

# patsubst - pattern substitution
OBJECTS := $(patsubst src/%.py,build/%.pyc,$(SOURCES))

# shell - execute shell command
GIT_HASH := $(shell git rev-parse --short HEAD)

# filter - select matching words
TEST_FILES := $(filter %_test.py,$(SOURCES))
```

### Custom Functions

```makefile
# Define function with 'define'
define run_tests
	@echo "Running tests for $(1)..."
	pytest $(1) -v
endef

# Call function with 'call'
test-unit:
	$(call run_tests,tests/unit)
```

## Pattern Rules

### Implicit Pattern Rules

```makefile
# Build all .o files from .c files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Build .min.js from .js
%.min.js: %.js
	uglifyjs $< -o $@
```

### Static Pattern Rules

```makefile
OBJECTS := foo.o bar.o

# Apply rule only to OBJECTS
$(OBJECTS): %.o: %.c
	$(CC) -c $< -o $@
```

## Phony Targets

```makefile
# Declare targets that don't create files
.PHONY: clean test install help

clean:
	rm -rf build/ dist/

test:
	pytest tests/

# Why .PHONY matters:
# - Make won't check if a file named 'clean' exists
# - Always runs the recipe, even if file exists
# - Improves performance
```

## Multi-Line Commands

```makefile
# Use backslash for continuation
deploy:
	docker build -t myapp:latest . && \
	docker push myapp:latest && \
	kubectl apply -f k8s/

# Use semicolon for same-shell execution
setup:
	cd frontend && \
	npm install && \
	npm run build
```

## Conditional Execution

```makefile
# Execute only if file exists
check-env:
	@test -f .env || (echo ".env file missing!" && exit 1)

# Execute with error handling
build:
	@echo "Building..."
	@./build.sh || (echo "Build failed!" && exit 1)
```

## Silent vs Verbose

```makefile
# @ prefix = silent (no echo)
quiet:
	@echo "This will print"
	@echo "But commands won't"

# No @ = verbose (shows command)
verbose:
	echo "You'll see: echo \"You'll see...\""
	echo "And then: And then..."
```

## Including Other Makefiles

```makefile
# Include other .mk files
include config.mk
include .claude/makefiles/*.mk

# Optional include (no error if missing)
-include local.mk

# Useful for:
# - Separating concerns (testing.mk, docker.mk)
# - Local overrides (local.mk not in git)
# - Shared configurations
```

## Target-Specific Variables

```makefile
# Variable only applies to specific target
debug: CFLAGS += -g -DDEBUG
debug: build

production: CFLAGS += -O3
production: build

build:
	$(CC) $(CFLAGS) main.c -o app
```

## Order-Only Prerequisites

```makefile
# Normal prerequisite: rebuilds if changed
# Order-only (after |): only checks existence

build/%.o: src/%.c | build
	$(CC) -c $< -o $@

# build/ must exist but we don't rebuild if it's touched
build:
	mkdir -p build
```

## Double-Colon Rules

```makefile
# Multiple recipes for same target
all:: build
	@echo "Built successfully"

all:: test
	@echo "Tests passed"

# Both recipes run when 'make all' is called
```

## Recursive Make

```makefile
# Call make in subdirectory
build:
	$(MAKE) -C frontend build
	$(MAKE) -C backend build

# Use $(MAKE) not 'make' for:
# - Inherits flags (-j, -n, etc)
# - Proper job control
```

## Best Practices

1. **Use .PHONY** for non-file targets
2. **Use variables** for paths and commands (easier to change)
3. **Use $(MAKE)** not `make` for recursion
4. **Use @** for cleaner output
5. **Use $(shell)** sparingly (slow)
6. **Document targets** with "When to use" comments
7. **Group related targets** in separate .mk files
8. **Set .DEFAULT_GOAL** to help or common target

## Example: Comprehensive Target

```makefile
.PHONY: test-coverage

# test-coverage
# When to use: Run tests with coverage report and enforce minimum threshold
test-coverage: export PYTHONPATH=src
test-coverage:
	@echo "Running tests with coverage..."
	@pytest $(TEST_DIR) \
		--cov=src \
		--cov-report=html \
		--cov-report=term \
		--cov-fail-under=$(COV_MIN) || \
		(echo "❌ Coverage below $(COV_MIN)%" && exit 1)
	@echo "✅ Coverage passed!"
```
