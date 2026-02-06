# learning-crossplane-unit-testing

A comprehensive learning repository for unit testing Crossplane v2 compositions, XRDs (CompositeResourceDefinitions), and XRs (Composite Resources).

## Overview

This repository demonstrates best practices for unit testing Crossplane v2 resources, with a focus on Azure infrastructure. We use Crossplane v2’s architecture which works directly with XRs (Composite Resources) instead of Claims, providing a more streamlined approach to infrastructure composition.

## What You’ll Learn

- Unit testing strategies for Crossplane XRDs
- Composition validation and testing
- XR (Composite Resource) testing patterns
- Azure-specific resource testing (Subscriptions, Resource Groups, etc.)
- Test automation and CI/CD integration
- Common pitfalls and how to avoid them

## Prerequisites

- Kubernetes cluster (local or remote)
- Crossplane v2.x installed
- `kubectl` CLI tool
- Testing tools:
  - [kuttl](https://kuttl.dev/) - Kubernetes Test Tool
  - [conftest](https://www.conftest.dev/) - Policy testing
  - [kubeval](https://kubeval.instrumenta.dev/) - YAML validation
  - [yq](https://github.com/mikefarah/yq) - YAML processor

## Directory Structure

```
learning-crossplane-unit-testing/
├── README.md
├── apis/
│   └── v1alpha1/
│       └── subscriptions/
│           ├── xrd.yml                    # XRD definition
│           ├── composition.yml            # Composition template
│           ├── examples/
│           │   ├── xr-dev.yml            # Development XR example
│           │   ├── xr-staging.yml        # Staging XR example
│           │   └── xr-prod.yml           # Production XR example
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
├── scripts/
│   ├── setup-test-env.sh
│   ├── run-all-tests.sh
│   └── validate-manifests.sh
└── .github/
    └── workflows/
        └── unit-tests.yml
```

## Use Case: Azure Subscription Management

### Scenario

As a Cloud Engineer at Team Rockstars Cloud working on the Atlas IDP, you need to provision and manage Azure Subscriptions for different environments (dev, staging, production) with consistent configuration and governance.

### Requirements

1. **Subscription Creation**: Automated Azure Subscription provisioning
1. **Resource Group**: Default resource group for subscription resources
1. **Tags**: Environment-specific tagging for cost allocation
1. **Naming Convention**: Standardized naming following company conventions
1. **Testing**: Comprehensive unit tests to validate configurations

### Implementation

#### 1. XRD (CompositeResourceDefinition)

Location: `apis/v1alpha1/subscriptions/xrd.yml`

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xazuresubscriptions.atlas.teamrockstars.cloud
spec:
  group: atlas.teamrockstars.cloud
  names:
    kind: XAzureSubscription
    plural: xazuresubscriptions
  versions:
    - name: v1alpha1
      served: true
      referenceable: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                parameters:
                  type: object
                  properties:
                    subscriptionName:
                      type: string
                      description: Name of the Azure Subscription
                    billingAccountId:
                      type: string
                      description: Azure Billing Account ID
                    workload:
                      type: string
                      enum:
                        - Production
                        - DevTest
                      description: Type of workload for the subscription
                    environment:
                      type: string
                      enum:
                        - dev
                        - staging
                        - prod
                      description: Environment designation
                    tags:
                      type: object
                      additionalProperties:
                        type: string
                      description: Additional tags for the subscription
                    defaultResourceGroup:
                      type: object
                      properties:
                        name:
                          type: string
                        location:
                          type: string
                          default: westeurope
                      required:
                        - name
                  required:
                    - subscriptionName
                    - billingAccountId
                    - workload
                    - environment
              required:
                - parameters
            status:
              type: object
              properties:
                subscriptionId:
                  type: string
                  description: Azure Subscription ID
                state:
                  type: string
                  description: Current state of the subscription
```

#### 2. Composition

Location: `apis/v1alpha1/subscriptions/composition.yml`

```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  name: xazuresubscription.atlas.teamrockstars.cloud
  labels:
    provider: azure
    resource: subscription
spec:
  compositeTypeRef:
    apiVersion: atlas.teamrockstars.cloud/v1alpha1
    kind: XAzureSubscription
  
  mode: Pipeline
  
  pipeline:
    - step: create-subscription
      functionRef:
        name: function-patch-and-transform
      input:
        apiVersion: pt.fn.crossplane.io/v1beta1
        kind: Resources
        resources:
          - name: subscription
            base:
              apiVersion: subscription.azure.upbound.io/v1beta1
              kind: Subscription
              spec:
                forProvider:
                  billingScope: ""
                  subscriptionName: ""
                  workload: ""
                  tags: {}
            patches:
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.billingAccountId
                toFieldPath: spec.forProvider.billingScope
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.subscriptionName
                toFieldPath: spec.forProvider.subscriptionName
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.workload
                toFieldPath: spec.forProvider.workload
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.tags
                toFieldPath: spec.forProvider.tags
                policy:
                  mergeOptions:
                    keepMapValues: true
              - type: ToCompositeFieldPath
                fromFieldPath: status.atProvider.subscriptionId
                toFieldPath: status.subscriptionId
              - type: ToCompositeFieldPath
                fromFieldPath: status.atProvider.state
                toFieldPath: status.state
            
          - name: default-resource-group
            base:
              apiVersion: azure.upbound.io/v1beta1
              kind: ResourceGroup
              spec:
                forProvider:
                  location: westeurope
                  tags: {}
            patches:
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.defaultResourceGroup.name
                toFieldPath: metadata.name
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.defaultResourceGroup.location
                toFieldPath: spec.forProvider.location
              - type: FromCompositeFieldPath
                fromFieldPath: spec.parameters.tags
                toFieldPath: spec.forProvider.tags
                policy:
                  mergeOptions:
                    keepMapValues: true
              - type: CombineFromComposite
                combine:
                  variables:
                    - fromFieldPath: spec.parameters.environment
                  strategy: string
                  string:
                    fmt: "atlas-subscription-%s"
                toFieldPath: spec.forProvider.tags.managed-by
```

#### 3. XR Examples

**Development Environment**

Location: `apis/v1alpha1/subscriptions/examples/xr-dev.yml`

```yaml
apiVersion: atlas.teamrockstars.cloud/v1alpha1
kind: XAzureSubscription
metadata:
  name: atlas-dev-subscription
  labels:
    environment: dev
    managed-by: crossplane
spec:
  parameters:
    subscriptionName: atlas-dev
    billingAccountId: "/providers/Microsoft.Billing/billingAccounts/12345678"
    workload: DevTest
    environment: dev
    tags:
      cost-center: "engineering"
      project: "atlas-idp"
      environment: "dev"
      owner: "willem.vanheemstra"
    defaultResourceGroup:
      name: rg-atlas-dev-weu
      location: westeurope
```

**Staging Environment**

Location: `apis/v1alpha1/subscriptions/examples/xr-staging.yml`

```yaml
apiVersion: atlas.teamrockstars.cloud/v1alpha1
kind: XAzureSubscription
metadata:
  name: atlas-staging-subscription
  labels:
    environment: staging
    managed-by: crossplane
spec:
  parameters:
    subscriptionName: atlas-staging
    billingAccountId: "/providers/Microsoft.Billing/billingAccounts/12345678"
    workload: DevTest
    environment: staging
    tags:
      cost-center: "engineering"
      project: "atlas-idp"
      environment: "staging"
      owner: "willem.vanheemstra"
    defaultResourceGroup:
      name: rg-atlas-staging-weu
      location: westeurope
```

**Production Environment**

Location: `apis/v1alpha1/subscriptions/examples/xr-prod.yml`

```yaml
apiVersion: atlas.teamrockstars.cloud/v1alpha1
kind: XAzureSubscription
metadata:
  name: atlas-prod-subscription
  labels:
    environment: prod
    managed-by: crossplane
spec:
  parameters:
    subscriptionName: atlas-production
    billingAccountId: "/providers/Microsoft.Billing/billingAccounts/12345678"
    workload: Production
    environment: prod
    tags:
      cost-center: "operations"
      project: "atlas-idp"
      environment: "prod"
      owner: "ops.team"
      compliance: "required"
    defaultResourceGroup:
      name: rg-atlas-prod-weu
      location: westeurope
```

## Unit Testing Strategy

### 1. KUTTL Tests (Integration-style Unit Tests)

Location: `apis/v1alpha1/subscriptions/tests/unit/kuttl/`

**Test Configuration**

File: `kuttl-test.yaml`

```yaml
apiVersion: kuttl.dev/v1beta1
kind: TestSuite
testDirs:
  - ./00-subscription-creation
timeout: 300
```

**Test Case: Subscription Creation**

File: `00-subscription-creation/00-xr.yaml`

```yaml
apiVersion: atlas.teamrockstars.cloud/v1alpha1
kind: XAzureSubscription
metadata:
  name: test-subscription
spec:
  parameters:
    subscriptionName: test-atlas-subscription
    billingAccountId: "/providers/Microsoft.Billing/billingAccounts/test-12345"
    workload: DevTest
    environment: dev
    tags:
      test: "true"
      purpose: "unit-testing"
    defaultResourceGroup:
      name: rg-test-weu
      location: westeurope
```

File: `00-subscription-creation/00-assert.yaml`

```yaml
apiVersion: subscription.azure.upbound.io/v1beta1
kind: Subscription
metadata:
  name: test-subscription-subscription
spec:
  forProvider:
    subscriptionName: test-atlas-subscription
    workload: DevTest
    tags:
      test: "true"
      purpose: "unit-testing"
---
apiVersion: azure.upbound.io/v1beta1
kind: ResourceGroup
metadata:
  name: rg-test-weu
spec:
  forProvider:
    location: westeurope
    tags:
      test: "true"
      purpose: "unit-testing"
      managed-by: atlas-subscription-dev
```

### 2. Conftest/OPA Policy Tests

Location: `apis/v1alpha1/subscriptions/tests/unit/conftest/`

**XRD Validation Policy**

File: `policy/xrd-validation.rego`

```rego
package xrd_validation

# Test that XRD has required metadata
deny[msg] {
    not input.metadata.name
    msg = "XRD must have a name"
}

# Test that XRD belongs to correct group
deny[msg] {
    input.spec.group != "atlas.teamrockstars.cloud"
    msg = sprintf("XRD group must be 'atlas.teamrockstars.cloud', got '%s'", [input.spec.group])
}

# Test that required parameters are defined
deny[msg] {
    not input.spec.versions[_].schema.openAPIV3Schema.properties.spec.properties.parameters
    msg = "XRD must define parameters in spec"
}

# Test that environment enum contains valid values
deny[msg] {
    environments := input.spec.versions[_].schema.openAPIV3Schema.properties.spec.properties.parameters.properties.environment.enum
    not valid_environments(environments)
    msg = "Environment enum must contain: dev, staging, prod"
}

valid_environments(environments) {
    required := {"dev", "staging", "prod"}
    provided := {e | e := environments[_]}
    required == provided
}

# Test that workload enum is correct
deny[msg] {
    workloads := input.spec.versions[_].schema.openAPIV3Schema.properties.spec.properties.parameters.properties.workload.enum
    not valid_workloads(workloads)
    msg = "Workload enum must contain: Production, DevTest"
}

valid_workloads(workloads) {
    required := {"Production", "DevTest"}
    provided := {w | w := workloads[_]}
    required == provided
}
```

**Composition Validation Policy**

File: `policy/composition-validation.rego`

```rego
package composition_validation

# Test that Composition references correct XRD
deny[msg] {
    input.spec.compositeTypeRef.kind != "XAzureSubscription"
    msg = sprintf("Composition must reference XAzureSubscription, got '%s'", [input.spec.compositeTypeRef.kind])
}

# Test that pipeline mode is used (Crossplane v2 best practice)
deny[msg] {
    input.spec.mode != "Pipeline"
    msg = "Composition should use Pipeline mode for Crossplane v2"
}

# Test that subscription resource exists in composition
deny[msg] {
    not has_subscription_resource
    msg = "Composition must include a Subscription resource"
}

has_subscription_resource {
    input.spec.pipeline[_].input.resources[_].base.kind == "Subscription"
}

# Test that resource group is created
deny[msg] {
    not has_resource_group
    msg = "Composition must include a ResourceGroup resource"
}

has_resource_group {
    input.spec.pipeline[_].input.resources[_].base.kind == "ResourceGroup"
}

# Test that required patches are present for subscription
deny[msg] {
    resource := input.spec.pipeline[_].input.resources[_]
    resource.name == "subscription"
    not has_required_subscription_patches(resource)
    msg = "Subscription resource must patch: billingAccountId, subscriptionName, workload, tags"
}

has_required_subscription_patches(resource) {
    patches := {p.fromFieldPath | p := resource.patches[_]}
    required := {
        "spec.parameters.billingAccountId",
        "spec.parameters.subscriptionName",
        "spec.parameters.workload",
        "spec.parameters.tags"
    }
    count(patches & required) == count(required)
}
```

**XR Validation Policy**

File: `policy/xr-validation.rego`

```rego
package xr_validation

# Test that XR has required metadata labels
deny[msg] {
    not input.metadata.labels.environment
    msg = "XR must have 'environment' label"
}

deny[msg] {
    not input.metadata.labels["managed-by"]
    msg = "XR must have 'managed-by' label"
}

# Test that environment label matches spec
deny[msg] {
    input.metadata.labels.environment != input.spec.parameters.environment
    msg = "Environment label must match spec.parameters.environment"
}

# Test that required parameters are provided
deny[msg] {
    not input.spec.parameters.subscriptionName
    msg = "XR must specify subscriptionName"
}

deny[msg] {
    not input.spec.parameters.billingAccountId
    msg = "XR must specify billingAccountId"
}

# Test that workload matches environment
deny[msg] {
    input.spec.parameters.environment == "prod"
    input.spec.parameters.workload != "Production"
    msg = "Production environment must use 'Production' workload"
}

# Test that tags include required fields
deny[msg] {
    not input.spec.parameters.tags["cost-center"]
    msg = "XR must include 'cost-center' tag"
}

deny[msg] {
    not input.spec.parameters.tags.project
    msg = "XR must include 'project' tag"
}

deny[msg] {
    not input.spec.parameters.tags.owner
    msg = "XR must include 'owner' tag"
}

# Test naming conventions
deny[msg] {
    not startswith(input.spec.parameters.subscriptionName, "atlas-")
    msg = "Subscription name must start with 'atlas-'"
}

deny[msg] {
    not startswith(input.spec.parameters.defaultResourceGroup.name, "rg-atlas-")
    msg = "Resource group name must start with 'rg-atlas-'"
}

# Test location is valid Azure region
deny[msg] {
    location := input.spec.parameters.defaultResourceGroup.location
    not valid_azure_region(location)
    msg = sprintf("Invalid Azure region: '%s'", [location])
}

valid_azure_region(location) {
    valid_regions := {
        "westeurope", "northeurope", "eastus", "westus", 
        "centralus", "southeastasia", "japaneast"
    }
    valid_regions[location]
}
```

**Policy Unit Tests**

File: `test/xrd-validation_test.rego`

```rego
package xrd_validation

test_xrd_missing_name {
    deny["XRD must have a name"] with input as {"metadata": {}}
}

test_xrd_wrong_group {
    deny[msg] with input as {
        "metadata": {"name": "test"},
        "spec": {"group": "wrong.group"}
    }
    contains(msg, "XRD group must be")
}

test_xrd_valid_environments {
    not deny[_] with input as {
        "metadata": {"name": "test"},
        "spec": {
            "group": "atlas.teamrockstars.cloud",
            "versions": [{
                "schema": {
                    "openAPIV3Schema": {
                        "properties": {
                            "spec": {
                                "properties": {
                                    "parameters": {
                                        "properties": {
                                            "environment": {
                                                "enum": ["dev", "staging", "prod"]
                                            },
                                            "workload": {
                                                "enum": ["Production", "DevTest"]
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }]
        }
    }
}
```

### 3. JSON Schema Validation

Location: `apis/v1alpha1/subscriptions/tests/unit/schemas/subscription-schema.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["apiVersion", "kind", "metadata", "spec"],
  "properties": {
    "apiVersion": {
      "type": "string",
      "pattern": "^atlas\\.teamrockstars\\.cloud/v1alpha1$"
    },
    "kind": {
      "type": "string",
      "const": "XAzureSubscription"
    },
    "metadata": {
      "type": "object",
      "required": ["name", "labels"],
      "properties": {
        "name": {
          "type": "string",
          "pattern": "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
        },
        "labels": {
          "type": "object",
          "required": ["environment", "managed-by"],
          "properties": {
            "environment": {
              "type": "string",
              "enum": ["dev", "staging", "prod"]
            },
            "managed-by": {
              "type": "string"
            }
          }
        }
      }
    },
    "spec": {
      "type": "object",
      "required": ["parameters"],
      "properties": {
        "parameters": {
          "type": "object",
          "required": [
            "subscriptionName",
            "billingAccountId",
            "workload",
            "environment"
          ],
          "properties": {
            "subscriptionName": {
              "type": "string",
              "pattern": "^atlas-"
            },
            "billingAccountId": {
              "type": "string",
              "pattern": "^/providers/Microsoft\\.Billing/billingAccounts/"
            },
            "workload": {
              "type": "string",
              "enum": ["Production", "DevTest"]
            },
            "environment": {
              "type": "string",
              "enum": ["dev", "staging", "prod"]
            },
            "tags": {
              "type": "object",
              "required": ["cost-center", "project", "owner"],
              "properties": {
                "cost-center": { "type": "string" },
                "project": { "type": "string" },
                "owner": { "type": "string" },
                "environment": { "type": "string" }
              }
            },
            "defaultResourceGroup": {
              "type": "object",
              "required": ["name"],
              "properties": {
                "name": {
                  "type": "string",
                  "pattern": "^rg-atlas-"
                },
                "location": {
                  "type": "string",
                  "enum": [
                    "westeurope",
                    "northeurope",
                    "eastus",
                    "westus",
                    "centralus"
                  ]
                }
              }
            }
          }
        }
      }
    }
  }
}
```

## Running Tests

### Setup Test Environment

```bash
# Install testing tools
./scripts/setup-test-env.sh

# Or manually:
brew install kuttl conftest kubeval yq
```

### Run All Tests

```bash
# Run complete test suite
./scripts/run-all-tests.sh

# Or run individually:

# 1. Validate YAML syntax
./scripts/validate-manifests.sh

# 2. Run Conftest policy tests
cd apis/v1alpha1/subscriptions/tests/unit/conftest
conftest test ../../xrd.yml -p policy/xrd-validation.rego
conftest test ../../composition.yml -p policy/composition-validation.rego
conftest test ../../examples/xr-dev.yml -p policy/xr-validation.rego

# 3. Run OPA policy unit tests
conftest verify -p policy/ -t test/

# 4. Validate against JSON Schema
yq eval apis/v1alpha1/subscriptions/examples/xr-dev.yml -o=json | \
  ajv validate -s apis/v1alpha1/subscriptions/tests/unit/schemas/subscription-schema.json

# 5. Run KUTTL tests (requires cluster)
kubectl kuttl test --config apis/v1alpha1/subscriptions/tests/unit/kuttl/kuttl-test.yaml
```

### Example Output

```
✓ XRD validation passed (0 violations)
✓ Composition validation passed (0 violations)
✓ XR validation passed (0 violations)
✓ Policy unit tests: 12/12 passed
✓ JSON Schema validation passed
✓ KUTTL tests: 1/1 passed
```

## Best Practices

### 1. Test Pyramid for Crossplane

```
        /\
       /  \    E2E Tests (few)
      /----\
     /      \  Integration Tests (some)
    /--------\
   /          \ Unit Tests (many)
  /____________\
```

- **Unit Tests** (this repo): Validate individual XRDs, Compositions, XRs
- **Integration Tests**: Test composition behavior with mock providers
- **E2E Tests**: Test against actual Azure APIs

### 2. What to Test

**XRD Level:**

- Schema validation
- Required fields presence
- Enum value correctness
- Field type validation
- OpenAPI v3 schema compliance

**Composition Level:**

- Correct XRD reference
- All required managed resources present
- Patch configurations correctness
- Transform functions validity
- Pipeline structure (Crossplane v2)

**XR Level:**

- Compliance with XRD schema
- Required parameters provided
- Naming conventions
- Tag requirements
- Environment-specific validation

### 3. Continuous Testing

Integrate tests into CI/CD:

```yaml
# .github/workflows/unit-tests.yml
name: Unit Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install tools
        run: |
          curl -L https://github.com/kudobuilder/kuttl/releases/download/v0.15.0/kuttl_0.15.0_linux_x86_64 -o kuttl
          chmod +x kuttl
          sudo mv kuttl /usr/local/bin/
          
          curl -L https://github.com/open-policy-agent/conftest/releases/download/v0.45.0/conftest_0.45.0_Linux_x86_64.tar.gz | tar xz
          sudo mv conftest /usr/local/bin/
      
      - name: Run Conftest
        run: |
          cd apis/v1alpha1/subscriptions/tests/unit/conftest
          conftest test ../../xrd.yml -p policy/
          conftest test ../../composition.yml -p policy/
          conftest test ../../examples/*.yml -p policy/
      
      - name: Run OPA unit tests
        run: |
          cd apis/v1alpha1/subscriptions/tests/unit/conftest
          conftest verify -p policy/ -t test/
```

## Common Pitfalls

### 1. Crossplane v2 vs v1.x

**❌ Don’t use Claims in v2:**

```yaml
# Old v1.x style - DON'T USE
kind: Claim
```

**✅ Use XRs directly in v2:**

```yaml
# Crossplane v2 style
kind: XAzureSubscription
```

### 2. Composition Mode

**❌ Avoid Resources mode (legacy):**

```yaml
spec:
  resources: [...]  # Old style
```

**✅ Use Pipeline mode:**

```yaml
spec:
  mode: Pipeline
  pipeline: [...]
```

### 3. Testing Without Mocks

- Use `kubectl --dry-run=client` for quick validation
- Use KUTTL with fake API server for integration tests
- Always test policy in isolation before cluster deployment

## Resources

- [Crossplane Documentation](https://docs.crossplane.io/)
- [Crossplane v2 Migration Guide](https://docs.crossplane.io/latest/concepts/composition-migrations/)
- [KUTTL Documentation](https://kuttl.dev/)
- [Open Policy Agent](https://www.openpolicyagent.org/)
- [Azure Upbound Provider](https://marketplace.upbound.io/providers/upbound/provider-azure/)

## Contributing

This is a learning repository. Feel free to:

- Add more test cases
- Improve existing policies
- Add documentation
- Share your learnings

## License

MIT License - Feel free to use for learning and reference.

-----

**Code Smell Detective** 🔍  
*Willem van Heemstra - Cloud Engineer @ Team Rockstars Cloud*
