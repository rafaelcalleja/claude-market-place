# Advanced Continuous Delivery Best Practices

> Source: https://to-be-continuous.gitlab.io/doc/advanced-cd/

## Overview

This guide addresses sophisticated deployment considerations for hosted, server-based applications, focusing on three critical areas:

1. **Review Apps** deployment strategy
2. **GitOps and pull-based deployment** implications
3. **Deployment code repository organization**

---

## Review Apps

### Rationale for Adoption

"Review Apps are dynamic and ephemeral environments to deploy your _ongoing developments_" enabling teams to test code early in development cycles. They facilitate automated acceptance testing and increase confidence in code changes before merging.

**Benefits**:
- Test code early in development cycles
- Facilitate automated acceptance testing
- Increase confidence in code changes before merging
- Enable parallel development workflows

### Barriers to Implementation

Organizations may face obstacles:
- **Resource constraints** preventing review environment maintenance
- **Organizational readiness** limitations for continuous delivery practices
- **Release-oriented delivery models** prioritizing staged deployments

### Trade-offs Without Review Apps

Omitting review environments typically necessitates adopting Gitflow branching models with integration environments.

**Consequences**:
- Acceptance testing automation becomes problematic
- Quality validation pushed later in development pipelines
- Increased risk of integration issues

### Alternative: Container-Based Testing

For containerized, standalone applications, running the app as a service within test jobs provides an alternative:

```yaml
cypress:
  services:
    - name: "$DOCKER_SNAPSHOT_IMAGE"
      alias: "myapp"
      command: ["--dev"]
  variables:
    environment_url: "http://myapp"
```

**Advantages**:
- Enables test execution without dedicated review environments
- Reduces infrastructure overhead
- Suitable for standalone containerized applications

---

## Pull-Based Deployment & GitOps

GitOps establishes two foundational principles:

1. **Git repositories serve as the authoritative deployment state source**
2. **Asynchronous, pull-based reconciliation replaces synchronous push operations**

### Synchronization Challenges

Pull-based strategies introduce fundamental difficulties:

- **Deployment triggers are fire-and-forget** - lacking native synchronization for orchestrating downstream tasks
- **Pipeline orchestration becomes problematic** - no confirmation of deployment success
- **Testing coordination** - difficult to orchestrate acceptance tests after deployment

### Hybrid Recommendation (Best Practice)

**"Keep a push-based deployment technique for non-prod environments"** while adopting GitOps for production.

**Architecture**:

```
Development → Staging → Integration → Review
  (Push-based deployment)
            ↓
      Production
    (GitOps pull-based)
```

**Benefits**:
- Preserves pipeline orchestration benefits across pre-production stages
- Leverages GitOps stability for production infrastructure
- Enables automated testing flows in non-production
- Provides deployment confirmation for orchestration

**Implementation Pattern**:
1. Use **push-based deployment** for staging, integration, and review environments
2. Publish **versioned artifacts** to registries upon successful testing
3. **Optionally trigger GitOps deployments** via Git commits referencing new artifact versions

---

## Deployment Code Repository Structure

### Organizational Considerations

**When to separate deployment code from application code**:

Separation suits scenarios involving:
- **Distinct teams** managing infrastructure versus application logic
- **Independent versioning** and lifecycle management requirements
- **GitOps-based deployment** strategies
- **Shared infrastructure** across multiple applications

### Coordination Challenges

Decoupled repositories create friction points:

- **Triggering deployments** from application pipelines
- **Maintaining environment synchronization** during infrastructure code changes
- **Version compatibility** between application and deployment code
- **Testing changes** across repository boundaries

### Best Practice Architecture

**Recommended pattern**: Implement deployment code as **independently versioned packages** published to registries.

**Package formats**:
- Helm charts
- Terraform modules
- Kubernetes manifests
- CloudFormation templates

**Workflow**:

```
Deployment Code Repository
    ↓
Publish versioned package (e.g., helm-chart:1.2.3)
    ↓
Application Pipeline references pinned version
    ↓
Explicit version update when deployment code releases
```

**Design ensures**:
- ✅ Independent release cycles for deployment and application code
- ✅ Clear version contracts between components
- ✅ Auditability of infrastructure changes alongside application deployments
- ✅ Controlled rollout of infrastructure changes

---

## Decision Matrix

### Should You Use Review Apps?

| Factor | Use Review Apps | Alternative (Container Testing) |
|--------|-----------------|--------------------------------|
| **Application Type** | Multi-service, stateful | Standalone, containerized |
| **Resource Availability** | Sufficient infrastructure | Limited resources |
| **Team Size** | Multiple developers | Small team |
| **Testing Strategy** | E2E acceptance tests | Unit + integration tests |

### Should You Use GitOps?

| Environment | Deployment Strategy | Rationale |
|-------------|-------------------|-----------|
| **Production** | GitOps (pull-based) | Audit trail, declarative state |
| **Staging** | Push-based | Pipeline orchestration, testing |
| **Review** | Push-based | Ephemeral, orchestrated cleanup |
| **Integration** | Push-based | Automated testing flows |

### Should You Separate Deployment Code?

| Scenario | Separate Repository | Monorepo |
|----------|-------------------|----------|
| **Different teams** | ✅ Yes | ❌ No |
| **GitOps strategy** | ✅ Yes | ❌ No |
| **Shared infrastructure** | ✅ Yes | ⚠️ Maybe |
| **Simple app + deploy** | ❌ No | ✅ Yes |

---

## Key Takeaways

1. **Review Apps are valuable but not always necessary** - Container-based testing can suffice for standalone apps
2. **Hybrid deployment strategy is optimal** - Push for non-prod, GitOps for production
3. **Deployment code separation depends on team structure** - Don't separate prematurely
4. **Version contracts are critical** - Pin deployment package versions explicitly
5. **Pipeline orchestration matters** - Push-based enables better test automation

---

## Related to-be-continuous Templates

These best practices inform the design of:
- **Kubernetes template** - Supports both push and GitOps patterns
- **Helm template** - Versioned chart publishing and deployment
- **Docker template** - Container image building for testing
- **Review apps** - Ephemeral environment creation

Consult specific template documentation for implementation details.
