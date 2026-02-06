#!/bin/bash

# test-dev.sh
# Unit test for dev environment using crossplane render

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"

echo "🧪 Testing dev environment XR with crossplane render..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Render the composition
OUTPUT=$(crossplane render \
  "$REPO_ROOT/apis/v1alpha1/subscriptions/examples/xr-dev.yml" \
  "$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml" \
  "$REPO_ROOT/apis/v1alpha1/subscriptions/functions/patch-and-transform.yml" 2>&1)

TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for tests
test_output() {
  local test_name="$1"
  local pattern="$2"
  
  if echo "$OUTPUT" | grep -q "$pattern"; then
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $test_name"
    echo "  Expected pattern: $pattern"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Run tests
echo ""
echo "Running tests..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Test 1: XR is present
test_output "XR composite resource present" "kind: XAzureSubscription"

# Test 2: Subscription resource created
test_output "Subscription managed resource created" "kind: Subscription"

# Test 3: ResourceGroup created
test_output "ResourceGroup managed resource created" "kind: ResourceGroup"

# Test 4: Subscription name is correct
test_output "Subscription name is atlas-dev" "subscriptionName: atlas-dev"

# Test 5: Workload type is DevTest
test_output "Workload type is DevTest" "workload: DevTest"

# Test 6: Environment tag present
test_output "Environment tag present" "environment: dev"

# Test 7: Resource group has correct name
test_output "Resource group name is rg-atlas-dev-weu" "name: rg-atlas-dev-weu"

# Test 8: Resource group location is westeurope
test_output "Resource group location is westeurope" "location: westeurope"

# Test 9: Cost center tag present
test_output "Cost center tag present" "cost-center: engineering"

# Test 10: Project tag present
test_output "Project tag present" "project: atlas-idp"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total: $((TESTS_PASSED + TESTS_FAILED))"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"

if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "${RED}Failed: $TESTS_FAILED${NC}"
  echo ""
  echo "Output for debugging:"
  echo "$OUTPUT"
  exit 1
else
  echo -e "${GREEN}Failed: $TESTS_FAILED${NC}"
  echo ""
  echo -e "${GREEN}✅ All dev environment tests passed!${NC}"
  exit 0
fi
