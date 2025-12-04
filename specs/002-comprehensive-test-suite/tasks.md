# Tasks: Comprehensive Test Suite with 100% Coverage

**Input**: Design documents from `/specs/002-comprehensive-test-suite/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: This feature IS the test implementation - all tasks are test-related.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `tests/` at repository root (plugin-curator/)
- Test target: `curator.py` (existing application code)

---

## Phase 1: Setup (Test Infrastructure)

**Purpose**: Initialize test project structure and configuration

**Goal**: Create test directory, install dependencies, configure pytest and coverage

**Independent Test**: `pytest --version` and `pytest --cov --help` both work

- [X] T001 Create tests/ directory structure in plugin-curator/
- [X] T002 [P] Create tests/__init__.py as empty module marker
- [X] T003 [P] Create tests/fixtures/ directory for test data
- [X] T004 [P] Create tests/fixtures/plugins/ directory for sample plugins
- [X] T005 [P] Create tests/fixtures/marketplaces/ directory for sample marketplaces
- [X] T006 [P] Create tests/fixtures/invalid/ directory for error scenario data
- [X] T007 [P] Create tests/integration/ directory for end-to-end tests
- [X] T008 Create requirements-test.txt with pytest>=7.4.0, pytest-cov>=4.1.0, pytest-xdist>=3.3.0, pytest-mock>=3.11.0, pytest-timeout>=2.1.0
- [X] T009 Install test dependencies: pip install -r requirements-test.txt
- [X] T010 Create pytest.ini with test discovery patterns and markers
- [X] T011 Create .coveragerc with coverage configuration (100% threshold, exclusions)
- [X] T012 Verify pytest installation: pytest --version
- [X] T013 Verify coverage plugin: pytest --cov --help

**Checkpoint**: Test infrastructure ready - can run pytest (no tests yet)

---

## Phase 2: Foundational (Shared Fixtures & Utilities)

**Purpose**: Create reusable test fixtures and data providers used across all user stories

**Goal**: Implement conftest.py with shared fixtures, mock helpers, and parameterized data

**Independent Test**: `pytest --fixtures` shows all defined fixtures

- [X] T014 Create tests/conftest.py with module docstring
- [X] T015 [P] Implement tmp_plugin_dir fixture in tests/conftest.py (yields Path, auto-cleanup)
- [X] T016 [P] Implement registry_fixture fixture in tests/conftest.py (temp registry.json with cleanup)
- [X] T017 [P] Implement mock_git_clone fixture in tests/conftest.py (mocks subprocess.run for git)
- [X] T018 [P] Create sample_minimal_plugin fixture factory in tests/conftest.py
- [X] T019 [P] Create sample_complete_plugin fixture factory in tests/conftest.py
- [X] T020 [P] Create sample_empty_plugin fixture factory in tests/conftest.py
- [X] T021 [P] Create sample_malformed_plugin fixture factory in tests/conftest.py
- [X] T022 [P] Define git_url_formats data provider in tests/conftest.py (from test-parameterization.yaml)
- [X] T023 [P] Define registry_states data provider in tests/conftest.py (empty, single, multiple)
- [X] T024 [P] Define plugin_json_scenarios data provider in tests/conftest.py
- [X] T025 [P] Define error_scenarios data provider in tests/conftest.py
- [X] T026 Verify fixtures: pytest --fixtures | grep -E "(tmp_plugin_dir|registry_fixture|mock_git_clone)"

**Checkpoint**: Shared fixtures available - all test modules can use them

---

## Phase 3: User Story 1 - Core Functionality Validation (Priority: P1)

**Purpose**: Test core operations for add-plugin, add-marketplace, select, discovery, and registry

**Goal**: Achieve 70%+ coverage by testing all primary workflows

**Independent Test**: `pytest tests/test_registry.py tests/test_discovery.py tests/test_cli.py -v` passes with >70% coverage

### Registry Operations Tests

- [X] T027 [P] [US1] Create tests/test_registry.py with module docstring
- [X] T028 [US1] Implement test_load_empty_registry in tests/test_registry.py (no file exists)
- [X] T029 [US1] Implement test_load_existing_registry in tests/test_registry.py (valid JSON)
- [X] T030 [US1] Implement test_save_registry in tests/test_registry.py (write and verify)
- [X] T031 [US1] Implement test_load_corrupted_registry in tests/test_registry.py (invalid JSON, fallback)
- [X] T032 [US1] Implement test_registry_save_load_roundtrip in tests/test_registry.py (idempotency)

### Component Discovery Tests

- [X] T033 [P] [US1] Create tests/test_discovery.py with module docstring
- [X] T034 [US1] Implement test_discover_commands_default_path in tests/test_discovery.py
- [X] T035 [US1] Implement test_discover_commands_custom_path in tests/test_discovery.py (plugin.json override)
- [X] T036 [US1] Implement test_discover_commands_no_directory in tests/test_discovery.py (returns empty)
- [X] T037 [US1] Implement test_discover_agents_default_path in tests/test_discovery.py
- [X] T038 [US1] Implement test_discover_agents_custom_path in tests/test_discovery.py
- [X] T039 [US1] Implement test_discover_skills_default_path in tests/test_discovery.py
- [X] T040 [US1] Implement test_discover_skills_custom_path in tests/test_discovery.py
- [X] T041 [US1] Implement test_discover_hooks_from_hooks_json in tests/test_discovery.py
- [X] T042 [US1] Implement test_discover_hooks_no_file in tests/test_discovery.py (returns empty)
- [X] T043 [US1] Implement test_discover_mcps_from_mcp_json in tests/test_discovery.py
- [X] T044 [US1] Implement test_discover_mcps_no_file in tests/test_discovery.py (returns empty)
- [X] T045 [US1] Parameterize discovery tests with @pytest.mark.parametrize using plugin structures

### CLI Commands Tests

- [X] T046 [P] [US1] Create tests/test_cli.py with module docstring
- [X] T047 [US1] Implement test_add_plugin_local_path in tests/test_cli.py (uses tmp_plugin_dir)
- [X] T048 [US1] Implement test_add_plugin_remote_url in tests/test_cli.py (mocks git clone)
- [X] T049 [US1] Implement test_add_plugin_no_plugin_json in tests/test_cli.py (fallback to dir name)
- [X] T050 [US1] Implement test_add_marketplace_local in tests/test_cli.py
- [X] T051 [US1] Implement test_add_marketplace_remote in tests/test_cli.py (mocks git clone)
- [X] T052 [US1] Implement test_select_with_populated_registry in tests/test_cli.py
- [X] T053 [US1] Implement test_select_with_empty_registry in tests/test_cli.py (error message)
- [X] T054 [US1] Implement test_add_plugin_invalid_path in tests/test_cli.py (error handling)
- [X] T055 [US1] Parameterize CLI tests with git_url_formats data provider

**Checkpoint US1**: Core functionality tests pass, coverage ≥ 70%

---

## Phase 4: User Story 2 - Edge Case Coverage (Priority: P2)

**Purpose**: Test edge cases, boundary conditions, and error scenarios

**Goal**: Increase coverage to 90%+ by testing all edge cases and error paths

**Independent Test**: `pytest tests/test_edge_cases.py -v` passes, coverage ≥ 90%

### Edge Case Tests

- [X] T056 [P] [US2] Create tests/test_edge_cases.py with module docstring
- [X] T057 [US2] Implement test_empty_plugin_all_components in tests/test_edge_cases.py
- [X] T058 [US2] Implement test_malformed_plugin_json in tests/test_edge_cases.py
- [X] T059 [US2] Implement test_malformed_hooks_json in tests/test_edge_cases.py
- [X] T060 [US2] Implement test_malformed_mcp_json in tests/test_edge_cases.py
- [X] T061 [US2] Implement test_git_clone_timeout in tests/test_edge_cases.py (mock timeout)
- [X] T062 [US2] Implement test_git_clone_auth_required in tests/test_edge_cases.py
- [X] T063 [US2] Implement test_file_permission_denied in tests/test_edge_cases.py
- [X] T064 [US2] Implement test_disk_full_on_save in tests/test_edge_cases.py (mock OSError)
- [X] T065 [US2] Implement test_special_chars_in_paths in tests/test_edge_cases.py (unicode, spaces)
- [X] T066 [US2] Implement test_symlinks_in_plugin in tests/test_edge_cases.py
- [X] T067 [US2] Implement test_large_plugin_performance in tests/test_edge_cases.py (100+ components)
- [X] T068 [US2] Implement test_partial_marketplace_failure in tests/test_edge_cases.py (mixed valid/invalid)
- [X] T069 [US2] Implement test_concurrent_registry_access in tests/test_edge_cases.py (parallel writes)
- [X] T070 [US2] Implement test_nested_subdirectories in tests/test_edge_cases.py (should ignore)
- [X] T071 [US2] Implement test_non_md_files in tests/test_edge_cases.py (only .md indexed)
- [X] T072 [US2] Parameterize edge cases with error_scenarios data provider

**Checkpoint US2**: Edge case tests pass, coverage ≥ 90%

---

## Phase 5: User Story 3 - Idempotent Test Execution (Priority: P1)

**Purpose**: Ensure tests are idempotent, isolated, and can run in any order

**Goal**: Validate test suite reliability and parallel execution safety

**Independent Test**: `pytest --random-order --count=10` passes consistently, `pytest -n auto` passes

### Idempotency Tests

- [ ] T073 [US3] Implement test_fixtures_cleanup_on_success in tests/test_registry.py
- [ ] T074 [US3] Implement test_fixtures_cleanup_on_failure in tests/test_registry.py
- [ ] T075 [US3] Verify all fixtures use yield for cleanup in tests/conftest.py
- [ ] T076 [US3] Add autouse fixture to validate no temp files remain in tests/conftest.py
- [ ] T077 [US3] Run pytest --random-order 10 times, verify all pass
- [ ] T078 [US3] Run pytest -n auto, verify no race conditions
- [ ] T079 [US3] Run pytest --random-order-seed=12345 twice, verify identical results
- [ ] T080 [US3] Add fixture scoping validation in tests/conftest.py (function scope for isolation)

**Checkpoint US3**: Tests pass in random order, parallel execution works, no flakiness

---

## Phase 6: User Story 4 - Parameterized Test Data Providers (Priority: P2)

**Purpose**: Implement parameterized tests to cover multiple input combinations efficiently

**Goal**: Maximize test coverage with minimal code duplication via parameterization

**Independent Test**: `pytest -v | grep -E "\\[.*\\]"` shows parameterized test variations

### Parameterization Implementation

- [ ] T081 [US4] Refactor test_discover_commands with @pytest.mark.parametrize in tests/test_discovery.py
- [ ] T082 [US4] Refactor test_discover_agents with @pytest.mark.parametrize in tests/test_discovery.py
- [ ] T083 [US4] Refactor test_discover_skills with @pytest.mark.parametrize in tests/test_discovery.py
- [ ] T084 [US4] Refactor test_discover_hooks with @pytest.mark.parametrize in tests/test_discovery.py
- [ ] T085 [US4] Refactor test_discover_mcps with @pytest.mark.parametrize in tests/test_discovery.py
- [ ] T086 [US4] Refactor test_add_plugin with git_url_formats parametrization in tests/test_cli.py
- [ ] T087 [US4] Refactor test_registry_states with parameterization in tests/test_registry.py
- [ ] T088 [US4] Refactor edge cases with error_scenarios parametrization in tests/test_edge_cases.py
- [ ] T089 [US4] Add pytest.param with ids= for readable test names
- [ ] T090 [US4] Verify parameterization: pytest --collect-only | grep -c "\\["

**Checkpoint US4**: All major test functions parameterized, test count > 100

---

## Phase 7: Integration Tests (End-to-End)

**Purpose**: Validate complete workflows with real file system and Git operations

**Goal**: Ensure integration between components works correctly

**Independent Test**: `pytest tests/integration/ -v` passes

- [ ] T091 [P] Create tests/integration/__init__.py
- [ ] T092 [P] Create tests/integration/test_local_plugin.py with module docstring
- [ ] T093 Implement test_e2e_local_plugin_add_and_select in tests/integration/test_local_plugin.py
- [ ] T094 Implement test_e2e_local_marketplace_full_flow in tests/integration/test_local_plugin.py
- [ ] T095 [P] Create tests/integration/test_remote_plugin.py with module docstring
- [ ] T096 Implement test_e2e_remote_plugin_clone_and_index in tests/integration/test_remote_plugin.py (uses real git)
- [ ] T097 Implement test_e2e_remote_marketplace_full_flow in tests/integration/test_remote_plugin.py
- [ ] T098 Implement test_e2e_cleanup_after_remote_clone in tests/integration/test_remote_plugin.py

**Checkpoint Integration**: End-to-end tests pass with real operations

---

## Phase 8: TUI Testing (Where Feasible)

**Purpose**: Test TUI behavior (component listing, selection output)

**Goal**: Validate TUI functionality through output capture

**Independent Test**: `pytest tests/test_tui.py -v` passes

- [X] T099 [P] Create tests/test_tui.py with module docstring
- [X] T100 Implement test_flatten_components in tests/test_tui.py (correct data structure)
- [X] T101 Implement test_flatten_components_sorting in tests/test_tui.py (by plugin, type, name)
- [X] T102 Implement test_component_list_display_format in tests/test_tui.py (checkbox format)
- [X] T103 Implement test_tui_empty_registry in tests/test_tui.py (error message)
- [X] T104 [P] Research Textual pilot testing feasibility for navigation tests
- [X] T105 [P] Implement test_tui_keyboard_navigation if pilot testing feasible

**Checkpoint TUI**: TUI tests pass where technically feasible

---

## Phase 9: Coverage Validation & Optimization

**Purpose**: Achieve and validate 100% code and branch coverage

**Goal**: Fill coverage gaps, optimize test execution time

**Independent Test**: `pytest --cov=curator --cov-branch --cov-fail-under=100` passes

- [ ] T106 Run pytest --cov=curator --cov-branch --cov-report=html
- [ ] T107 Identify uncovered lines from htmlcov/curator_py.html
- [ ] T108 Identify uncovered branches from coverage report
- [ ] T109 Implement tests for uncovered exception paths in relevant test files
- [ ] T110 Implement tests for uncovered branch conditions in relevant test files
- [ ] T111 Implement tests for uncovered error handling in relevant test files
- [ ] T112 Verify 100% line coverage: pytest --cov=curator --cov-report=term-missing
- [ ] T113 Verify 100% branch coverage: pytest --cov=curator --cov-branch --cov-report=term-missing
- [ ] T114 Validate coverage threshold enforcement: pytest --cov=curator --cov-fail-under=100
- [ ] T115 Optimize slow tests: pytest --durations=10, refactor if needed
- [ ] T116 Validate execution time: time pytest -n auto < 2 minutes

**Checkpoint Coverage**: 100% line and branch coverage achieved, < 2 minute execution

---

## Phase 10: CI/CD Integration & Documentation

**Purpose**: Configure CI/CD pipeline and document test suite usage

**Goal**: Enable automated testing in GitHub Actions and provide developer guide

**Independent Test**: GitHub Actions workflow runs and passes

- [ ] T117 [P] Create .github/workflows/test.yml for GitHub Actions
- [ ] T118 [P] Configure workflow with Python 3.11 setup in .github/workflows/test.yml
- [ ] T119 [P] Add pytest execution step with coverage in .github/workflows/test.yml
- [ ] T120 [P] Add coverage upload to Codecov in .github/workflows/test.yml
- [ ] T121 [P] Add coverage enforcement step (fail if < 100%) in .github/workflows/test.yml
- [ ] T122 [P] Add coverage report artifact upload in .github/workflows/test.yml
- [ ] T123 [P] Create pre-commit hook script .git/hooks/pre-commit for local testing
- [ ] T124 Make pre-commit hook executable: chmod +x .git/hooks/pre-commit
- [ ] T125 [P] Update README.md with test suite section (how to run tests)
- [ ] T126 [P] Update README.md with coverage badges from Codecov
- [ ] T127 Test GitHub Actions workflow locally: act push (if act installed)
- [ ] T128 Push to trigger GitHub Actions, verify workflow passes

**Checkpoint CI/CD**: Automated tests run in CI/CD, documentation complete

---

## Phase 11: Polish & Validation

**Purpose**: Final validation, cleanup, and quality assurance

**Goal**: Ensure test suite meets all success criteria

**Independent Test**: All success criteria from spec.md are met

- [ ] T129 Run full test suite: pytest --cov=curator --cov-branch --cov-fail-under=100 -n auto
- [ ] T130 Verify zero test flakiness: pytest --random-order --count=10
- [ ] T131 Verify parallel execution: pytest -n auto (all tests pass)
- [ ] T132 Verify coverage reports generated: ls htmlcov/index.html coverage.xml
- [ ] T133 Verify test count ≥ 50 edge cases: pytest --collect-only | grep -c edge_case
- [ ] T134 Verify test code < 2000 lines: wc -l tests/*.py tests/integration/*.py
- [ ] T135 Validate all fixtures have proper cleanup (no temp file leaks)
- [ ] T136 Validate all error messages in tests match expected patterns
- [ ] T137 Review test organization: each user story independently testable
- [ ] T138 Final coverage validation: pytest --cov=curator --cov-branch --cov-report=term-missing
- [ ] T139 Update tasks.md: Mark all completed tasks with [X]
- [ ] T140 Create summary report: total tests, coverage %, execution time, flakiness score

**Checkpoint Polish**: All success criteria met, test suite production-ready

---

## Dependencies & Execution Order

### User Story Dependencies

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational) ← Must complete before any user story
    ↓
    ├─→ Phase 3 (US1 - Core Functionality) ← MVP baseline, must complete first
    │       ↓
    │   ├─→ Phase 4 (US2 - Edge Cases) ← Depends on US1 tests as foundation
    │   │
    │   └─→ Phase 5 (US3 - Idempotency) ← Can run parallel with US4
    │
    └─→ Phase 6 (US4 - Parameterization) ← Refactors US1/US2 tests
            ↓
        Phase 7 (Integration) ← Validates US1-US4 together
            ↓
        Phase 8 (TUI) ← Independent, can run parallel with coverage
            ↓
        Phase 9 (Coverage) ← Fills gaps from US1-US4
            ↓
        Phase 10 (CI/CD) ← Infrastructure setup
            ↓
        Phase 11 (Polish) ← Final validation
```

