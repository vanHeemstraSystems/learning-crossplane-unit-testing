# 🎯 Complete Download & Setup Guide

**Repository**: learning-crossplane-unit-testing  
**Author**: Willem van Heemstra  
**Focus**: Crossplane v2 Unit Testing with CLI Tools

---

## 📦 What You Have

**Total downloadable files: 34**

All files are ready to download from the links provided above. This guide will help you:

1. Download all files
2. Place them correctly
3. Set up your testing environment
4. Run your first tests

---

## 🚀 Quick Start (Minimum Setup)

For a working setup in **under 5 minutes**, you need just **9 critical files**:

### Step 1: Download Critical Files

1. **README.md** → `README.md`
2. **xrd.yml** → `apis/v1alpha1/subscriptions/xrd.yml`
3. **composition.yml** → `apis/v1alpha1/subscriptions/composition.yml`
4. **patch-and-transform.yml** → `apis/v1alpha1/subscriptions/functions/patch-and-transform.yml`
5. **xr-dev.yml** → `apis/v1alpha1/subscriptions/examples/xr-dev.yml`
6. **setup-test-env-v2.sh** → `scripts/setup-test-env-v2.sh`
7. **run-render-tests.sh** → `scripts/run-render-tests.sh`
8. **run-validate-tests.sh** → `scripts/run-validate-tests.sh`
9. **crossplane-cli-tests.yml** → `.github/workflows/crossplane-cli-tests.yml`

### Step 2: Create Directory Structure

```bash
cd learning-crossplane-unit-testing

# Create directories
mkdir -p apis/v1alpha1/subscriptions/examples
mkdir -p scripts
mkdir -p .github/workflows

# Place the files (download and copy them to the locations above)
```

### Step 3: Make Scripts Executable

```bash
chmod +x scripts/setup-test-env-v2.sh
chmod +x scripts/run-render-tests.sh
chmod +x scripts/run-validate-tests.sh
```

### Step 4: Install Crossplane CLI

```bash
./scripts/setup-test-env-v2.sh
```

### Step 5: Run Your First Test

```bash
# Test render
./scripts/run-render-tests.sh

# Test validation
./scripts/run-validate-tests.sh
```

**✅ You're done! You now have a working Crossplane unit testing setup.**

---

## 📚 Complete Setup (Recommended)

For the **full experience with all features**, download all **34 files**:

### Core Files (14 files)

**Documentation:**
- README.md → README.md
- QUICKSTART.md → QUICKSTART.md
- DIRECTORY_STRUCTURE.md → DIRECTORY_STRUCTURE.md
- FILE_MAPPING.md → FILE_MAPPING.md

**Crossplane Resources:**
- xrd.yml → apis/v1alpha1/subscriptions/xrd.yml
- composition.yml → apis/v1alpha1/subscriptions/composition.yml
- patch-and-transform.yml → apis/v1alpha1/subscriptions/functions/patch-and-transform.yml
- xr-dev.yml → apis/v1alpha1/subscriptions/examples/xr-dev.yml
- xr-staging.yml → apis/v1alpha1/subscriptions/examples/xr-staging.yml
- xr-prod.yml → apis/v1alpha1/subscriptions/examples/xr-prod.yml

**Primary Test Scripts:**
- setup-test-env-v2.sh → scripts/setup-test-env-v2.sh
- run-render-tests.sh → scripts/run-render-tests.sh
- run-validate-tests.sh → scripts/run-validate-tests.sh
- run-all-tests-v2.sh → scripts/run-all-tests-v2.sh

### Enhanced Features (20 files)

**Individual Render Tests:**
- test-dev.sh → apis/v1alpha1/subscriptions/tests/unit/render/test-dev.sh
- test-staging.sh → apis/v1alpha1/subscriptions/tests/unit/render/test-staging.sh
- test-prod.sh → apis/v1alpha1/subscriptions/tests/unit/render/test-prod.sh

**Policy Files (Conftest):**
- xrd-validation.rego → apis/v1alpha1/subscriptions/tests/unit/conftest/policy/
- composition-validation.rego → apis/v1alpha1/subscriptions/tests/unit/conftest/policy/
- xr-validation.rego → apis/v1alpha1/subscriptions/tests/unit/conftest/policy/
- xrd-validation_test.rego → apis/v1alpha1/subscriptions/tests/unit/conftest/test/
- composition-validation_test.rego → apis/v1alpha1/subscriptions/tests/unit/conftest/test/
- xr-validation_test.rego → apis/v1alpha1/subscriptions/tests/unit/conftest/test/

