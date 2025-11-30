# Testing Guide for gitlab-tbc Plugin

Complete testing guide to verify the plugin works correctly.

---

## 🚀 Pre-requisites

Before testing, ensure:
- [ ] Claude Code is installed (`cc --version` works)
- [ ] You're in the correct directory: `/home/rcalleja/github/nalanda/documents_stored_procedures/`
- [ ] Plugin directory exists: `gitlab-tbc/`

---

## 📋 Test Plan

### Phase 1: Plugin Loading ⚙️

**Test 1.1: Load Plugin**
```bash
cc --plugin-dir gitlab-tbc
```

**Expected Result:**
- Claude Code starts without errors
- No "plugin failed to load" messages
- Welcome message appears

**✅ Pass Criteria:**
- Plugin loads successfully
- No error messages in console

---

**Test 1.2: Verify Plugin Components**

Once Claude Code is running, type:
```
/help
```

**Expected Result:**
- `/discover` command appears in the list
- Description: "Search for to-be-continuous templates by technology stack"

**✅ Pass Criteria:**
- Command is listed
- Description matches

---

### Phase 2: Basic Command Testing 🔍

**Test 2.1: Simple Technology Search**

Try this command:
```bash
/discover python
```

**Expected Result:**
```
Found templates for Python:

📦 Build Template:
- Python - Build template for Python
  https://gitlab.com/to-be-continuous/python

💡 Commonly Combined With:
- SonarQube (code quality)
- Docker (containerization)
- Gitleaks (security scanning)

📚 Related Samples:
- python-library
- python-on-kubernetes
- python-serverless-on-aws
```

**✅ Pass Criteria:**
- Shows Python template with URL
- Suggests complementary templates (SonarQube, Docker, Gitleaks)
- Lists related samples
- All URLs are clickable and correct

---

**Test 2.2: Multiple Technologies**

```bash
/discover python docker kubernetes
```

**Expected Result:**
```
Found templates for Python + Docker + Kubernetes:

📦 Build & Package:
1. Python - Build template for Python
   https://gitlab.com/to-be-continuous/python

2. Docker - Build, test and scan container images
   https://gitlab.com/to-be-continuous/docker

3. Kubernetes - Kubernetes deployment
   https://gitlab.com/to-be-continuous/kubernetes

💡 Recommended Additions:
- SonarQube (code quality)
- Gitleaks (secret scanning)
- Postman or Bruno (API testing)

📚 Perfect Sample:
- python-on-kubernetes
  https://gitlab.com/to-be-continuous/samples/python-on-kubernetes
  Uses: Python, SonarQube, Docker, Kubernetes, Postman, Bruno
```

**✅ Pass Criteria:**
- Shows all 3 templates
- Provides intelligent suggestions
- Shows most relevant sample (python-on-kubernetes)
- Sample description matches

---

**Test 2.3: Ambiguous Query**

```bash
/discover java
```

**Expected Result:**
```
Found multiple Java templates:

📦 Build Systems:
1. Maven - Maven builds (most common for Java)
   https://gitlab.com/to-be-continuous/maven

2. Gradle - Gradle builds (modern alternative)
   https://gitlab.com/to-be-continuous/gradle

3. sbt - sbt builds (for Scala/Java)
   https://gitlab.com/to-be-continuous/sbt

❓ Which do you use?
- Maven: Traditional, XML-based
- Gradle: Modern, Groovy/Kotlin DSL
- sbt: Scala Build Tool

📚 Samples available for each:
- maven-on-kubernetes
- maven-on-openshift
- maven-on-gcloud
```

**✅ Pass Criteria:**
- Shows all 3 Java build options
- Explains differences
- Lists samples for each

---

**Test 2.4: Testing Templates**

```bash
/discover testing api
```

**Expected Result:**
```
Found API testing templates:

🧪 API Testing:
1. Postman - Testing template for Postman
   https://gitlab.com/to-be-continuous/postman

2. Bruno - Testing template for Bruno
   https://gitlab.com/to-be-continuous/bruno

3. Hurl - Testing template for Hurl
   https://gitlab.com/to-be-continuous/hurl

💡 For Complete Testing Stack:
- Add E2E: Cypress, Playwright, or Puppeteer
- Add Load: k6 (load testing)
- Add Performance: Lighthouse
```