### Critical Path

1. **Setup → Foundational** (required for all tests)
2. **US1 (Core Functionality)** (establishes baseline coverage)
3. **US2 (Edge Cases) + US3 (Idempotency)** (can run parallel)
4. **US4 (Parameterization)** (refactors existing tests)
5. **Coverage Validation** (achieves 100%)
6. **Integration + CI/CD** (final validation)

### Parallel Opportunities

**Within Setup Phase** (T002-T007):
- All directory creation tasks can run parallel

**Within Foundational Phase** (T015-T025):
- All fixture and data provider creation tasks can run parallel after T014

**Within US1 Phase**:
- T027 (create test_registry.py) parallel with T033 (create test_discovery.py) parallel with T046 (create test_cli.py)
- Registry tests (T028-T032) can run parallel with discovery tests (T034-T045) after file creation

**Within US2 Phase** (T056-T072):
- All edge case test implementations can run parallel after T056

**Within US4 Phase** (T081-T090):
- All parameterization refactorings can run parallel

**Within CI/CD Phase** (T117-T126):
- All documentation and workflow creation tasks can run parallel

---

## Implementation Strategy

### MVP Scope (Minimum Viable Product)

**Phase 1 + Phase 2 + Phase 3 (US1) = MVP**

This delivers:
- Complete test infrastructure
- Core functionality tests (70% coverage)
- Basic validation of add-plugin, add-marketplace, select, discovery, registry
- Foundation for additional test coverage

