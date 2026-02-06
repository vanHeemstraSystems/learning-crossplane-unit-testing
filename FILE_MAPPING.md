# Complete File Mapping and Placement Guide

This document provides the complete mapping of all files you need to place in your repository.

## Quick Reference

**Total Files: 30**
- Documentation: 3 files
- Crossplane Resources: 6 files
- Test Scripts: 8 files
- Policy Files: 6 files
- Test Data: 3 files
- GitHub Actions: 2 files
- Schemas: 1 file
- Helper Docs: 1 file

## File Placement Map

### 📄 Root Level Files (3 files)

1. **README.md** 
   - Download: `README.md`
   - Place at: `README.md`
   - Purpose: Main documentation with Crossplane CLI focus

2. **DIRECTORY_STRUCTURE.md**
   - Download: `DIRECTORY_STRUCTURE.md`
   - Place at: `DIRECTORY_STRUCTURE.md`
   - Purpose: Directory structure guide

3. **QUICKSTART.md**
   - Download: `QUICKSTART.md`
   - Place at: `QUICKSTART.md`
   - Purpose: Quick start guide

### 🔧 Crossplane Resource Files (6 files)

Create directory: `apis/v1alpha1/subscriptions/`

4. **XRD Definition**
   - Download: `xrd.yml`
   - Place at: `apis/v1alpha1/subscriptions/xrd.yml`

5. **Composition**
   - Download: `composition.yml`
   - Place at: `apis/v1alpha1/subscriptions/composition.yml`

6. **Functions**
   - Download: `patch-and-transform.yml`
   - Place at: `apis/v1alpha1/subscriptions/functions/patch-and-transform.yml`

Create directory: `apis/v1alpha1/subscriptions/examples/`

7. **Dev XR Example**
   - Download: `xr-dev.yml`
   - Place at: `apis/v1alpha1/subscriptions/examples/xr-dev.yml`

8. **Staging XR Example**
   - Download: `xr-staging.yml`
   - Place at: `apis/v1alpha1/subscriptions/examples/xr-staging.yml`

9. **Production XR Example**
   - Download: `xr-prod.yml`
   - Place at: `apis/v1alpha1/subscriptions/examples/xr-prod.yml`

### 🧪 Test Scripts (8 files)

Create directory: `scripts/`

10. **Setup Script (Crossplane CLI focused)**
    - Download: `setup-test-env-v2.sh`
    - Place at: `scripts/setup-test-env-v2.sh`
    - Make executable: `chmod +x scripts/setup-test-env-v2.sh`

11. **Render Tests Runner**
    - Download: `run-render-tests.sh`
    - Place at: `scripts/run-render-tests.sh`
    - Make executable: `chmod +x scripts/run-render-tests.sh`

12. **Validation Tests Runner**
    - Download: `run-validate-tests.sh`
    - Place at: `scripts/run-validate-tests.sh`
    - Make executable: `chmod +x scripts/run-validate-tests.sh`

13. **All Tests Runner (Crossplane CLI focused)**
    - Download: `run-all-tests-v2.sh`
    - Place at: `scripts/run-all-tests-v2.sh`
    - Make executable: `chmod +x scripts/run-all-tests-v2.sh`

14. **Manifest Validator (Optional - for YAML syntax)**
    - Download: `validate-manifests.sh`
    - Place at: `scripts/validate-manifests.sh`
    - Make executable: `chmod +x scripts/validate-manifests.sh`

Create directory: `apis/v1alpha1/subscriptions/tests/unit/render/`

15. **Dev Render Test**
    - Download: `test-dev.sh`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/render/test-dev.sh`
    - Make executable: `chmod +x apis/v1alpha1/subscriptions/tests/unit/render/test-dev.sh`

16. **Staging Render Test** (create similar to dev)
    - Copy and modify `test-dev.sh`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/render/test-staging.sh`

17. **Production Render Test** (create similar to dev)
    - Copy and modify `test-dev.sh`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/render/test-prod.sh`

### 📋 Policy Files (6 files) - Optional

Create directory: `apis/v1alpha1/subscriptions/tests/unit/conftest/policy/`

18. **XRD Validation Policy**
    - Download: `xrd-validation.rego`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xrd-validation.rego`

19. **Composition Validation Policy**
    - Download: `composition-validation.rego`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/conftest/policy/composition-validation.rego`

20. **XR Validation Policy**
    - Download: `xr-validation.rego`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xr-validation.rego`

