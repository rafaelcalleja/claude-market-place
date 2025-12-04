# Pytest Test Suite Research - Comprehensive Guide

**Research Date:** 2025-11-11
**Purpose:** Implementing comprehensive pytest test suite with 100% coverage for Python CLI tools

---

## 1. Pytest Best Practices for 100% Branch Coverage

### Key Concepts

**Line Coverage vs Branch Coverage:**
- **Line Coverage:** Measures which lines of code are executed
- **Branch Coverage:** Measures which decision paths are taken (if/else, loops, etc.)
- Branch coverage is more thorough and catches untested code paths that line coverage misses

### Enabling Branch Coverage

```bash
# Run tests with branch coverage
pytest --cov=myproject --cov-branch tests/

# Generate HTML report with branch details
pytest --cov=myproject --cov-branch --cov-report=html tests/

# Show missing lines and branches
pytest --cov=myproject --cov-branch --cov-report=term-missing tests/
```

### Configuration (.coveragerc or pyproject.toml)

```ini
[run]
source = myproject
branch = True
omit =
    */tests/*
    */venv/*
    */__pycache__/*

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
    if TYPE_CHECKING:
    @abstractmethod

# Branch-specific exclusions
exclude_also =
    if DEBUG:
    if 0:
    if False:

partial_branches =
    pragma: no branch
    while True:
```

### Understanding Branch Coverage Reports

**HTML Report Indicators:**
- **Green lines:** Fully covered (all branches taken)
- **Yellow lines:** Partially covered (some branches not taken)
- **Red lines:** Not executed
- **Annotations:** Show which branch destinations were missed (e.g., "2->4" means branch from line 2 to line 4 not taken)

### Branch Coverage Pragmas

```python
# Exclude a line from line coverage
if DEBUG:  # pragma: no cover
    debug_function()

# Exclude a branch from branch coverage
while True:  # pragma: no branch
    process()
    if done:
        break

# Generator expressions may need this
result = (x for x in data)  # pragma: no branch
```

### Best Practices

1. **Aim for 80%+ coverage** for critical paths, don't obsess over 100%
2. **Test edge cases** not just happy paths
3. **Use coverage as a guide** not an absolute goal
4. **Exclude generated code** and boilerplate
5. **Focus on meaningful tests** over coverage percentage
6. **Test both branches** of every conditional
7. **Test loop iterations:** zero, one, many
8. **Test exception paths** explicitly

### Documentation

- **Official Coverage.py:** https://coverage.readthedocs.io/en/latest/
- **Pytest-cov:** https://pytest-cov.readthedocs.io/en/latest/
- **Branch Coverage:** https://coverage.readthedocs.io/en/7.11.3/branch.html

---

## 2. Idempotent Test Design Patterns Using Fixtures

### Key Principles

**Idempotent Tests:** Tests that can run in any order, multiple times, without affecting each other or leaving state behind.

### Fixture Scopes

```python
# Function scope (default) - runs for each test
@pytest.fixture(scope="function")
def temp_data():
    return {"key": "value"}

# Class scope - runs once per test class
@pytest.fixture(scope="class")
def database_connection():
    conn = create_connection()
    yield conn
    conn.close()

# Module scope - runs once per test module
@pytest.fixture(scope="module")
def expensive_resource():
    resource = setup_expensive_resource()
    yield resource
    teardown_resource(resource)

# Session scope - runs once per test session
@pytest.fixture(scope="session")
def shared_config():
    return load_config()
```

### tmpdir and tmp_path Fixtures

```python
# Legacy tmpdir (py.path.local object)
def test_with_tmpdir(tmpdir):
    temp_file = tmpdir.join("test.txt")
    temp_file.write("content")
    assert temp_file.read() == "content"

# Modern tmp_path (pathlib.Path object) - PREFERRED
def test_with_tmp_path(tmp_path):
    temp_file = tmp_path / "test.txt"
    temp_file.write_text("content")
    assert temp_file.read_text() == "content"

# Custom temporary directory fixture
@pytest.fixture
def custom_temp_dir(tmp_path):
    """Create a temporary directory with specific structure."""
    project_dir = tmp_path / "project"
    project_dir.mkdir()
    (project_dir / "src").mkdir()
    (project_dir / "tests").mkdir()
    return project_dir
```

