# Directory Structure Guide

This document explains the complete directory structure for the learning-crossplane-unit-testing repository.

## Complete Directory Tree

```
learning-crossplane-unit-testing/
├── README.md
├── .github/
│   └── workflows/
│       ├── crossplane-cli-tests.yml     ← RECOMMENDED (Crossplane CLI focused)
│       └── unit-tests.yml               ← OPTIONAL (includes KUTTL, requires cluster)
├── apis/
│   └── v1alpha1/
│       └── subscriptions/
│           ├── xrd.yml
│           ├── composition.yml
│           ├── examples/
│           │   ├── xr-dev.yml
│           │   ├── xr-staging.yml
│           │   └── xr-prod.yml
│           └── tests/
│               └── unit/
│                   ├── kuttl/
│                   │   ├── kuttl-test.yaml
│                   │   └── 00-subscription-creation/
│                   │       ├── 00-assert.yaml
│                   │       └── 00-xr.yaml
│                   ├── conftest/
│                   │   ├── policy/
│                   │   │   ├── xrd-validation.rego
│                   │   │   ├── composition-validation.rego
│                   │   │   └── xr-validation.rego
│                   │   └── test/
│                   │       ├── xrd-validation_test.rego
│                   │       ├── composition-validation_test.rego
│                   │       └── xr-validation_test.rego
│                   └── schemas/
│                       └── subscription-schema.json
├── docs/
│   ├── testing-strategy.md
│   ├── azure-subscription-use-case.md
│   ├── crossplane-v2-differences.md
│   └── ci-cd-integration.md
└── scripts/
    ├── setup-test-env-v2.sh
    ├── run-render-tests.sh
    ├── run-validate-tests.sh
    ├── run-all-tests-v2.sh
    └── validate-manifests.sh
```

## File Placement Instructions

### Step 1: Root Level Files

1. Place `README.md` in the repository root
2. Create `.github/workflows/` directory and place `crossplane-cli-tests.yml` there (recommended)

### Step 2: Crossplane Resources

Create the following directory structure and place files:

```bash
mkdir -p apis/v1alpha1/subscriptions/examples
```

Place these files:
- `xrd.yml` → `apis/v1alpha1/subscriptions/xrd.yml`
- `composition.yml` → `apis/v1alpha1/subscriptions/composition.yml`
- `xr-dev.yml` → `apis/v1alpha1/subscriptions/examples/xr-dev.yml`
- `xr-staging.yml` → `apis/v1alpha1/subscriptions/examples/xr-staging.yml`
- `xr-prod.yml` → `apis/v1alpha1/subscriptions/examples/xr-prod.yml`

### Step 3: KUTTL Tests

Create the directory structure:

```bash
mkdir -p apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation
```

Place these files:
- `kuttl-test.yaml` → `apis/v1alpha1/subscriptions/tests/unit/kuttl/kuttl-test.yaml`
- `00-xr.yaml` → `apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation/00-xr.yaml`
- `00-assert.yaml` → `apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation/00-assert.yaml`

### Step 4: Conftest Policies

Create the directory structure:

```bash
mkdir -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy
mkdir -p apis/v1alpha1/subscriptions/tests/unit/conftest/test
```

Place these files:

**Policy files:**
- `xrd-validation.rego` → `apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xrd-validation.rego`
- `composition-validation.rego` → `apis/v1alpha1/subscriptions/tests/unit/conftest/policy/composition-validation.rego`
- `xr-validation.rego` → `apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xr-validation.rego`

**Test files:**
- `xrd-validation_test.rego` → `apis/v1alpha1/subscriptions/tests/unit/conftest/test/xrd-validation_test.rego`
- `composition-validation_test.rego` → `apis/v1alpha1/subscriptions/tests/unit/conftest/test/composition-validation_test.rego`
- `xr-validation_test.rego` → `apis/v1alpha1/subscriptions/tests/unit/conftest/test/xr-validation_test.rego`

### Step 5: JSON Schema

Create the directory structure:

```bash
mkdir -p apis/v1alpha1/subscriptions/tests/unit/schemas
```

Place this file:
- `subscription-schema.json` → `apis/v1alpha1/subscriptions/tests/unit/schemas/subscription-schema.json`

### Step 6: Scripts

Create the directory structure:

```bash
mkdir -p scripts
```

Place these files and make them executable:
- `setup-test-env-v2.sh` → `scripts/setup-test-env-v2.sh`
- `run-render-tests.sh` → `scripts/run-render-tests.sh`
- `run-validate-tests.sh` → `scripts/run-validate-tests.sh`
- `run-all-tests-v2.sh` → `scripts/run-all-tests-v2.sh`
- `validate-manifests.sh` → `scripts/validate-manifests.sh`

### Crossplane v2 note (XRD apiVersion)

XRDs in this repository use `apiVersion: apiextensions.crossplane.io/v2` and set `spec.scope` (recommended default is `Namespaced` in v2).

See: https://docs.crossplane.io/latest/composition/composite-resource-definitions/

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Step 7: Documentation (Optional - Create Later)

Create the directory structure:

```bash
mkdir -p docs
```

These can be created as you expand the repository:
- `docs/testing-strategy.md`
- `docs/azure-subscription-use-case.md`
- `docs/crossplane-v2-differences.md`
- `docs/ci-cd-integration.md`

## Quick Setup Commands

Run these commands from your repository root:

```bash
# Create all directories
mkdir -p apis/v1alpha1/subscriptions/examples
mkdir -p apis/v1alpha1/subscriptions/tests/unit/kuttl/00-subscription-creation
mkdir -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy
mkdir -p apis/v1alpha1/subscriptions/tests/unit/conftest/test
mkdir -p apis/v1alpha1/subscriptions/tests/unit/schemas
mkdir -p scripts
mkdir -p docs
mkdir -p .github/workflows

# Make scripts executable (after placing them)
chmod +x scripts/*.sh
```

## Verification

After placing all files, verify the structure:

```bash
# Check directory structure
tree -L 5

# Or use ls
ls -R apis/
ls -R scripts/
ls -R .github/
```

## Git Add Commands

Once all files are in place:

```bash
git add README.md
git add .github/
git add apis/
git add scripts/
git add docs/  # if created
git commit -m "feat: add Crossplane unit testing framework with Azure Subscription use case"
git push origin main
```

## File Count Summary

- **Root**: 1 file (README.md)
- **GitHub Actions**: 1 file
- **Crossplane Resources**: 5 files (1 XRD, 1 Composition, 3 XR examples)
- **KUTTL Tests**: 3 files
- **Conftest Policies**: 6 files (3 policies, 3 test files)
- **JSON Schema**: 1 file
- **Scripts**: 3 files
- **Total**: 20 files

---

**Note**: This structure follows Crossplane v2 conventions with direct XR usage (no Claims) and Pipeline mode for Compositions.
