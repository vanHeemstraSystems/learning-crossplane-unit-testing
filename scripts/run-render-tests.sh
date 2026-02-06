#!/bin/bash

# run-render-tests.sh
# Run crossplane render tests for all environments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🧪 Running Crossplane Render Tests${NC}"
echo "======================================"

# Pick the CLI binary name (Windows installs often use crank.exe).
XP_BIN="${XP_BIN:-}"
if [ -z "$XP_BIN" ]; then
    if command -v crossplane &> /dev/null; then
        XP_BIN="crossplane"
    elif command -v crank &> /dev/null; then
        XP_BIN="crank"
    fi
fi

# Ensure crossplane render uses the same Docker endpoint as the Docker CLI.
# On macOS, Docker Desktop often uses a context socket under ~/.docker/run/
# and /var/run/docker.sock may not exist.
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

# Check if Crossplane CLI is installed
if [ -z "$XP_BIN" ]; then
    echo -e "${RED}❌ Crossplane CLI not found${NC}"
    echo "Install from: https://docs.crossplane.io/latest/cli/"
    echo "Install with: curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh"
    exit 1
fi

echo "Using Crossplane CLI: $XP_BIN"
echo "Using Crossplane CLI version: $($XP_BIN version 2>/dev/null || $XP_BIN --version 2>/dev/null || true)"
echo ""

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run render test
run_render_test() {
    local env="$1"
    local xr_file="$REPO_ROOT/apis/v1alpha1/subscriptions/examples/xr-$env.yml"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Testing: $env environment${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ ! -f "$xr_file" ]; then
        echo -e "${RED}✗ XR file not found: $xr_file${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
    
    # Run crossplane render
    if OUTPUT=$($XP_BIN render \
        "$xr_file" \
        "$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml" \
        "$REPO_ROOT/apis/v1alpha1/subscriptions/functions/patch-and-transform.yml" 2>&1); then
        
        # Verify expected resources in output
        local checks_passed=0
        local checks_failed=0
        
        # Check 1: XR present
        if echo "$OUTPUT" | grep -q "kind: XAzureSubscription"; then
            echo -e "  ${GREEN}✓${NC} XR composite resource rendered"
            checks_passed=$((checks_passed + 1))
        else
            echo -e "  ${RED}✗${NC} XR composite resource missing"
            checks_failed=$((checks_failed + 1))
        fi
        
        # Check 2: Subscription resource
        if echo "$OUTPUT" | grep -q "kind: Subscription"; then
            echo -e "  ${GREEN}✓${NC} Subscription managed resource rendered"
            checks_passed=$((checks_passed + 1))
        else
            echo -e "  ${RED}✗${NC} Subscription managed resource missing"
            checks_failed=$((checks_failed + 1))
        fi
        
        # Check 3: ResourceGroup
        if echo "$OUTPUT" | grep -q "kind: ResourceGroup"; then
            echo -e "  ${GREEN}✓${NC} ResourceGroup managed resource rendered"
            checks_passed=$((checks_passed + 1))
        else
            echo -e "  ${RED}✗${NC} ResourceGroup managed resource missing"
            checks_failed=$((checks_failed + 1))
        fi
        
        # Check 4: Environment-specific validation
        case "$env" in
            dev)
                if echo "$OUTPUT" | grep -q "subscriptionName: atlas-dev"; then
                    echo -e "  ${GREEN}✓${NC} Subscription name correct for dev"
                    checks_passed=$((checks_passed + 1))
                else
                    echo -e "  ${RED}✗${NC} Subscription name incorrect for dev"
                    checks_failed=$((checks_failed + 1))
                fi
                
                if echo "$OUTPUT" | grep -q "workload: DevTest"; then
                    echo -e "  ${GREEN}✓${NC} Workload type correct for dev"
                    checks_passed=$((checks_passed + 1))
                else
                    echo -e "  ${RED}✗${NC} Workload type incorrect for dev"
                    checks_failed=$((checks_failed + 1))
                fi
                ;;
            staging)
                if echo "$OUTPUT" | grep -q "subscriptionName: atlas-staging"; then
                    echo -e "  ${GREEN}✓${NC} Subscription name correct for staging"
                    checks_passed=$((checks_passed + 1))
                else
                    echo -e "  ${RED}✗${NC} Subscription name incorrect for staging"
                    checks_failed=$((checks_failed + 1))
                fi
                ;;
            prod)
                if echo "$OUTPUT" | grep -q "subscriptionName: atlas-production"; then
                    echo -e "  ${GREEN}✓${NC} Subscription name correct for prod"
                    checks_passed=$((checks_passed + 1))
                else
                    echo -e "  ${RED}✗${NC} Subscription name incorrect for prod"
                    checks_failed=$((checks_failed + 1))
                fi
                
                if echo "$OUTPUT" | grep -q "workload: Production"; then
                    echo -e "  ${GREEN}✓${NC} Workload type correct for prod"
                    checks_passed=$((checks_passed + 1))
                else
                    echo -e "  ${RED}✗${NC} Workload type incorrect for prod"
                    checks_failed=$((checks_failed + 1))
                fi
                ;;
        esac
        
        echo ""
        echo "  Checks: $checks_passed passed, $checks_failed failed"
        
        if [ $checks_failed -eq 0 ]; then
            echo -e "${GREEN}✅ $env environment test PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        else
            echo -e "${RED}❌ $env environment test FAILED${NC}"
            echo ""
            echo "Output for debugging:"
            echo "$OUTPUT"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to render composition${NC}"
        echo "Error output:"
        echo "$OUTPUT"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Run tests for each environment
run_render_test "dev"
echo ""
run_render_test "staging"
echo ""
run_render_test "prod"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Render Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total environments tested: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
else
    echo -e "${GREEN}Failed: $FAILED_TESTS${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ All render tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some render tests failed${NC}"
    exit 1
fi