**MVP Validation**: `pytest tests/test_registry.py tests/test_discovery.py tests/test_cli.py --cov=curator` shows 70%+ coverage

### Incremental Delivery

1. **Iteration 1** (MVP): Phase 1-3 (US1) → 70% coverage, core workflows tested
2. **Iteration 2**: +Phase 4 (US2) → 90% coverage, edge cases handled
3. **Iteration 3**: +Phase 5-6 (US3, US4) → Idempotent, parameterized tests
4. **Iteration 4**: +Phase 7-9 → 100% coverage, integration validated
5. **Iteration 5**: +Phase 10-11 → CI/CD integrated, production-ready

### Validation Checkpoints

After each phase, validate:
- **Phase 1**: `pytest --version` works
- **Phase 2**: `pytest --fixtures` shows all fixtures
- **Phase 3**: `pytest tests/test_*.py --cov=curator` shows 70%+ coverage
- **Phase 4**: Coverage increases to 90%+
- **Phase 5**: `pytest --random-order --count=10` passes consistently
- **Phase 6**: Test count > 100 due to parameterization
- **Phase 7**: Integration tests pass with real operations
- **Phase 8**: TUI tests pass
- **Phase 9**: `pytest --cov-fail-under=100` passes
- **Phase 10**: GitHub Actions workflow passes
- **Phase 11**: All success criteria met