### monkeypatch Fixture

```python
# Patching environment variables
def test_env_vars(monkeypatch):
    monkeypatch.setenv("DATABASE_URL", "test://localhost")
    assert os.environ["DATABASE_URL"] == "test://localhost"
    # Automatically restored after test

# Patching object attributes
def test_config(monkeypatch):
    monkeypatch.setattr("myapp.config.DEBUG", True)
    assert myapp.config.DEBUG is True

# Patching dictionary items
def test_dict_patch(monkeypatch):
    monkeypatch.setitem(os.environ, "API_KEY", "test-key")
    assert os.environ["API_KEY"] == "test-key"

# Deleting attributes
def test_delete_attr(monkeypatch):
    monkeypatch.delattr("myapp.config.FEATURE_FLAG")

# Patching sys.path
def test_sys_path(monkeypatch):
    monkeypatch.syspath_prepend("/custom/path")
```

### Yield Fixtures (Recommended Pattern)

```python
@pytest.fixture
def database():
    """Setup and teardown pattern with yield."""
    # Setup
    db = Database()
    db.connect()

    # Provide to test
    yield db

    # Teardown (always runs, even if test fails)
    db.rollback()
    db.close()

# Nested fixture dependencies
@pytest.fixture
def user(database):
    """Fixture that depends on another fixture."""
    user = database.create_user("test@example.com")
    yield user
    database.delete_user(user.id)
```

### Fixture Factories

```python
@pytest.fixture
def make_user():
    """Factory fixture for creating multiple users."""
    created_users = []

    def _make_user(name, email):
        user = User(name=name, email=email)
        created_users.append(user)
        return user

    yield _make_user

    # Cleanup all created users
    for user in created_users:
        user.delete()

# Usage in tests
def test_multiple_users(make_user):
    user1 = make_user("Alice", "alice@example.com")
    user2 = make_user("Bob", "bob@example.com")
    assert user1.name != user2.name
```

### Autouse Fixtures

```python
@pytest.fixture(autouse=True)
def reset_global_state():
    """Runs automatically before each test in the module."""
    global_cache.clear()
    yield
    # Cleanup after test
```

### Fixture Finalization

```python
@pytest.fixture
def resource(request):
    """Using request.addfinalizer for cleanup."""
    resource = acquire_resource()

    def cleanup():
        release_resource(resource)

    request.addfinalizer(cleanup)
    return resource
```

### Best Practices

1. **Use tmp_path over tmpdir** (modern pathlib API)
2. **Prefer yield fixtures** for setup/teardown
3. **Keep fixtures small and focused** (single responsibility)
4. **Use appropriate scope** (function, class, module, session)
5. **Avoid side effects** between fixtures
6. **Use monkeypatch** instead of manual mocking when possible
7. **Document fixture purpose** with docstrings
8. **Use fixture factories** for creating multiple test objects

### Documentation

- **Official Fixtures Guide:** https://docs.pytest.org/en/stable/how-to/fixtures.html
- **Fixture Reference:** https://docs.pytest.org/en/stable/reference/fixtures.html

---

## 3. Mocking Strategies for Subprocess Calls

### Using pytest-mock (Recommended)

**Installation:**
```bash
pip install pytest-mock
```

### Basic mocker Fixture

```python
# The mocker fixture is provided by pytest-mock
def test_subprocess_run(mocker):
    """Mock subprocess.run with return value."""
    mock_result = mocker.MagicMock()
    mock_result.returncode = 0
    mock_result.stdout = "Success"
    mock_result.stderr = ""

    mock_run = mocker.patch("subprocess.run", return_value=mock_result)

    # Call function that uses subprocess.run
    result = my_function_that_calls_subprocess()

    # Verify subprocess.run was called correctly
    mock_run.assert_called_once_with(
        ["git", "clone", "https://example.com/repo.git"],
        capture_output=True,
        text=True,
        check=True
    )
    assert result == "Success"
```

### Mocking subprocess.run with Multiple Calls

