# GUIDANCE: Step-by-step to a first unit test (Subscription XRD)

This repository is meant to be a **template** you can recreate on another machine. This guide walks you from **empty folder** to **running a passing unit test** for a **Subscription XRD + Composition** using **Crossplane CLI**.

The “unit test” goal here is:
- **Render test**: `crossplane render` produces the expected managed resources (Subscription + ResourceGroup) from an XR input.
- **Schema validation test**: `crossplane beta validate` confirms the rendered output conforms to **your XRD schema** (fast, local, no cluster).
- **(Optional) Policy tests**: Conftest/OPA enforces your organization’s rules on XRD/Composition/XR YAML.

---

## What you’re building (minimum viable layout)

These are the minimum files needed to get a first green test:

```text
apis/v1alpha1/subscriptions/
  xrd.yml
  composition.yml
  functions/
    patch-and-transform.yml
  examples/
    xr-dev.yml
    xr-staging.yml
    xr-prod.yml
  tests/unit/render/
    test-dev.sh
scripts/
  run-render-tests.sh
  run-validate-tests.sh
  run-all-tests-v2.sh
  setup-test-env-v2.sh
```

This repo already contains working examples at those paths. When creating a similar repo elsewhere, copy these files first, then customize the API group/kind/names to your own domain.

---

## Step 0 — Create a new repo folder (other computer)

```bash
mkdir -p learning-crossplane-unit-testing
cd learning-crossplane-unit-testing

# optional but recommended
git init
```

Create the directory structure:

```bash
mkdir -p apis/v1alpha1/subscriptions/examples
mkdir -p apis/v1alpha1/subscriptions/tests/unit/render
mkdir -p scripts
```

---

## Step 1 — Copy in the “known-good” starting files

From this repo, copy these exact files into the same paths in your new repo:

- `apis/v1alpha1/subscriptions/xrd.yml`
- `apis/v1alpha1/subscriptions/composition.yml`
- `apis/v1alpha1/subscriptions/functions/patch-and-transform.yml`
- `apis/v1alpha1/subscriptions/examples/xr-dev.yml`
- `apis/v1alpha1/subscriptions/examples/xr-staging.yml`
- `apis/v1alpha1/subscriptions/examples/xr-prod.yml`
- `apis/v1alpha1/subscriptions/tests/unit/render/test-dev.sh`
- `scripts/run-render-tests.sh`
- `scripts/run-validate-tests.sh`
- `scripts/run-all-tests-v2.sh`
- `scripts/setup-test-env-v2.sh`

Then make scripts executable:

```bash
chmod +x scripts/*.sh
chmod +x apis/v1alpha1/subscriptions/tests/unit/render/*.sh
```

---

## Step 2 — Install tooling (Crossplane CLI is the key)

Run the repo setup script (recommended):

```bash
./scripts/setup-test-env-v2.sh
```

What matters for the first unit test:
- **Required**: `crossplane` CLI (for `crossplane render` and `crossplane beta validate`)
- **Optional**: `conftest` and `yq` (for policy tests and helper validations)

Verify:

```bash
crossplane --version
crossplane render --help
crossplane beta validate --help
```

---

## Step 3 — Run your first “unit test”: render test

This is the fastest feedback loop and does **not** require a Kubernetes cluster.

### 3A) Single test (dev)

```bash
./apis/v1alpha1/subscriptions/tests/unit/render/test-dev.sh
```

What it checks (by grepping the render output):
- XR exists: `kind: XAzureSubscription`
- Managed resources exist: `kind: Subscription`, `kind: ResourceGroup`
- Environment-specific fields (e.g. `subscriptionName: atlas-dev`, `workload: DevTest`, tags, location)

### 3B) All environments (dev/staging/prod)

```bash
./scripts/run-render-tests.sh
```

---

## Step 4 — Validate rendered output against your XRD schema

This ensures the XR + rendered resources conform to **your XRD’s OpenAPI schema**.

Run:

```bash
./scripts/run-validate-tests.sh
```

Under the hood this does (for each environment):

```bash
crossplane render apis/v1alpha1/subscriptions/examples/xr-<env>.yml \
  apis/v1alpha1/subscriptions/composition.yml \
  apis/v1alpha1/subscriptions/functions/patch-and-transform.yml \
  --include-full-xr \
| crossplane beta validate apis/v1alpha1/subscriptions/xrd.yml -
```

---

## Step 5 — One command to run the full suite

```bash
./scripts/run-all-tests-v2.sh
```

This runs:
- Required: render tests + XRD schema validation
- Optional (if installed): Conftest policies + OPA policy unit tests

---

## Step 6 — Customize from “Subscription example” to “your Subscription XRD”

If you keep the same API group/kind, the tests will run immediately. If you rename anything, update these three places **together**:

- **XRD**: `apis/v1alpha1/subscriptions/xrd.yml`
  - `.spec.group`
  - `.spec.names.kind`
  - `.metadata.name` (must match `plural.group`)
- **Composition**: `apis/v1alpha1/subscriptions/composition.yml`
  - `.spec.compositeTypeRef.apiVersion` (must match `group/version`)
  - `.spec.compositeTypeRef.kind` (must match XRD kind)
- **XR examples**: `apis/v1alpha1/subscriptions/examples/xr-*.yml`
  - `.apiVersion` (must match `group/version`)
  - `.kind` (must match XRD kind)
  - `.spec.parameters.*` (must match what your XRD schema defines)

### Common “first failure” fixes

- **Render fails with “no functions specified / function not found”**
  - Ensure `apis/v1alpha1/subscriptions/functions/patch-and-transform.yml` exists
  - Ensure Docker is running (default `crossplane render` runtime uses Docker)
  - Ensure Composition references `functionRef.name: function-patch-and-transform`

- **Validate fails**
  - Usually your XR examples don’t match the XRD schema (missing required fields, wrong enum values, wrong types).
  - Start by aligning `xrd.yml` required fields with what your `xr-*.yml` provide.

- **Render “passes” but checks fail**
  - The render test scripts use `grep` patterns like `subscriptionName: atlas-dev`.
  - Update `apis/v1alpha1/subscriptions/tests/unit/render/test-*.sh` to assert your new names/fields.

---

## Optional — Add policy tests (OPA/Conftest)

This repo includes example policies under:

`apis/v1alpha1/subscriptions/tests/unit/conftest/policy/`

Example (XRD):

```bash
conftest test apis/v1alpha1/subscriptions/xrd.yml \
  -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xrd-validation.rego
```

Policy tests are great for:
- naming conventions
- required tags
- ensuring enums contain required values
- “guardrails” that aren’t expressed in OpenAPI alone

---

## Optional — CI (GitHub Actions)

If you want the same checks on every push/PR, use:

- `.github/workflows/crossplane-cli-tests.yml`

It runs `crossplane render` and `crossplane beta validate` on Linux runners, and optionally runs Conftest policies.

---

## Definition of Done (first milestone)

You’ve successfully recreated the pattern when these commands all succeed on the other machine:

```bash
./scripts/setup-test-env-v2.sh
./apis/v1alpha1/subscriptions/tests/unit/render/test-dev.sh
./scripts/run-render-tests.sh
./scripts/run-validate-tests.sh
./scripts/run-all-tests-v2.sh
```

If you want, tell me what **API group** and **kind** you want for your new Subscription XRD (or paste your draft `xrd.yml`), and I’ll provide a tight “rename + update tests” checklist tailored to your domain.