**KUTTL Tests:**
- kuttl-test.yaml → apis/v1alpha1/subscriptions/tests/unit/kuttl/
- 00-xr.yaml → apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation/
- 00-assert.yaml → apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation/

**Schemas:**
- subscription-schema.json → apis/v1alpha1/subscriptions/tests/unit/schemas/

**Additional Scripts:**
- validate-manifests.sh → scripts/validate-manifests.sh
- run-all-tests.sh (original) → scripts/run-all-tests-legacy.sh

**GitHub Actions:**
- crossplane-cli-tests.yml → .github/workflows/crossplane-cli-tests.yml
- unit-tests.yml → .github/workflows/unit-tests-legacy.yml

---

## 🗂️ File Organization by Purpose

### Testing Approach 1: Crossplane CLI (RECOMMENDED)

**What you need:**
```
✅ xrd.yml, composition.yml, functions/patch-and-transform.yml
✅ xr-dev.yml, xr-staging.yml, xr-prod.yml
✅ run-render-tests.sh
✅ run-validate-tests.sh
✅ crossplane-cli-tests.yml (GitHub Actions)
```

**Why**: Fast, no cluster needed, official tooling

### Testing Approach 2: Policy Testing (OPTIONAL)

**What you need:**
```
✅ All .rego files
✅ conftest installed
```

**Why**: Enforce organizational standards

### Testing Approach 3: KUTTL Integration Tests (OPTIONAL)

**What you need:**
```
✅ kuttl-test.yaml
✅ 00-xr.yaml, 00-assert.yaml
✅ Kubernetes cluster
```

**Why**: Test with real Kubernetes

---

## 📋 Complete Directory Structure After Setup

```
learning-crossplane-unit-testing/
├── README.md
├── QUICKSTART.md                      ← QUICKSTART.md
├── DIRECTORY_STRUCTURE.md             ← DIRECTORY_STRUCTURE.md
├── FILE_MAPPING.md                    ← FILE_MAPPING.md
│
├── .github/
│   └── workflows/
│       ├── crossplane-cli-tests.yml   ← crossplane-cli-tests.yml
│       └── unit-tests-legacy.yml      ← unit-tests.yml (optional)
│
├── apis/
│   └── v1alpha1/
│       └── subscriptions/
│           ├── xrd.yml
│           ├── composition.yml
│           ├── functions/
│           │   └── patch-and-transform.yml
│           ├── examples/
│           │   ├── xr-dev.yml
│           │   ├── xr-staging.yml
│           │   └── xr-prod.yml
│           └── tests/
│               └── unit/
│                   ├── render/
│                   │   ├── test-dev.sh
│                   │   ├── test-staging.sh
│                   │   └── test-prod.sh
│                   ├── conftest/
│                   │   ├── policy/
│                   │   │   ├── xrd-validation.rego
│                   │   │   ├── composition-validation.rego
│                   │   │   └── xr-validation.rego
│                   │   └── test/
│                   │       ├── xrd-validation_test.rego
│                   │       ├── composition-validation_test.rego
│                   │       └── xr-validation_test.rego
│                   ├── kuttl/
│                   │   ├── kuttl-test.yaml
│                   │   └── 00-subscription-creation/
│                   │       ├── 00-xr.yaml
│                   │       └── 00-assert.yaml
│                   └── schemas/
│                       └── subscription-schema.json
│
└── scripts/
    ├── setup-test-env-v2.sh
    ├── run-render-tests.sh
    ├── run-validate-tests.sh
    ├── run-all-tests-v2.sh
    └── validate-manifests.sh
```

---

## 🎬 Setup Commands (Copy & Paste)

```bash
# Navigate to your repository
cd learning-crossplane-unit-testing

# Create all directories
mkdir -p .github/workflows
mkdir -p apis/v1alpha1/subscriptions/examples
mkdir -p apis/v1alpha1/subscriptions/tests/unit/render
mkdir -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy
mkdir -p apis/v1alpha1/subscriptions/tests/unit/conftest/test
mkdir -p apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation
mkdir -p apis/v1alpha1/subscriptions/tests/unit/schemas
mkdir -p scripts

# After downloading and placing files, make scripts executable
chmod +x scripts/*.sh
chmod +x apis/v1alpha1/subscriptions/tests/unit/render/*.sh

# Install tools
./scripts/setup-test-env-v2.sh

# Run tests
./scripts/run-all-tests-v2.sh
```