```python
def test_multiple_subprocess_calls(mocker):
    """Mock multiple subprocess calls with different results."""
    # First call succeeds, second fails
    mock_results = [
        mocker.MagicMock(returncode=0, stdout="First success"),
        mocker.MagicMock(returncode=1, stderr="Second failed")
    ]

    mock_run = mocker.patch("subprocess.run", side_effect=mock_results)

    result1 = subprocess.run(["git", "status"])
    result2 = subprocess.run(["git", "push"])

    assert result1.returncode == 0
    assert result2.returncode == 1
    assert mock_run.call_count == 2
```

### Mocking subprocess.run to Raise Exception

```python
def test_subprocess_exception(mocker):
    """Mock subprocess to raise CalledProcessError."""
    mocker.patch(
        "subprocess.run",
        side_effect=subprocess.CalledProcessError(
            returncode=128,
            cmd=["git", "clone"],
            stderr="Repository not found"
        )
    )

    with pytest.raises(subprocess.CalledProcessError) as exc_info:
        my_git_clone_function("invalid-repo")

    assert exc_info.value.returncode == 128
    assert "not found" in exc_info.value.stderr
```

### Mocking subprocess.Popen

```python
def test_subprocess_popen(mocker):
    """Mock subprocess.Popen for streaming output."""
    mock_process = mocker.MagicMock()
    mock_process.communicate.return_value = (b"output", b"")
    mock_process.returncode = 0

    mock_popen = mocker.patch("subprocess.Popen", return_value=mock_process)

    # Call function using Popen
    result = my_function_with_popen()

    mock_popen.assert_called_once()
    mock_process.communicate.assert_called_once()
```

### Advanced Mocking Patterns

```python
# Mock with spy (calls through to real implementation)
def test_spy_subprocess(mocker):
    """Spy on subprocess.run while still calling it."""
    spy = mocker.spy(subprocess, "run")

    subprocess.run(["echo", "test"])

    spy.assert_called_once()
    assert spy.call_args[0][0] == ["echo", "test"]

# Mock with custom side_effect function
def test_custom_side_effect(mocker):
    """Use function to determine mock behavior."""
    def custom_run(cmd, **kwargs):
        if "clone" in cmd:
            return mocker.MagicMock(returncode=0, stdout="Cloned")
        else:
            return mocker.MagicMock(returncode=1, stderr="Unknown command")

    mocker.patch("subprocess.run", side_effect=custom_run)

    result1 = subprocess.run(["git", "clone", "repo"])
    result2 = subprocess.run(["git", "push"])

    assert result1.returncode == 0
    assert result2.returncode == 1

# Patching in specific module
def test_patch_in_module(mocker):
    """Patch subprocess where it's imported."""
    # If mymodule does: from subprocess import run
    # Then patch where it's used, not where it's defined
    mocker.patch("mymodule.run", return_value=mocker.MagicMock(returncode=0))
```

### Fixture-Based Mocking

```python
@pytest.fixture
def mock_git_clone(mocker):
    """Reusable mock for git clone operations."""
    mock_result = mocker.MagicMock()
    mock_result.returncode = 0
    mock_result.stdout = "Cloning into 'repo'..."
    return mocker.patch("subprocess.run", return_value=mock_result)

def test_with_mock_fixture(mock_git_clone):
    """Use mock fixture in test."""
    result = my_clone_function("https://example.com/repo.git")
    assert result.returncode == 0
    mock_git_clone.assert_called_once()
```

### Best Practices

1. **Patch where used, not where defined** (import location matters)
2. **Use pytest-mock over unittest.mock** for better pytest integration
3. **Mock at the right level** (subprocess.run vs higher-level functions)
4. **Verify call arguments** with assert_called_with
5. **Test error paths** with side_effect exceptions
6. **Use fixtures for common mocks** to reduce duplication
7. **Mock external dependencies** not internal logic
8. **Consider integration tests** for actual subprocess calls

### Tradeoffs

