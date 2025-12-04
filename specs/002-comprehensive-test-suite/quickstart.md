# Quickstart: Running the Comprehensive Test Suite

**Feature**: 002-comprehensive-test-suite
**Purpose**: Guide for running tests, interpreting results, and debugging failures
**Created**: 2025-11-11

## Installation

### Prerequisites

- Python 3.11+
- Git (for integration tests)
- Virtual environment (recommended)

### Setup Test Environment

```bash
# Navigate to project root
cd /path/to/plugin-curator

# Activate existing venv or create new one
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate  # Windows

# Install test dependencies
pip install -r requirements-test.txt

# Verify installation
pytest --version
pytest-cov --version
```

### Test Dependencies

Create `requirements-test.txt`:
```
pytest>=7.4.0
pytest-cov>=4.1.0
pytest-xdist>=3.3.0
pytest-mock>=3.11.0
pytest-timeout>=2.1.0
pytest-random-order>=1.1.0
```

---

## Running Tests

### Basic Commands

```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/test_registry.py

# Run specific test function
pytest tests/test_registry.py::test_load_empty_registry

# Run tests matching pattern
pytest -k "registry"

# Run tests with specific marker
pytest -m unit
pytest -m integration
```

### Coverage Commands

```bash
# Run with coverage (terminal output)
pytest --cov=curator --cov-report=term

# Run with coverage (HTML report)
pytest --cov=curator --cov-report=html --cov-report=term

# Run with branch coverage
pytest --cov=curator --cov-branch --cov-report=term-missing

# Run with coverage threshold enforcement
pytest --cov=curator --cov-fail-under=100

# Complete coverage command (recommended)
pytest --cov=curator --cov-branch --cov-report=html --cov-report=term-missing --cov-fail-under=100
```

### Parallel Execution

```bash
# Run tests in parallel (auto-detect cores)
pytest -n auto

# Run with specific number of workers
pytest -n 4

# Parallel execution with coverage
pytest -n auto --cov=curator --cov-report=term
```

### Random Order Execution

```bash
# Run tests in random order
pytest --random-order

# Run with specific seed for reproducibility
pytest --random-order-seed=12345
```

### Performance Testing

```bash
# Show slowest 10 tests
pytest --durations=10

# Show all test durations
pytest --durations=0

# Set timeout for individual tests
pytest --timeout=5
```

---

## Interpreting Results

### Test Output

```
======================== test session starts =========================
tests/test_registry.py::test_load_empty_registry PASSED         [ 10%]
tests/test_registry.py::test_save_registry PASSED              [ 20%]
tests/test_discovery.py::test_discover_commands PASSED         [ 30%]
...

==================== 50 passed in 1.23s ==============================
```

**Indicators**:
- `PASSED`: Test succeeded
- `FAILED`: Test failed (see traceback)
- `SKIPPED`: Test skipped (marked with @pytest.mark.skip)
- `XFAIL`: Expected failure
- `XPASS`: Unexpected pass

### Coverage Report (Terminal)

```
---------- coverage: platform linux, python 3.11.0 -----------
Name          Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------
curator.py      464      0    120      0   100%
-----------------------------------------------------------
TOTAL           464      0    120      0   100%
```

**Columns**:
- `Stmts`: Total statements
- `Miss`: Uncovered statements
- `Branch`: Total branches
- `BrPart`: Partially covered branches
- `Cover`: Coverage percentage
- `Missing`: Line numbers not covered

### Coverage Report (HTML)

```bash
# Generate HTML report
pytest --cov=curator --cov-report=html

# Open in browser
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
start htmlcov/index.html  # Windows
```

**HTML Features**:
- Color-coded lines (green=covered, red=uncovered)
- Branch coverage indicators
- Click lines to see execution count
- Filter by file/function

---

## Debugging Failures

### Common Issues

#### 1. Test Fails Due to Residual State

**Symptom**: Test passes individually but fails in suite

**Solution**:
```bash
# Run in random order to detect state issues
pytest --random-order

# Run specific test in isolation
pytest tests/test_file.py::test_function

# Check fixture cleanup
pytest -v --setup-show
```

#### 2. Coverage Below 100%

**Symptom**: Coverage report shows uncovered lines

**Solution**:
```bash
# Generate HTML report to see uncovered lines
pytest --cov=curator --cov-report=html
open htmlcov/curator_py.html

# Check for missing branch coverage
pytest --cov=curator --cov-branch --cov-report=term-missing
```

**Common Causes**:
- Exception paths not tested
- Error handling missing tests
- Branch conditions not fully covered

#### 3. Flaky Tests