Create directory: `apis/v1alpha1/subscriptions/tests/unit/conftest/test/`

21. **XRD Validation Tests**
    - Download: `xrd-validation_test.rego`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/conftest/test/xrd-validation_test.rego`

22. **Composition Validation Tests**
    - Download: `composition-validation_test.rego`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/conftest/test/composition-validation_test.rego`

23. **XR Validation Tests**
    - Download: `xr-validation_test.rego`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/conftest/test/xr-validation_test.rego`

### 🎯 KUTTL Test Files (3 files) - Optional

Create directory: `apis/v1alpha1/subscriptions/tests/unit/kuttl/`

24. **KUTTL Config**
    - Download: `kuttl-test.yaml`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/kuttl/kuttl-test.yaml`

Create directory: `apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation/`

25. **KUTTL Test XR**
    - Download: `00-xr.yaml`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation/00-xr.yaml`

26. **KUTTL Test Assertion**
    - Download: `00-assert.yaml`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation/00-assert.yaml`

### 📐 Schema Files (1 file) - Optional

Create directory: `apis/v1alpha1/subscriptions/tests/unit/schemas/`

27. **JSON Schema**
    - Download: `subscription-schema.json`
    - Place at: `apis/v1alpha1/subscriptions/tests/unit/schemas/subscription-schema.json`

### ⚙️ GitHub Actions (2 files)

Create directory: `.github/workflows/`

28. **Crossplane CLI Tests Workflow**
    - Download: `crossplane-cli-tests.yml`
    - Place at: `.github/workflows/crossplane-cli-tests.yml`

29. **Legacy Unit Tests Workflow** (optional - includes KUTTL)
    - Download: `unit-tests.yml`
    - Place at: `.github/workflows/unit-tests.yml`

### 📚 Documentation (1 file) - Optional

Create directory: `docs/`

30. **Crossplane CLI Testing Guide**
    - Create your own or expand from README
    - Place at: `docs/crossplane-cli-testing.md`

## Directory Structure After Placement

```
learning-crossplane-unit-testing/
├── README.md                                  # File 1
├── DIRECTORY_STRUCTURE.md                     # File 2
├── QUICKSTART.md                              # File 3
│
├── .github/
│   └── workflows/
│       ├── crossplane-cli-tests.yml          # File 28 (RECOMMENDED)
│       └── unit-tests.yml                     # File 29 (optional)
│
├── apis/
│   └── v1alpha1/
│       └── subscriptions/
│           ├── xrd.yml                        # File 4
│           ├── composition.yml                # File 5
│           ├── functions/                     # File 6
│           │   └── patch-and-transform.yml
│           │
│           ├── examples/
│           │   ├── xr-dev.yml                # File 7
│           │   ├── xr-staging.yml            # File 8
│           │   └── xr-prod.yml               # File 9
│           │
│           └── tests/
│               └── unit/
│                   ├── render/                # CROSSPLANE CLI TESTS (RECOMMENDED)
│                   │   ├── test-dev.sh        # File 15
│                   │   ├── test-staging.sh    # File 16
│                   │   └── test-prod.sh       # File 17
│                   │
│                   ├── conftest/              # POLICY TESTS (optional)
│                   │   ├── policy/
│                   │   │   ├── xrd-validation.rego           # File 18
│                   │   │   ├── composition-validation.rego   # File 19
│                   │   │   └── xr-validation.rego            # File 20
│                   │   └── test/
│                   │       ├── xrd-validation_test.rego      # File 21
│                   │       ├── composition-validation_test.rego # File 22
│                   │       └── xr-validation_test.rego       # File 23
│                   │
│                   ├── kuttl/                 # KUTTL TESTS (optional)
│                   │   ├── kuttl-test.yaml   # File 24
│                   │   └── 00-subscription-creation/
│                   │       ├── 00-xr.yaml    # File 25
│                   │       └── 00-assert.yaml # File 26
│                   │
│                   └── schemas/               # JSON SCHEMA (optional)
│                       └── subscription-schema.json  # File 27
│
├── scripts/                                   # TEST SCRIPTS (RECOMMENDED)
│   ├── setup-test-env-v2.sh                  # File 10
│   ├── run-render-tests.sh                   # File 11
│   ├── run-validate-tests.sh                 # File 12
│   ├── run-all-tests-v2.sh                   # File 13
│   └── validate-manifests.sh                 # File 14 (optional)
│
└── docs/                                      # DOCUMENTATION (optional)
    └── crossplane-cli-testing.md             # File 30
```