---

## Success Criteria Mapping

| Success Criterion | Validated By Tasks |
|-------------------|-------------------|
| SC-001: 100% line coverage | T106-T114 |
| SC-002: Consistent across 10 runs | T077, T130 |
| SC-003: < 2 minute execution | T116, T129 |
| SC-004: Zero flakiness | T073-T080, T130 |
| SC-005: 50+ edge cases | T056-T072, T133 |
| SC-006: All error paths covered | T108-T111 |
| SC-007: Test code < 2000 lines | T134 |
| SC-008: 100% branch coverage | T108, T113 |
| SC-009: Parallel execution safe | T078, T131 |
| SC-010: CI/CD pipeline passes | T117-T128 |

---

## Task Count Summary

- **Total Tasks**: 140
- **Phase 1 (Setup)**: 13 tasks
- **Phase 2 (Foundational)**: 13 tasks
- **Phase 3 (US1 - Core)**: 29 tasks
- **Phase 4 (US2 - Edge Cases)**: 17 tasks
- **Phase 5 (US3 - Idempotency)**: 8 tasks
- **Phase 6 (US4 - Parameterization)**: 10 tasks
- **Phase 7 (Integration)**: 8 tasks
- **Phase 8 (TUI)**: 7 tasks
- **Phase 9 (Coverage)**: 11 tasks
- **Phase 10 (CI/CD)**: 12 tasks
- **Phase 11 (Polish)**: 12 tasks

**Parallel Opportunities**: 40+ tasks marked with [P]

**Estimated Effort**: 10-15 hours (following incremental delivery strategy)

---

## Notes

- All tasks follow strict checkbox format: `- [ ] [ID] [P?] [Story?] Description with file path`
- Tests are THE feature (not optional) - all tasks are test implementation
- Each user story phase is independently testable
- Idempotency is validated throughout (US3 focus, but checked in all phases)
- Parameterization is applied progressively (US4 refactors earlier tests)
- Coverage goal is 100% (not 80% or 90%)
- Performance goal is < 2 minutes total execution time
- All fixtures must use yield for proper cleanup
- All edge cases must be parameterized for maintainability