**Symptom**: Test sometimes passes, sometimes fails

**Solution**:
```bash
# Run test multiple times
pytest --count=10 tests/test_file.py::test_function

# Check for timing issues
pytest --timeout=5

# Review fixture scopes (function vs module)
```

#### 4. Slow Test Execution

**Symptom**: Tests take > 2 minutes

**Solution**:
```bash
# Identify slow tests
pytest --durations=0

# Run in parallel
pytest -n auto

# Profile test execution
pytest --profile
```

#### 5. Import Errors

**Symptom**: `ModuleNotFoundError: No module named 'curator'`

**Solution**:
```bash
# Ensure running from project root
cd /path/to/plugin-curator

# Verify curator.py exists
ls curator.py

# Check PYTHONPATH
echo $PYTHONPATH

# Install in development mode (if needed)
pip install -e .
```

### Verbose Debugging

```bash
# Maximum verbosity
pytest -vv

# Show local variables in tracebacks
pytest -l

# Show print statements
pytest -s

# Drop into debugger on failure
pytest --pdb

# Show fixture setup/teardown
pytest --setup-show
```

---

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/test.yml`:

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install -r requirements-test.txt

      - name: Run tests with coverage
        run: |
          pytest --cov=curator --cov-branch --cov-report=xml --cov-report=term -n auto

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          fail_ci_if_error: true

      - name: Enforce 100% coverage
        run: |
          pytest --cov=curator --cov-fail-under=100 --cov-report=term

      - name: Archive coverage report
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: coverage-report
          path: htmlcov/
```

### Local Pre-Commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
set -e

echo "Running test suite..."
pytest --cov=curator --cov-fail-under=100 --cov-report=term -n auto

echo "✓ All tests passed with 100% coverage"
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

## Test Markers

### Organizing Tests

```python
# Mark as unit test
@pytest.mark.unit
def test_load_registry():
    pass

# Mark as integration test
@pytest.mark.integration
def test_add_plugin_local():
    pass

# Mark as slow test
@pytest.mark.slow
def test_large_plugin():
    pass

# Mark as edge case
@pytest.mark.edge_case
def test_malformed_json():
    pass
```

### Running by Marker

```bash
# Run only unit tests
pytest -m unit

# Run everything except slow tests
pytest -m "not slow"

# Run unit and integration tests
pytest -m "unit or integration"

# Run edge cases only
pytest -m edge_case
```

---

## Performance Benchmarks

### Target Metrics

- **Total Execution Time**: < 2 minutes
- **Average Test Duration**: < 1 second
- **Coverage Collection Overhead**: < 20%
- **Parallel Speedup**: 2-3x (4+ cores)

### Measuring Performance

```bash
# Baseline (no coverage)
time pytest

# With coverage
time pytest --cov=curator

# Calculate overhead
# Overhead % = ((with_cov - baseline) / baseline) * 100

# Parallel speedup
time pytest  # Serial
time pytest -n auto  # Parallel
# Speedup = serial_time / parallel_time
```

---

## Troubleshooting

### Environment Issues

```bash
# Check Python version
python --version  # Should be 3.11+

# Check pytest installation
pytest --version

# Reinstall test dependencies
pip install --upgrade -r requirements-test.txt

# Clear pytest cache
pytest --cache-clear
```

### Coverage Issues

```bash
# Check .coveragerc configuration
cat .coveragerc

# Verify coverage source
pytest --cov=. --cov-report=term  # Should only show curator.py

# Debug coverage collection
pytest --cov=curator --cov-report=term -v
```

### Parallel Execution Issues

```bash
# Disable parallel execution
pytest -n 0

# Check for shared state
pytest --random-order

# Review fixture scopes
pytest --setup-show
```

---

## Quick Reference

### Essential Commands

```bash
# Full test run with coverage
pytest --cov=curator --cov-branch --cov-report=html -n auto

# Fast feedback (no coverage)
pytest -n auto

# Debug specific test
pytest tests/test_file.py::test_name -vv -s --pdb

# Check coverage gaps
pytest --cov=curator --cov-report=term-missing

# Enforce 100% coverage
pytest --cov=curator --cov-fail-under=100
```

### Configuration Files

- `pytest.ini`: Pytest configuration
- `.coveragerc`: Coverage configuration
- `requirements-test.txt`: Test dependencies
- `conftest.py`: Shared fixtures

### Documentation

- Official pytest docs: https://docs.pytest.org
- pytest-cov docs: https://pytest-cov.readthedocs.io
- pytest-xdist docs: https://pytest-xdist.readthedocs.io