---

## ✅ Verification Steps

### 1. Check Directory Structure

```bash
tree -L 4 apis/
tree -L 2 scripts/
```

### 2. Verify Crossplane CLI

```bash
crossplane --version
# Should show a version that includes:
#   - `crossplane render`
#   - `crossplane beta validate`
```

### 3. Test Basic Render

```bash
crossplane render \
  apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions/patch-and-transform.yml
```

**Expected output**: Should show XR + Subscription + ResourceGroup

### 4. Run Complete Test Suite

```bash
./scripts/run-all-tests-v2.sh
```

**Expected output**:
```
✅ Crossplane Render Tests PASSED
✅ Crossplane Validation Tests PASSED
✅ All required tests passed!
```

---

## 🐛 Troubleshooting

### Issue: "Permission denied" when running scripts

**Solution:**
```bash
chmod +x scripts/*.sh
chmod +x apis/v1alpha1/subscriptions/tests/unit/render/*.sh
```

### Issue: "crossplane: command not found"

**Solution:**
```bash
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
sudo mv crossplane /usr/local/bin/
```

### Issue: Render fails with "no functions specified"

**Solution:**
Ensure you're passing the function definition file:
```bash
crossplane render xr.yml composition.yml functions/patch-and-transform.yml
#                                        ^^^^^^^^^^^^^^ don't forget this!
```

### Issue: Functions don't run locally

**Solution:**
Add Development runtime to `functions/patch-and-transform.yml`:
```yaml
metadata:
  annotations:
    render.crossplane.io/runtime: Development
```

---

## 🎯 Testing Workflow

```
1. Make changes to Composition
   ↓
2. Run: ./scripts/run-render-tests.sh
   ↓
3. Run: ./scripts/run-validate-tests.sh
   ↓
4. Fix any issues
   ↓
5. Commit and push
   ↓
6. GitHub Actions runs automatically
   ↓
7. Deploy to cluster (if tests pass)
```

---

## 📊 What Each Test Does

### Render Tests (`run-render-tests.sh`)
- ✅ Verifies Composition renders without errors
- ✅ Checks all expected resources are created
- ✅ Validates patches are applied correctly
- ⚡ Runs in seconds
- 🚫 No Kubernetes cluster needed

### Validation Tests (`run-validate-tests.sh`)
- ✅ Validates against XRD schema
- ✅ Ensures type correctness
- ✅ Checks required fields
- ⚡ Runs in seconds
- 🚫 No Kubernetes cluster needed

### Policy Tests (Optional - Conftest)
- ✅ Enforces naming conventions
- ✅ Validates required tags
- ✅ Checks security policies
- ⚡ Runs in seconds
- 🚫 No Kubernetes cluster needed

### KUTTL Tests (Optional)
- ✅ Tests actual resource creation
- ✅ Validates Kubernetes behavior
- 🐢 Slower (minutes)
- ✅ Requires Kubernetes cluster

---

## 🎓 Learning Path

1. **Day 1**: Set up minimum viable testing (9 files)
2. **Day 2**: Add all environments (staging, prod)
3. **Day 3**: Add policy tests
4. **Week 2**: Add KUTTL integration tests (optional)
5. **Week 3**: Customize for your use cases

---

## 📚 Additional Resources

- [Crossplane CLI Documentation](https://docs.crossplane.io/latest/cli/command-reference/)
- [Composition Functions Guide](https://docs.crossplane.io/latest/concepts/composition-functions/)
- [Testing Crossplane Blog](https://blog.upbound.io/composition-testing-patterns-rendering)
- [KUTTL Documentation](https://kuttl.dev/)
- [Conftest Documentation](https://www.conftest.dev/)

---

## 🎉 You're Ready!

With all files downloaded and placed correctly, you have:

✅ Professional Crossplane unit testing setup  
✅ Fast feedback loop (seconds, not minutes)  
✅ No Kubernetes cluster required for unit tests  
✅ CI/CD integration ready  
✅ Best practices from the Crossplane community  

**Next Steps:**
1. Run `./scripts/run-all-tests-v2.sh`
2. Customize for your Azure resources
3. Add more XRDs and Compositions
4. Share with your team!

---

**Code Smell Detective** 🔍  
*Willem van Heemstra - Cloud Engineer @ Team Rockstars Cloud*

*Happy Testing!* 🧪