| Approach | Pros | Cons | When to Use |
|----------|------|------|-------------|
| Mock subprocess.run | Fast, no external deps | Doesn't test actual command | Unit tests |
| Real subprocess calls | Tests actual behavior | Slow, environment-dependent | Integration tests |
| pytest-mock | Clean syntax, fixtures | Requires plugin | All unit tests |
| unittest.mock | Built-in | More verbose | When avoiding dependencies |

### Documentation

- **pytest-mock:** https://pytest-mock.readthedocs.io/
- **unittest.mock:** https://docs.python.org/3/library/unittest.mock.html

---

## 4. Advanced Parameterized Testing

### Basic Parametrization

```python
@pytest.mark.parametrize("input,expected", [
    (2, 4),
    (3, 9),
    (4, 16),
])
def test_square(input, expected):
    assert input ** 2 == expected
```

### Multiple Parameters

```python
@pytest.mark.parametrize("x,y,expected", [
    (1, 2, 3),
    (2, 3, 5),
    (3, 4, 7),
])
def test_addition(x, y, expected):
    assert x + y == expected
```

### Nested Parametrization (Cartesian Product)

```python
@pytest.mark.parametrize("x", [1, 2])
@pytest.mark.parametrize("y", [10, 20])
def test_multiplication(x, y):
    """Generates 4 tests: (1,10), (1,20), (2,10), (2,20)."""
    result = x * y
    assert result > 0
```

### Parametrize with IDs

```python
# Custom test IDs for readability
@pytest.mark.parametrize("value,expected", [
    (0, False),
    (1, True),
    (-1, True),
], ids=["zero", "positive", "negative"])
def test_boolean_conversion(value, expected):
    assert bool(value) == expected

# Function-based IDs
def idfn(val):
    if isinstance(val, str):
        return val
    return f"value_{val}"

@pytest.mark.parametrize("input", [1, 2, "special"], ids=idfn)
def test_with_function_ids(input):
    assert input is not None
```

### Parametrize with pytest.param

```python
@pytest.mark.parametrize("test_input,expected", [
    pytest.param(1, 2, id="first"),
    pytest.param(2, 4, id="second"),
    pytest.param(3, 6, marks=pytest.mark.skip(reason="Not implemented")),
    pytest.param(4, 8, marks=pytest.mark.xfail(reason="Known bug")),
])
def test_multiply_by_two(test_input, expected):
    assert test_input * 2 == expected
```

### Indirect Parametrization with Fixtures

```python
@pytest.fixture
def database(request):
    """Fixture that takes parameter."""
    db_type = request.param
    if db_type == "sqlite":
        return SQLiteDB()
    elif db_type == "postgres":
        return PostgresDB()

@pytest.mark.parametrize("database", ["sqlite", "postgres"], indirect=True)
def test_database_operations(database):
    """Test runs twice with different database fixtures."""
    assert database.connect() is True
```

### Complex Data Structures

```python
@pytest.mark.parametrize("config", [
    {"name": "test1", "value": 10, "enabled": True},
    {"name": "test2", "value": 20, "enabled": False},
])
def test_with_dict(config):
    assert "name" in config
    assert config["value"] > 0
```

### Parametrize from External Data

```python
# Load test cases from JSON/YAML
import json

def load_test_cases():
    with open("test_cases.json") as f:
        return json.load(f)

@pytest.mark.parametrize("test_case", load_test_cases())
def test_from_file(test_case):
    input_data = test_case["input"]
    expected = test_case["expected"]
    assert process(input_data) == expected
```

### Combining Parametrize with Fixtures

```python
@pytest.fixture
def setup_data(tmp_path):
    """Fixture used with parametrized test."""
    data_file = tmp_path / "data.txt"
    return data_file

@pytest.mark.parametrize("content,expected_lines", [
    ("line1\nline2", 2),
    ("single", 1),
    ("", 0),
])
def test_file_lines(setup_data, content, expected_lines):
    setup_data.write_text(content)
    lines = setup_data.read_text().split("\n")
    assert len(lines) == expected_lines
```

### Parametrize Class Methods