## Installation Commands

Run these commands from your repository root:

```bash
# Create all necessary directories
mkdir -p .github/workflows
mkdir -p apis/v1alpha1/subscriptions/examples
mkdir -p apis/v1alpha1/subscriptions/tests/unit/render
mkdir -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy
mkdir -p apis/v1alpha1/subscriptions/tests/unit/conftest/test
mkdir -p apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation
mkdir -p apis/v1alpha1/subscriptions/tests/unit/schemas
mkdir -p scripts
mkdir -p docs

# Make scripts executable (after placing them)
chmod +x scripts/*.sh
chmod +x apis/v1alpha1/subscriptions/tests/unit/render/*.sh
```

## Priority Levels

### 🔴 CRITICAL (Minimum Viable Setup)

These are the absolute minimum files needed for Crossplane CLI testing:

1. README.md (File 1)
2. xrd.yml (File 4)
3. composition.yml (File 5)
4. patch-and-transform.yml (File 6)
5. xr-dev.yml (File 7)
6. setup-test-env-v2.sh (File 10)
7. run-render-tests.sh (File 11)
8. run-validate-tests.sh (File 12)
9. crossplane-cli-tests.yml (File 28)

**Total: 9 files** - Gets you basic Crossplane CLI testing

### 🟡 RECOMMENDED (Complete Testing Setup)

Add these for a complete testing experience:

10. xr-staging.yml (File 8)
11. xr-prod.yml (File 9)
12. run-all-tests-v2.sh (File 13)
13. QUICKSTART.md (File 3)
14. DIRECTORY_STRUCTURE.md (File 2)

**Total: 14 files** - Complete Crossplane CLI testing with docs

### 🟢 OPTIONAL (Enhanced Features)

Add these for advanced features:

- Policy tests (Files 18-23) - 6 files
- KUTTL tests (Files 24-26) - 3 files
- JSON Schema (File 27) - 1 file
- Individual render tests (Files 15-17) - 3 files
- Additional docs (File 30) - 1 file

**Total: 30 files** - Complete suite with all bells and whistles

## Verification Checklist

After placing all files, verify:

```bash
# 1. Check directory structure
tree -L 5 apis/
tree -L 2 scripts/
tree -L 2 .github/

# 2. Verify scripts are executable
ls -la scripts/
ls -la apis/v1alpha1/subscriptions/tests/unit/render/

# 3. Test basic render
crossplane render \
  apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions/patch-and-transform.yml

# 4. Run test suite
./scripts/run-all-tests-v2.sh
```

## Common Issues and Solutions

### Issue: "Permission denied" when running scripts

**Solution:**
```bash
chmod +x scripts/*.sh
chmod +x apis/v1alpha1/subscriptions/tests/unit/render/*.sh
```

### Issue: "crossplane: command not found"

**Solution:**
```bash
./scripts/setup-test-env-v2.sh
# or manually:
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
sudo mv crossplane /usr/local/bin/
```

### Issue: Functions not rendering

**Solution:**
Ensure `functions/patch-and-transform.yml` has the Development runtime annotation:
```yaml
metadata:
  annotations:
    render.crossplane.io/runtime: Development
```

## Git Commit Strategy

```bash
# Stage files in logical groups
git add README.md QUICKSTART.md DIRECTORY_STRUCTURE.md
git commit -m "docs: add documentation"

git add apis/v1alpha1/subscriptions/*.yml
git commit -m "feat: add XRD, Composition, and Functions"

git add apis/v1alpha1/subscriptions/examples/*.yml
git commit -m "feat: add XR examples for dev, staging, prod"

git add scripts/*.sh
git commit -m "feat: add Crossplane CLI test scripts"

git add .github/workflows/*.yml
git commit -m "ci: add GitHub Actions workflows"

git add apis/v1alpha1/subscriptions/tests/
git commit -m "test: add unit tests (render, policy, kuttl)"

git push origin main
```

---

**Need Help?**

If you're missing any files or have questions about placement, let me know!

🔍 Code Smell Detective - Willem van Heemstra
