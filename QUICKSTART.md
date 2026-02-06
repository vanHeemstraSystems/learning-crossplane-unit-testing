# Quick Start Guide

Get your Crossplane unit testing environment up and running in minutes.

## Prerequisites

- Git installed
- Kubernetes cluster access (optional, for KUTTL tests)
- Bash shell (Linux/macOS or WSL on Windows)

## Step 1: Clone and Setup

```bash
# Clone your repository
git clone https://github.com/vanHeemstraSystems/learning-crossplane-unit-testing.git
cd learning-crossplane-unit-testing
```

## Step 2: Install Testing Tools

```bash
# Run the setup script
chmod +x scripts/setup-test-env.sh
./scripts/setup-test-env.sh
```

This installs:
- ✅ KUTTL - Kubernetes testing framework
- ✅ Conftest - Policy testing with OPA
- ✅ Kubeval - Kubernetes YAML validation
- ✅ yq - YAML processor
- ✅ kubectl - Kubernetes CLI

## Step 3: Validate Manifests

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run manifest validation
./scripts/validate-manifests.sh
```

Expected output:
```
✓ XRD validation passed
✓ Composition validation passed
✓ XR examples validated
✓ Naming conventions verified
✓ Required tags present
```

## Step 4: Run Policy Tests

```bash
# Run Conftest policy tests
cd apis/v1alpha1/subscriptions/tests/unit/conftest

# Test XRD
conftest test ../../xrd.yml -p policy/xrd-validation.rego

# Test Composition
conftest test ../../composition.yml -p policy/composition-validation.rego

# Test XR examples
conftest test ../../examples/xr-dev.yml -p policy/xr-validation.rego
conftest test ../../examples/xr-staging.yml -p policy/xr-validation.rego
conftest test ../../examples/xr-prod.yml -p policy/xr-validation.rego

# Run policy unit tests
conftest verify -p policy/
```

## Step 5: Run Complete Test Suite

```bash
# Return to repository root
cd /path/to/learning-crossplane-unit-testing

# Run all tests
./scripts/run-all-tests.sh
```

## Common Commands

### Validate Single File

```bash
# XRD
conftest test apis/v1alpha1/subscriptions/xrd.yml \
  -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xrd-validation.rego

# Composition
conftest test apis/v1alpha1/subscriptions/composition.yml \
  -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy/composition-validation.rego

# XR
conftest test apis/v1alpha1/subscriptions/examples/xr-dev.yml \
  -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xr-validation.rego
```

### YAML Syntax Check

```bash
# Check syntax
yq eval apis/v1alpha1/subscriptions/xrd.yml

# Kubernetes validation
kubectl --dry-run=client -f apis/v1alpha1/subscriptions/xrd.yml validate
```

### Run KUTTL Tests

```bash
# Requires Kubernetes cluster
kubectl kuttl test --config apis/v1alpha1/subscriptions/tests/unit/kuttl/kuttl-test.yaml
```

## Testing Workflow

```
1. Create/Modify XRD
   ↓
2. Create/Modify Composition
   ↓
3. Create XR example
   ↓
4. Run validate-manifests.sh
   ↓
5. Run policy tests
   ↓
6. Fix any violations
   ↓
7. Run complete test suite
   ↓
8. Commit changes
```

## CI/CD Integration

The repository includes GitHub Actions workflow that runs automatically on:
- Push to `main` or `develop`
- Pull requests to `main` or `develop`
- Manual workflow dispatch

View results in GitHub Actions tab.

## Troubleshooting

### Issue: "command not found: conftest"

**Solution**: Run the setup script again or install manually:
```bash
brew install conftest  # macOS
# OR
curl -L https://github.com/open-policy-agent/conftest/releases/download/v0.45.0/conftest_0.45.0_Linux_x86_64.tar.gz | tar xz
sudo mv conftest /usr/local/bin/
```

### Issue: Policy test fails with "deny" messages

**Solution**: This is expected! The policies are working correctly. Fix the violations in your YAML files.

Example:
```
FAIL - xr-dev.yml - main - Subscription name must start with 'atlas-'
```

Fix by updating the `subscriptionName` in your XR to start with `atlas-`.

### Issue: KUTTL tests don't run

**Solution**: KUTTL requires a Kubernetes cluster. Options:
1. Use a local cluster (minikube, kind, k3d)
2. Skip KUTTL tests and rely on Conftest/manifest validation
3. Use GitHub Actions which can provision a cluster

### Issue: Script permission denied

**Solution**: Make scripts executable:
```bash
chmod +x scripts/*.sh
```

## Next Steps

1. **Customize for your use case**:
   - Modify XRD schema for your resources
   - Update Composition with your resource requirements
   - Adjust policies to match your organization's standards

2. **Add more tests**:
   - Create additional KUTTL test cases
   - Add more policy rules
   - Expand JSON schema validation

3. **Expand to other resources**:
   - Create additional XRDs (VirtualNetworks, StorageAccounts, etc.)
   - Follow the same testing patterns
   - Reuse policy templates

4. **Integrate with your workflow**:
   - Add pre-commit hooks
   - Integrate with your CI/CD pipeline
   - Add deployment automation

## Learning Resources

- [Crossplane Documentation](https://docs.crossplane.io/)
- [KUTTL Documentation](https://kuttl.dev/)
- [Open Policy Agent](https://www.openpolicyagent.org/)
- [Conftest Examples](https://www.conftest.dev/)

## Support

For issues or questions:
1. Check the `docs/` directory for detailed documentation
2. Review the policy files for validation rules
3. Open an issue on GitHub
4. Contact Willem van Heemstra

---

**Happy Testing! 🧪**
