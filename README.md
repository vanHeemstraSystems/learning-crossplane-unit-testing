# Learning Crossplane Unit Testing

A comprehensive learning repository for unit testing Crossplane v2 compositions, XRDs (CompositeResourceDefinitions), and XRs (Composite Resources) using the Crossplane CLI.

## Overview

This repository demonstrates best practices for unit testing Crossplane v2 resources using the official Crossplane CLI tools (`crossplane render` and `crossplane beta validate`), complemented by policy-based testing with Conftest/OPA. We use Crossplane v2’s architecture which works directly with XRs (Composite Resources) instead of Claims, providing a more streamlined approach to infrastructure composition.

## What You’ll Learn

- **Crossplane CLI Testing**: Using `crossplane render` and `crossplane beta validate`
- Unit testing strategies for Crossplane XRDs, Compositions, and XRs
- Policy-based validation with Conftest/OPA
- Azure-specific resource testing (Subscriptions, Resource Groups, etc.)
- Test automation and CI/CD integration
- Common pitfalls and how to avoid them

## Prerequisites

- **Crossplane CLI** (must include `crossplane render` and `crossplane beta validate`)
- `kubectl` CLI tool
- Docker (for running composition functions)
- Testing tools:
  - [conftest](https://www.conftest.dev/) - Policy testing (optional)
  - [yq](https://github.com/mikefarah/yq) - YAML processor (optional)

## Crossplane v2 and XRD apiVersion (important clarification)

Crossplane v2 XRDs use the Kubernetes apiVersion:

```yaml
apiVersion: apiextensions.crossplane.io/v2
kind: CompositeResourceDefinition
```

This repository follows the Crossplane v2 docs and sets `spec.scope` on the XRD (recommended default is `Namespaced`).

For details, see the official docs: [Composite Resource Definitions](https://docs.crossplane.io/latest/composition/composite-resource-definitions/).

## Directory Structure

```
learning-crossplane-unit-testing/
├── README.md
├── apis/
│   └── v1alpha1/
│       └── subscriptions/
│           ├── xrd.yml                    # XRD definition
│           ├── composition.yml            # Composition template
│           ├── functions.yml              # Function definitions
│           ├── examples/
│           │   ├── xr-dev.yml            # Development XR example
│           │   ├── xr-staging.yml        # Staging XR example
│           │   └── xr-prod.yml           # Production XR example
│           └── tests/
│               └── unit/
│                   ├── render/           # Crossplane render tests
│                   │   ├── test-dev.sh
│                   │   ├── test-staging.sh
│                   │   └── test-prod.sh
│                   ├── conftest/         # Policy tests
│                   │   ├── policy/
│                   │   │   ├── xrd-validation.rego
│                   │   │   ├── composition-validation.rego
│                   │   │   └── xr-validation.rego
│                   │   └── test/
│                   │       └── ...
│                   └── schemas/
│                       └── subscription-schema.json
├── docs/
│   ├── testing-strategy.md
│   ├── crossplane-cli-testing.md
│   └── ci-cd-integration.md
└── scripts/
    ├── setup-test-env-v2.sh
    ├── run-render-tests.sh
    ├── run-validate-tests.sh
    └── run-all-tests-v2.sh
```

## Testing Approach

### Primary: Crossplane CLI Testing

The **recommended approach** uses the official Crossplane CLI:

1. **`crossplane render`** - Renders your Composition locally to verify output
1. **`crossplane beta validate`** - Validates rendered resources against provider schemas

This is faster, more reliable, and doesn’t require a Kubernetes cluster.

### Secondary: Policy Testing

Use Conftest/OPA for governance and organizational standards:

- Naming conventions
- Required tags
- Security policies
- Compliance rules

## Use Case: Azure Subscription Management

[Previous use case section remains the same through the XRD, Composition, and XR examples…]

## Unit Testing with Crossplane CLI

### 1. Functions Definition

Create `functions.yml` to define the composition functions:

```yaml
---
apiVersion: pkg.crossplane.io/v1beta1
kind: Function
metadata:
  name: function-patch-and-transform
  annotations:
    render.crossplane.io/runtime: Development
spec:
  package: xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.5.0
```

### 2. Render Test (Basic)

Test that your Composition renders correctly:

```bash
# Basic render test
crossplane render \
  apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions.yml

# Expected output: XR + rendered managed resources
```

### 3. Validate Against Provider Schemas

```bash
# First render, then validate
crossplane render \
  apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions.yml \
  --include-full-xr | \
crossplane beta validate \
  apis/v1alpha1/subscriptions/xrd.yml \
  https://marketplace.upbound.io/providers/upbound/provider-azure-subscription/v1.3.1/crds.yaml \
  -
```

### 4. Test with Observed Resources

Simulate existing infrastructure:

```bash
# Create observed resources directory
mkdir -p apis/v1alpha1/subscriptions/tests/unit/observed

# Render with observed state
crossplane render \
  apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions.yml \
  --observed-resources=apis/v1alpha1/subscriptions/tests/unit/observed
```

### 5. Automated Test Scripts

**Test Script Example** (`tests/unit/render/test-dev.sh`):

```bash
#!/bin/bash
set -e

echo "🧪 Testing dev environment XR..."

# Render the composition
OUTPUT=$(crossplane render \
  apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions.yml 2>&1)

# Check for expected resources
echo "$OUTPUT" | grep -q "kind: Subscription" || {
  echo "❌ Failed: Subscription resource not found"
  exit 1
}

echo "$OUTPUT" | grep -q "kind: ResourceGroup" || {
  echo "❌ Failed: ResourceGroup resource not found"
  exit 1
}

# Verify subscription name
echo "$OUTPUT" | grep -q "subscriptionName: atlas-dev" || {
  echo "❌ Failed: Incorrect subscription name"
  exit 1
}

# Verify region
echo "$OUTPUT" | grep -q "region: westeurope" || {
  echo "❌ Failed: Incorrect region"
  exit 1
}

echo "✅ Dev environment test passed!"
```

### 6. Comprehensive Validation

**Validation Script** (`scripts/run-validate-tests.sh`):

```bash
#!/bin/bash
set -e

echo "🔍 Running Crossplane validation tests..."

# Test each environment
for env in dev staging prod; do
  echo ""
  echo "Testing $env environment..."
  
  # Render and validate
  crossplane render \
    apis/v1alpha1/subscriptions/examples/xr-$env.yml \
    apis/v1alpha1/subscriptions/composition.yml \
    apis/v1alpha1/subscriptions/functions.yml \
    --include-full-xr | \
  crossplane beta validate \
    apis/v1alpha1/subscriptions/xrd.yml \
    - && echo "✅ $env validated successfully" || echo "❌ $env validation failed"
done

echo ""
echo "✅ All validations complete!"
```

## Testing Strategy Comparison

|Testing Method            |Speed      |Requires Cluster|Schema Validation    |Real Providers|
|--------------------------|-----------|----------------|---------------------|--------------|
|`crossplane render`       |⚡ Very Fast|❌ No            |✅ Yes (with validate)|❌ No          |
|`crossplane beta validate`|⚡ Very Fast|❌ No            |✅ Yes                |❌ No          |
|Conftest/OPA              |⚡ Very Fast|❌ No            |⚠️ Custom             |❌ No          |
|KUTTL                     |🐢 Slow     |✅ Yes           |✅ Yes                |⚠️ Optional    |

**Recommendation**: Start with `crossplane render` + `crossplane beta validate` for unit tests, add Conftest for policy enforcement, and use KUTTL only for integration testing.

## Running Tests

### Setup Test Environment

```bash
# Install Crossplane CLI
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh

# Move to PATH
sudo mv crossplane /usr/local/bin/

# Verify installation
crossplane --version
```

### Run Render Tests

```bash
# Single environment
crossplane render \
  apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions.yml

# All environments (automated)
./scripts/run-render-tests.sh
```

### Run Validation Tests

```bash
# Validate single XR
crossplane render \
  apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions.yml \
  --include-full-xr | \
crossplane beta validate apis/v1alpha1/subscriptions/xrd.yml -

# All environments (automated)
./scripts/run-validate-tests.sh
```

### Run Complete Test Suite

```bash
# Runs: render tests + validation + policy tests
./scripts/run-all-tests-v2.sh
```

### Example Output

```
🧪 Testing Crossplane Compositions
====================================

📋 Render Tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ dev environment rendered successfully
✅ staging environment rendered successfully
✅ prod environment rendered successfully

🔍 Validation Tests
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[✓] XAzureSubscription/atlas-dev-subscription validated
[✓] Subscription/atlas-dev-subscription-subscription validated
[✓] ResourceGroup/rg-atlas-dev-weu validated

📊 Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ All tests passed!
```

## Best Practices

### 1. Test Pyramid for Crossplane

```
        /\
       /  \    E2E Tests (few) - KUTTL with real cloud
      /----\
     /      \  Integration Tests (some) - KUTTL with mock providers
    /--------\
   /          \ Unit Tests (many) - crossplane render + validate
  /____________\
```

### 2. What to Test at Each Level

**Unit Tests (crossplane render + validate):**

- ✅ Composition renders correctly
- ✅ All expected managed resources are created
- ✅ Patches are applied correctly
- ✅ Resources match provider schemas
- ✅ Fast feedback loop (seconds)

**Policy Tests (Conftest):**

- ✅ Naming conventions
- ✅ Required tags present
- ✅ Security requirements
- ✅ Organizational standards

**Integration Tests (KUTTL - optional):**

- ✅ Resources are actually created
- ✅ Dependencies work correctly
- ✅ Status updates propagate
- ⚠️ Slower (minutes)

### 3. CI/CD Integration

Use `crossplane render` and `crossplane beta validate` in your pipeline:

```yaml
# .github/workflows/unit-tests.yml
name: Unit Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Crossplane CLI
        run: |
          curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
          sudo mv crossplane /usr/local/bin/
      
      - name: Render Compositions
        run: |
          for env in dev staging prod; do
            echo "Testing $env..."
            crossplane render \
              apis/v1alpha1/subscriptions/examples/xr-$env.yml \
              apis/v1alpha1/subscriptions/composition.yml \
              apis/v1alpha1/subscriptions/functions.yml
          done
      
      - name: Validate Against Schemas
        run: |
          crossplane render \
            apis/v1alpha1/subscriptions/examples/xr-dev.yml \
            apis/v1alpha1/subscriptions/composition.yml \
            apis/v1alpha1/subscriptions/functions.yml \
            --include-full-xr | \
          crossplane beta validate apis/v1alpha1/subscriptions/xrd.yml -
```

## Advantages of Crossplane CLI Testing

✅ **No Kubernetes cluster required** - Run tests locally  
✅ **Fast feedback** - Tests complete in seconds  
✅ **Official tooling** - Maintained by Crossplane team  
✅ **Schema validation** - Validates against actual provider schemas  
✅ **Pre-deployment testing** - Catch errors before deploying  
✅ **CI/CD friendly** - Easy to integrate into pipelines  
✅ **Composition function support** - Tests the actual rendering logic

## Common Pitfalls

### 1. Crossplane v2 vs v1.x

**❌ Don’t use Claims in v2:**

```yaml
kind: Claim  # Old v1.x style - DON'T USE
```

**✅ Use XRs directly in v2:**

```yaml
kind: XAzureSubscription  # Crossplane v2 style
```

### 2. Missing Functions File

**❌ Error: “no functions specified”**

```bash
crossplane render xr.yaml composition.yaml  # Missing functions!
```

**✅ Always include functions.yml:**

```bash
crossplane render xr.yaml composition.yaml functions.yml
```

### 3. Function Runtime Mode

For local testing, use Development mode in functions.yml:

```yaml
metadata:
  annotations:
    render.crossplane.io/runtime: Development
```

## Resources

- [Crossplane CLI Command Reference](https://docs.crossplane.io/latest/cli/command-reference/)
- [Crossplane Render Documentation](https://docs.crossplane.io/latest/cli/command-reference/#render)
- [Crossplane Validate Documentation](https://docs.crossplane.io/latest/cli/command-reference/#validate)
- [Composition Functions Guide](https://docs.crossplane.io/latest/concepts/composition-functions/)
- [Testing Crossplane Compositions Blog](https://blog.upbound.io/composition-testing-patterns-rendering)

## Contributing

This is a learning repository. Feel free to:

- Add more test cases
- Improve existing tests
- Add documentation
- Share your learnings

## License

MIT License - Feel free to use for learning and reference.