```python
class TestMathOperations:
    @pytest.mark.parametrize("a,b,expected", [
        (2, 3, 5),
        (0, 0, 0),
        (-1, 1, 0),
    ])
    def test_add(self, a, b, expected):
        assert a + b == expected

    @pytest.mark.parametrize("a,b,expected", [
        (6, 3, 2),
        (10, 5, 2),
    ])
    def test_divide(self, a, b, expected):
        assert a / b == expected
```

### Best Practices

1. **Use descriptive IDs** for parametrized tests
2. **Group related test cases** together
3. **Avoid too many parameters** (max 3-4 for readability)
4. **Use pytest.param for marks** (skip, xfail)
5. **Leverage indirect parametrization** for complex fixtures
6. **Document test case purpose** in IDs or comments
7. **Use external files** for large test datasets
8. **Combine with fixtures** for powerful test setups

### Tradeoffs

| Approach | Pros | Cons | When to Use |
|----------|------|------|-------------|
| Simple list | Easy to write | Limited metadata | Simple test cases |
| pytest.param | Flexible, supports marks | More verbose | Complex scenarios |
| Indirect fixtures | Very flexible | More complex | Stateful fixtures |
| External data | Maintainable, large datasets | Harder to debug | Data-driven tests |

### Documentation

- **Parametrize Reference:** https://docs.pytest.org/en/stable/reference/reference.html#pytest-mark-parametrize
- **Parametrize How-To:** https://docs.pytest.org/en/stable/how-to/parametrize.html

---

## 5. pytest-xdist Configuration for Parallel Execution

### Installation

```bash
pip install pytest-xdist

# Optional: Install psutil for better CPU detection
pip install pytest-xdist[psutil]
```

### Basic Usage

```bash
# Auto-detect number of CPUs
pytest -n auto

# Specify number of workers
pytest -n 4

# Run with logical mode (default)
pytest -n 4 --dist=load

# Load balance by file
pytest -n 4 --dist=loadfile

# Load balance by group
pytest -n 4 --dist=loadgroup
```

### Distribution Modes

**load (default):** Distributes tests to workers dynamically as they complete
```bash
pytest -n auto --dist=load
```

**loadfile:** Sends all tests from a file to the same worker
```bash
pytest -n auto --dist=loadfile
```

**loadgroup:** Groups tests marked with xdist_group
```bash
pytest -n auto --dist=loadgroup
```

**no:** Disables distribution (each worker gets full test suite)
```bash
pytest -n 4 --dist=no
```

### Configuration in pytest.ini

```ini
[pytest]
# Default xdist settings
addopts = -n auto --dist=loadfile

# Maximum workers
xdist_workers = auto

# Timeout for worker communication
timeout = 300
```

### Configuration in pyproject.toml

```toml
[tool.pytest.ini_options]
addopts = [
    "-n", "auto",
    "--dist=loadfile",
    "--maxfail=3",
]
```

### Grouping Tests

```python
# Mark tests to run on the same worker
@pytest.mark.xdist_group(name="group1")
def test_database_setup():
    """Runs on same worker as other group1 tests."""
    pass

@pytest.mark.xdist_group(name="group1")
def test_database_operations():
    """Runs on same worker with test_database_setup."""
    pass
```

### Worker-Specific Configuration

```python
import pytest

@pytest.fixture(scope="session")
def worker_id(request):
    """Get the worker ID for this process."""
    # worker_id is 'master' when not using xdist
    # or 'gw0', 'gw1', etc. when using xdist
    return getattr(request.config, 'workerinput', {}).get('workerid', 'master')

def test_worker_specific(worker_id):
    """Test can use worker_id to vary behavior."""
    print(f"Running on worker: {worker_id}")
```

### Session-Scoped Fixtures with xdist

```python
# Problem: Session fixtures run per worker, not once per session
@pytest.fixture(scope="session")
def database():
    """This runs ONCE PER WORKER, not once per session."""
    db = create_database()
    yield db
    db.cleanup()

# Solution: Use file locking for true session scope
import filelock

@pytest.fixture(scope="session")
def shared_database(tmp_path_factory, worker_id):
    """True session-scoped fixture across all workers."""
    if worker_id == "master":
        # Not using xdist
        return create_database()

    # Use file lock to ensure only one worker creates database
    root_tmp_dir = tmp_path_factory.getbasetemp().parent
    lock_file = root_tmp_dir / "database.lock"

    with filelock.FileLock(str(lock_file) + ".lock"):
        db = create_database()

    yield db

    # Only master worker cleans up
    if worker_id == "master":
        db.cleanup()
```