**✅ Pass Criteria:**
- Shows 3 API testing templates
- Suggests complementary testing types

---

**Test 2.5: Cloud Provider Search**

```bash
/discover aws deployment
```

**Expected Result:**
```
Found AWS deployment templates:

☁️ AWS:
1. Amazon Web Services - AWS deployment
   https://gitlab.com/to-be-continuous/aws

2. Terraform - Infrastructure as Code (supports AWS)
   https://gitlab.com/to-be-continuous/terraform

📚 Related Samples:
- golang-docker-on-aws (ECS deployment)
- python-serverless-on-aws (Lambda)
- cloudformation-on-aws (CloudFormation)
- terraform-ansible-on-aws (IaC + provisioning)

💡 AWS Deployment Options:
- ECS (containers)
- Lambda (serverless)
- CloudFormation (AWS IaC)
- Terraform + Ansible (multi-cloud IaC)
```

**✅ Pass Criteria:**
- Shows AWS and Terraform templates
- Lists 4 AWS-related samples
- Explains deployment options

---

### Phase 3: Natural Language Testing 💬

**Test 3.1: Natural Question**

Ask naturally (don't use /discover command):
```
What templates exist for Python and Docker?
```

**Expected Result:**
- Skill activates automatically
- Same quality response as `/discover python docker`

**✅ Pass Criteria:**
- Skill triggers without explicit command
- Response is complete and formatted

---

**Test 3.2: Different Phrasing**

```
I need a pipeline for testing APIs
```

**Expected Result:**
- Shows API testing templates (Postman, Bruno, Hurl)
- Suggests complementary tools

**✅ Pass Criteria:**
- Understands "need a pipeline" as template search
- Shows appropriate testing templates

---

**Test 3.3: Show Me Format**

```
Show me templates for deploying to Kubernetes
```

**Expected Result:**
- Shows Kubernetes, Helm, Helmfile templates
- Explains differences

**✅ Pass Criteria:**
- "Show me" phrasing triggers skill
- Deployment templates appear

---

### Phase 4: Edge Cases 🔬

**Test 4.1: Non-existent Template**

```bash
/discover rust machine-learning
```

**Expected Result:**
```
Found partial matches:

✅ Rust:
- Rust - Build template for Rust
  https://gitlab.com/to-be-continuous/rust

❌ No specific Machine Learning template found

💡 Suggestions:
1. Use Rust template as base
2. For ML, you might need:
   - Custom build steps
   - Python template (for ML tooling)
   - Docker (for ML dependencies)

🔧 Consider creating a new template:
The to-be-continuous ecosystem would benefit from an ML/AI template!
```

**✅ Pass Criteria:**
- Shows Rust template (partial match)
- Acknowledges ML not found
- Provides constructive suggestions
- Mentions template creation possibility

---

**Test 4.2: Security Query**

```bash
/discover security scanning
```

**Expected Result:**
- Shows multiple security templates:
  - SonarQube
  - Gitleaks
  - DefectDojo
  - Dependency-Track
  - Test SSL
- Recommends minimum security stack
- Categorizes by type (SAST, DAST, dependency, infrastructure)

**✅ Pass Criteria:**
- At least 5 security templates shown
- Categorized properly
- Minimum stack recommendation included

---

**Test 4.3: Complete Stack**

```bash
/discover go microservices kubernetes helm testing
```

**Expected Result:**
- Shows all components:
  - Go (build)
  - Docker/CNB (packaging)
  - Kubernetes + Helm (deployment)
  - Testing templates
- Suggests security additions
- Shows golang-cnb-helm-on-kubernetes sample
- Provides example YAML

**✅ Pass Criteria:**
- All requested templates shown
- Intelligent additions suggested
- Most relevant sample highlighted
- Quick start YAML snippet provided

---

### Phase 5: Output Quality 📊

**Test 5.1: URLs Are Valid**

For any search result, click on the URLs:
- Template URLs should go to `https://gitlab.com/to-be-continuous/[name]`
- Sample URLs should go to `https://gitlab.com/to-be-continuous/samples/[name]`

**✅ Pass Criteria:**
- All URLs are clickable
- All URLs lead to correct GitLab pages
- No 404 errors

---

**Test 5.2: Formatting Consistency**

Check multiple searches:
```bash
/discover python
/discover docker
/discover kubernetes
```

**✅ Pass Criteria:**
- Consistent emoji usage (📦, 💡, 📚)
- Consistent section headers
- Consistent URL formatting
- Consistent suggestion format

---

**Test 5.3: Description Accuracy**

Verify template descriptions match catalog:
- Check `/discover python` description vs `skills/template-discovery/references/catalog.md`
- Descriptions should match

**✅ Pass Criteria:**
- Descriptions are accurate
- No outdated information

---

### Phase 6: Skill Activation 🧠

**Test 6.1: Skill Triggers Automatically**

Without using `/discover`, ask:
```
Are there templates for Node.js with testing?
```

**Expected Result:**
- `template-discovery` skill activates
- Shows Node.js and testing templates

**✅ Pass Criteria:**
- Skill activates from natural question
- Response quality same as explicit command

---

**Test 6.2: Skill References Catalog**

After a search, ask:
```
Can you show me the complete catalog?
```

**Expected Result:**
- Skill references `references/catalog.md`
- May show section of catalog or point to file

**✅ Pass Criteria:**
- Skill knows about catalog.md
- Can reference it when asked

---

**Test 6.3: Skill Uses Categories**

Ask:
```
What templates are for deployment?
```

**Expected Result:**
- Uses `references/categories.md`
- Shows deployment category templates:
  - AWS, Azure, GCP
  - Kubernetes, Helm, Helmfile
  - Cloud Foundry, OpenShift
  - S3, Terraform, Ansible

**✅ Pass Criteria:**
- Shows deployment templates only
- Categorizes correctly

---

## 📈 Test Results Summary

Track your results here:

### Basic Functionality
- [ ] Plugin loads successfully
- [ ] /discover command appears in /help
- [ ] Single technology search works
- [ ] Multiple technology search works
- [ ] Ambiguous queries handled well

### Natural Language
- [ ] "What templates..." triggers skill
- [ ] "I need..." triggers skill
- [ ] "Show me..." triggers skill

### Output Quality
- [ ] URLs are valid and clickable
- [ ] Formatting is consistent
- [ ] Descriptions are accurate
- [ ] Suggestions are intelligent

### Edge Cases
- [ ] Partial matches handled
- [ ] Non-existent templates acknowledged
- [ ] Complex queries work

### Skill Behavior
- [ ] Activates automatically
- [ ] References catalog.md
- [ ] Uses categories.md
- [ ] Provides examples when relevant

---

## 🐛 Issue Reporting

If you find issues, document them here:

### Issue Template

**Test:** [Test number and name]
**Expected:** [What should happen]
**Actual:** [What actually happened]
**Error Message:** [If any]
**Steps to Reproduce:**
1. Step 1
2. Step 2
3. ...

---

## ✅ Success Criteria

Plugin is working correctly if:
- ✅ All Phase 1 tests pass (loading)
- ✅ At least 4/5 Phase 2 tests pass (basic commands)
- ✅ At least 2/3 Phase 3 tests pass (natural language)
- ✅ At least 2/4 Phase 4 tests pass (edge cases)
- ✅ All Phase 5 tests pass (output quality)
- ✅ At least 2/3 Phase 6 tests pass (skill activation)

**Overall Pass:** 15/23 tests minimum (65%)
**Excellent:** 20/23 tests (87%)
**Perfect:** 23/23 tests (100%)

---

## 🎯 Next Steps After Testing

**If tests pass:**
1. Start using the plugin in real work
2. Gather feedback on usefulness
3. Identify features for Phase 2 (local sync, pipeline creation)

**If tests fail:**
1. Document failures in Issue Reporting section
2. Identify patterns in failures
3. Fix issues and re-test
4. Iterate until tests pass

---

## 💡 Tips for Testing

- **Be thorough**: Run each test at least once
- **Test naturally**: Try variations of queries
- **Check URLs**: Click on links to verify they work
- **Note edge cases**: If you find a query that breaks, document it
- **Test incrementally**: Fix issues as you find them

---

**Ready to start testing?** Begin with Phase 1, Test 1.1!
