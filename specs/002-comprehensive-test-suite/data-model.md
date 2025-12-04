# Data Model: Comprehensive Test Suite

**Feature**: 002-comprehensive-test-suite
**Purpose**: Define test entities, fixture structures, and data relationships for the pytest test suite
**Created**: 2025-11-11

## Test Entities

### 1. TestPlugin

**Purpose**: Represents a sample plugin structure used as test data

**Attributes**:
- `name` (str): Plugin identifier
- `root_path` (Path): Absolute path to plugin directory
- `has_plugin_json` (bool): Whether `.claude-plugin/plugin.json` exists
- `component_counts` (dict): Count of each component type
  - `commands` (int): Number of command files
  - `agents` (int): Number of agent files
  - `skills` (int): Number of skill directories
  - `hooks` (int): Number of hook definitions
  - `mcps` (int): Number of MCP server configurations

**Variations**:
- **minimal**: Basic plugin structure with no components
- **complete**: All component types present
- **empty**: Valid structure but zero components
- **malformed**: Invalid plugin.json syntax
- **large**: Hundreds of components for performance testing

**Relationships**:
- Contained in `TestMarketplace` (1-to-many)
- Referenced by `TestDataProvider` for parameterization

---

### 2. TestFixture

**Purpose**: Manages temporary test environments with automatic cleanup

**Attributes**:
- `temp_dir` (Path): Temporary directory for test isolation
- `cleanup_funcs` (list): Functions to call during teardown
- `isolation_level` (str): Scope of fixture (function, module, session)
- `created_files` (list): Tracks files created during test
- `mock_objects` (list): Tracks mocked objects for cleanup

**Lifecycle**:
1. **Setup**: Create temporary directory, initialize tracking
2. **Test Execution**: Provide resources to test functions
3. **Teardown**: Execute cleanup functions, remove temporary files

**Cleanup Strategy**:
- Use yield fixtures for automatic cleanup
- Register finalizers for exception-safe cleanup
- Track all created resources for complete removal

**Relationships**:
- Used by all test functions requiring file system isolation
- Contains `TestPlugin` instances

---

### 3. MockOperation

**Purpose**: Simulates external operation failures for testing error paths

**Attributes**:
- `operation_type` (str): Type of operation (git, file, network)
- `failure_mode` (str): How the operation fails
- `expected_error` (str): Expected error message pattern
- `call_count` (int): How many times operation is called before failing
- `side_effect` (callable): Custom failure behavior

**Failure Modes**:
- **timeout**: Operation exceeds time limit
- **permission_denied**: Insufficient file system permissions
- **not_found**: Resource does not exist
- **malformed_data**: Data parsing error
- **network_error**: Connection or DNS failure
- **disk_full**: Insufficient disk space

**Usage Patterns**:
- Use `mocker.patch()` to replace real operations
- Configure `side_effect` for specific failure scenarios
- Assert correct error handling and messages

**Relationships**:
- Applied to functions under test via pytest-mock
- Validates error handling in curator.py

---

### 4. TestDataProvider

**Purpose**: Parameterized test data sets with expected outcomes

**Attributes**:
- `parameter_set` (dict): Input parameters for test
- `expected_outcome` (dict): Expected results or exceptions
- `test_id` (str): Unique identifier for test case
- `category` (str): Classification (valid, invalid, edge_case)
- `description` (str): Human-readable test purpose

**Categories**:
- **valid_inputs**: Normal, expected usage patterns
- **invalid_inputs**: Incorrect or malformed input
- **edge_cases**: Boundary conditions and unusual scenarios

**Example Structure**:
```python
{
    "test_id": "empty_plugin",
    "category": "edge_case",
    "parameter_set": {
        "plugin_path": "/tmp/empty-plugin",
        "has_components": False
    },
    "expected_outcome": {
        "registry_entry": True,
        "component_count": 0,
        "error": None
    },
    "description": "Plugin with valid structure but no components"
}
```

**Relationships**:
- Consumed by @pytest.mark.parametrize decorators
- References `TestPlugin` and `MockOperation` instances

---

### 5. TestMarketplace

**Purpose**: Represents sample marketplace structures for integration testing

**Attributes**:
- `name` (str): Marketplace identifier
- `root_path` (Path): Marketplace directory path
- `plugins` (list[TestPlugin]): List of plugins in marketplace
- `marketplace_json` (dict): Parsed marketplace.json content
- `has_errors` (bool): Whether marketplace contains invalid plugins

**Variations**:
- **valid_marketplace**: All plugins valid
- **mixed_marketplace**: Some valid, some invalid plugins
- **empty_marketplace**: Valid structure, no plugins
- **malformed_marketplace**: Invalid marketplace.json

**Relationships**:
- Contains multiple `TestPlugin` instances
- Used by integration tests for add-marketplace command

---

### 6. CoverageReport

**Purpose**: Tracks and validates test coverage metrics

**Attributes**:
- `total_lines` (int): Total executable lines in curator.py
- `covered_lines` (int): Lines executed during tests
- `total_branches` (int): Total decision branches
- `covered_branches` (int): Branches executed during tests
- `line_percentage` (float): Line coverage percentage
- `branch_percentage` (float): Branch coverage percentage
- `missing_lines` (list): Line numbers not covered
- `missing_branches` (list): Branch paths not covered

**Thresholds**:
- `line_coverage_min`: 100%
- `branch_coverage_min`: 100%

**Validation**:
- Generated by pytest-cov after test execution
- Fails build if thresholds not met
- Identifies uncovered code paths

**Relationships**:
- Produced by test execution
- Validated against success criteria in spec.md

---

## Entity Relationships

```
TestMarketplace (1) ─── contains ──> (N) TestPlugin
       │
       │ provides test data
       ↓
TestDataProvider ──> parameterizes ──> Test Functions
       │
       │ references
       ↓
MockOperation ──> simulates failures ──> External Operations
       │
       │ validates
       ↓
CoverageReport <── produced by <── Test Execution
```

## Fixture Scopes

| Fixture Type | Scope | Rationale | Examples |
|--------------|-------|-----------|----------|
| Temp directories | function | Isolation per test | `tmp_plugin_dir` |
| Mock operations | function | Clean slate each test | `mock_git_clone` |
| Sample plugins | module | Reuse across test class | `sample_plugins` |
| Coverage config | session | Single configuration | `coverage_config` |

## State Management

**Idempotency Requirements**:
- All fixtures must clean up after themselves
- No shared state between tests
- Random execution order must work
- Parallel execution must be safe

**Cleanup Strategies**:
1. **Automatic**: Yield fixtures with teardown code
2. **Explicit**: Register finalizers with `request.addfinalizer()`
3. **Autouse**: Mark fixtures as `autouse=True` for automatic application
4. **Scoped**: Use appropriate scope (function, module, session)

## Data Validation

**Registry Schema Validation**:
- Validate registry.json structure matches expected format
- Ensure all component paths are relative
- Verify JSON is well-formed and parsable

**Component Discovery Validation**:
- Assert correct component counts
- Verify paths are relative to plugin root
- Validate handling of missing/malformed files

**Error Message Validation**:
- Assert error messages match expected patterns
- Verify user-friendly error guidance
- Validate exit codes for different error types