### Debugging xdist Issues

```bash
# Run with verbose output
pytest -n auto -v

# Show which worker runs which test
pytest -n auto -v --showlocals

# Disable output capturing to see print statements
pytest -n auto -s  # Note: -s doesn't work well with xdist

# Run specific test with xdist disabled for debugging
pytest tests/test_specific.py -n 0
```

### Common Issues and Solutions

**Issue: Tests fail only when run in parallel**
```python
# Problem: Shared state between tests
global_cache = {}

def test_one():
    global_cache["key"] = "value1"

def test_two():
    assert global_cache["key"] == "value2"  # Fails randomly

# Solution: Use fixtures and proper cleanup
@pytest.fixture(autouse=True)
def clear_cache():
    global_cache.clear()
    yield
    global_cache.clear()
```

**Issue: Database conflicts**
```python
# Problem: All workers use same database
DATABASE_URL = "postgres://localhost/test_db"

# Solution: Worker-specific databases
@pytest.fixture(scope="session")
def database_url(worker_id):
    if worker_id == "master":
        return "postgres://localhost/test_db"
    return f"postgres://localhost/test_db_{worker_id}"
```

### Performance Optimization

```python
# Group slow tests to balance load
@pytest.mark.xdist_group(name="slow")
def test_slow_operation_1():
    time.sleep(5)

@pytest.mark.xdist_group(name="slow")
def test_slow_operation_2():
    time.sleep(5)

# Fast tests run independently
def test_fast_operation():
    assert 1 + 1 == 2
```

### Best Practices

1. **Use -n auto** to auto-detect CPUs
2. **Use --dist=loadfile** for better fixture management
3. **Avoid shared state** between tests
4. **Use worker_id fixture** for worker-specific resources
5. **Group related tests** with xdist_group
6. **Test both serial and parallel** to catch race conditions
7. **Use session fixtures carefully** with file locks
8. **Disable for debugging** specific failures

### When NOT to Use xdist

- Tests with heavy shared state
- Tests requiring specific execution order
- Very fast test suites (overhead not worth it)
- Debugging specific test failures
- Tests with complex fixture dependencies

### Tradeoffs

| Aspect | Pros | Cons |
|--------|------|------|
| Speed | 3-10x faster on multi-core | Overhead for small suites |
| Isolation | Catches state-related bugs | Session fixtures complex |
| CI/CD | Faster builds | More CPU usage |
| Debugging | - | Harder to debug failures |

### Documentation

- **Official pytest-xdist:** https://pytest-xdist.readthedocs.io/en/stable/
- **Distribution Guide:** https://pytest-xdist.readthedocs.io/en/stable/distribution.html
- **How-Tos:** https://pytest-xdist.readthedocs.io/en/stable/how-to.html

---

## 6. Textual TUI Testing Approaches

### Overview

Textual provides built-in testing support through the `Pilot` API, which allows automated testing of TUI applications without rendering to a terminal.

### Basic Testing Setup

```bash
# Install testing dependencies
pip install pytest pytest-asyncio
```

**pytest.ini Configuration:**
```ini
[pytest]
asyncio_mode = auto
```

### Pilot Testing (Recommended)

**Basic Test Structure:**
```python
from textual.app import App
from textual.widgets import Button

async def test_basic_app():
    """Test app using Pilot."""
    app = MyApp()
    async with app.run_test() as pilot:
        # App runs in headless mode
        # Pilot allows interaction
        assert app.is_running
```

### Simulating Key Presses

```python
async def test_key_presses():
    """Test keyboard input."""
    app = RGBApp()
    async with app.run_test() as pilot:
        # Press single key
        await pilot.press("r")
        assert app.screen.styles.background == Color.parse("red")

        # Press multiple keys (simulate typing)
        await pilot.press("h", "e", "l", "l", "o")

        # Press special keys
        await pilot.press("enter", "escape", "up", "down")

        # Press with modifiers
        await pilot.press("ctrl+c")
```

