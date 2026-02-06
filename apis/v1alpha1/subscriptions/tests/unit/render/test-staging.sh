#!/bin/bash

# test-staging.sh
# Unit test for staging environment using crossplane render

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"

echo "🧪 Testing staging environment XR with crossplane render..."

# Pick the CLI binary name (Windows installs often use crank.exe).
XP_BIN="${XP_BIN:-}"
if [ -z "$XP_BIN" ]; then
  if command -v crossplane &> /dev/null; then
    XP_BIN="crossplane"
  elif command -v crank &> /dev/null; then
    XP_BIN="crank"
  fi
fi
if [ -z "$XP_BIN" ]; then
  echo -e "${RED}❌ Crossplane CLI not found${NC}"
  echo "Install from: https://docs.crossplane.io/latest/cli/"
  exit 1
fi

# Ensure crossplane render can talk to Docker Desktop on macOS.
# Docker CLI may use a context socket under ~/.docker/run/, while /var/run/docker.sock may not exist.
if [ -z "${DOCKER_HOST:-}" ] && command -v docker &> /dev/null; then
  DOCKER_CTX="$(docker context show 2>/dev/null || true)"
  if [ -n "$DOCKER_CTX" ]; then
    DOCKER_HOST_FROM_CTX="$(docker context inspect --format '{{.Endpoints.docker.Host}}' "$DOCKER_CTX" 2>/dev/null || true)"
    if [ -n "$DOCKER_HOST_FROM_CTX" ]; then
      export DOCKER_HOST="$DOCKER_HOST_FROM_CTX"
    fi
  fi
fi
if [ -z "${DOCKER_HOST:-}" ] && [ -S "$HOME/.docker/run/docker.sock" ]; then
  export DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"
fi

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Render the composition
if ! OUTPUT=$($XP_BIN render \
  "$REPO_ROOT/apis/v1alpha1/subscriptions/examples/xr-staging.yml" \
  "$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml" \
  "$REPO_ROOT/apis/v1alpha1/subscriptions/functions/patch-and-transform.yml" 2>&1); then
  echo -e "${RED}❌ crossplane render failed${NC}"
  echo ""
  echo "$OUTPUT"
  exit 1
fi

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
test_output "Subscription name is atlas-staging" "subscriptionName: atlas-staging"

# Test 5: Workload type is DevTest
test_output "Workload type is DevTest" "workload: DevTest"

# Test 6: Environment tag present
test_output "Environment tag present" "environment: staging"

# Test 7: Resource group has correct name
test_output "Resource group name is rg-atlas-staging-weu" "name: rg-atlas-staging-weu"

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
  echo -e "${GREEN}✅ All staging environment tests passed!${NC}"
  exit 0
fi