### Simulating Clicks

```python
async def test_clicks():
    """Test mouse interactions."""
    app = MyApp()
    async with app.run_test() as pilot:
        # Click by selector
        await pilot.click("#my-button")
        await pilot.click(Button)  # Click first Button

        # Click at coordinates
        await pilot.click()  # Click at (0, 0)
        await pilot.click(offset=(10, 5))  # Click at (10, 5)

        # Click with offset from widget
        await pilot.click(Button, offset=(0, -1))  # Click above button

        # Double/triple click
        await pilot.click("#widget", times=2)  # Double click
        await pilot.click("#widget", times=3)  # Triple click

        # Click with modifiers
        await pilot.click("#item", control=True, shift=True)
```

### Testing Widget State

```python
async def test_widget_state():
    """Verify widget state after interactions."""
    app = MyApp()
    async with app.run_test() as pilot:
        # Query widgets
        button = app.query_one("#submit", Button)
        input_field = app.query_one("#username", Input)

        # Check initial state
        assert not button.disabled
        assert input_field.value == ""

        # Interact and verify
        input_field.value = "testuser"
        await pilot.pause()  # Wait for updates

        await pilot.click("#submit")
        await pilot.pause()

        # Verify state changes
        assert app.submitted_user == "testuser"
```

### Pausing Execution

```python
async def test_with_pause():
    """Use pause to wait for message processing."""
    app = MyApp()
    async with app.run_test() as pilot:
        # Post a message
        app.post_message(MyCustomMessage())

        # Wait for messages to be processed
        await pilot.pause()

        # Or pause with delay
        await pilot.pause(0.1)  # Wait 100ms then process messages
```

### Custom Terminal Size

```python
async def test_custom_size():
    """Test with specific terminal dimensions."""
    app = MyApp()
    async with app.run_test(size=(100, 50)) as pilot:
        # App renders with 100 columns x 50 lines
        assert app.size.width == 100
        assert app.size.height == 50
```

### Snapshot Testing with pytest-textual-snapshot

**Installation:**
```bash
pip install pytest-textual-snapshot
```

**Basic Snapshot Test:**
```python
def test_calculator_snapshot(snap_compare):
    """Compare visual output with saved snapshot."""
    # First run: generates snapshot, test fails
    # Subsequent runs: compares against saved snapshot
    assert snap_compare("path/to/calculator.py")
```

**Update Snapshots:**
```bash
# Review changes in browser report
pytest

# If changes are correct, update snapshots
pytest --snapshot-update
```

**Advanced Snapshot Testing:**
```python
def test_snapshot_with_interaction(snap_compare):
    """Snapshot after simulating user input."""
    assert snap_compare(
        "path/to/app.py",
        press=["1", "2", "3"],  # Press keys before snapshot
        terminal_size=(80, 40),  # Custom size
    )

def test_snapshot_with_setup(snap_compare):
    """Run custom setup before snapshot."""
    async def run_before(pilot):
        await pilot.hover("#number-5")
        await pilot.click("#submit")

    assert snap_compare(
        "path/to/app.py",
        run_before=run_before
    )
```

### Testing Message Handling

```python
from textual.message import Message

class CustomMessage(Message):
    pass

async def test_message_handling():
    """Test custom message processing."""
    app = MyApp()
    async with app.run_test() as pilot:
        message_received = False

        def on_custom_message(message: CustomMessage):
            nonlocal message_received
            message_received = True

        app.on(CustomMessage, on_custom_message)

        # Post message
        app.post_message(CustomMessage())
        await pilot.pause()

        assert message_received
```

### Testing Screens and Navigation

```python
async def test_screen_navigation():
    """Test switching between screens."""
    app = MyApp()
    async with app.run_test() as pilot:
        # Check initial screen
        assert isinstance(app.screen, MainScreen)

        # Navigate to settings
        await pilot.press("s")  # Keyboard shortcut
        await pilot.pause()

        assert isinstance(app.screen, SettingsScreen)

        # Go back
        await pilot.press("escape")
        await pilot.pause()

        assert isinstance(app.screen, MainScreen)
```

### Testing Async Operations

```python
async def test_async_operations():
    """Test async workers and operations."""
    app = MyApp()
    async with app.run_test() as pilot:
        # Trigger async operation
        await pilot.click("#fetch-data")

        # Wait for operation to complete
        await pilot.pause(1.0)  # Allow time for async work

        # Verify result
        result_widget = app.query_one("#result", Static)
        assert "Data loaded" in result_widget.renderable
```

### Best Practices

1. **Use pilot.pause()** after interactions that trigger messages
2. **Query widgets** to verify state changes
3. **Test keyboard shortcuts** in addition to clicks
4. **Use snapshot tests** for visual regression testing
5. **Test different terminal sizes** for responsive layouts
6. **Mock external APIs** for predictable tests
7. **Test error states** and edge cases
8. **Use descriptive test names** that explain what's being tested

### Tradeoffs

| Approach | Pros | Cons | When to Use |
|----------|------|------|-------------|
| Pilot Testing | Fast, automated, no display | Doesn't test actual rendering | Unit/integration tests |
| Snapshot Testing | Catches visual regressions | Snapshots need maintenance | Regression testing |
| Manual Testing | Tests real user experience | Slow, not automated | Final QA, UX testing |
| Output Capture | Simple for basic apps | Limited interaction testing | CLI output tests |

### Common Patterns

**Testing Forms:**
```python
async def test_form_submission():
    app = FormApp()
    async with app.run_test() as pilot:
        # Fill form fields
        name_input = app.query_one("#name", Input)
        email_input = app.query_one("#email", Input)

        name_input.value = "John Doe"
        email_input.value = "john@example.com"
        await pilot.pause()

        # Submit form
        await pilot.click("#submit")
        await pilot.pause()

        # Verify submission
        assert app.form_data["name"] == "John Doe"
```

**Testing Data Tables:**
```python
async def test_data_table():
    app = TableApp()
    async with app.run_test() as pilot:
        table = app.query_one(DataTable)

        # Verify initial data
        assert table.row_count == 5

        # Interact with table
        await pilot.press("down", "down")  # Move cursor
        await pilot.press("enter")  # Select row
        await pilot.pause()

        # Verify selection
        assert table.cursor_row == 2
```

### Documentation

- **Official Textual Testing:** https://textual.textualize.io/guide/testing/
- **Pilot API Reference:** https://textual.textualize.io/api/pilot/
- **pytest-textual-snapshot:** https://github.com/Textualize/pytest-textual-snapshot
- **Textual Test Examples:** https://github.com/Textualize/textual/tree/main/tests

---

## Summary and Recommendations

### For CLI Tools with External Dependencies

**Recommended Stack:**
```bash
pip install pytest pytest-cov pytest-mock pytest-asyncio pytest-xdist
```

**pytest.ini Configuration:**
```ini
[pytest]
minversion = 7.0
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
asyncio_mode = auto
addopts =
    -n auto
    --dist=loadfile
    --cov=myproject
    --cov-branch
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
```

### Coverage Configuration

**.coveragerc:**
```ini
[run]
source = myproject
branch = True
omit =
    */tests/*
    */venv/*
    */.venv/*
    */__pycache__/*

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
    if TYPE_CHECKING:
    @abstractmethod

exclude_also =
    def __str__
    if self.debug:

partial_branches =
    pragma: no branch
```

### Key Takeaways

1. **Use branch coverage** for thorough testing
2. **Leverage fixtures** for idempotent tests
3. **Mock external calls** (subprocess, API, filesystem)
4. **Parametrize** to reduce test duplication
5. **Run in parallel** with xdist for speed
6. **Test TUIs** with Pilot for automation
7. **Aim for 80%+ coverage** on critical code
8. **Write meaningful tests** over chasing 100%

### Further Reading

- **Python Testing with pytest** by Brian Okken
- **Test-Driven Development with Python** by Harry Percival
- **pytest Documentation:** https://docs.pytest.org/
- **Coverage.py Documentation:** https://coverage.readthedocs.io/
