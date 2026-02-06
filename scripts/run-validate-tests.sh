#!/bin/bash

# run-validate-tests.sh
# Run crossplane beta validate tests against provider schemas

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔍 Running Crossplane Validation Tests${NC}"
echo "=========================================="

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

# Check if crossplane CLI is installed
if ! command -v crossplane &> /dev/null; then
    echo -e "${RED}❌ crossplane CLI not found${NC}"
    echo "Install with: curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh"
    exit 1
fi

echo "Using crossplane CLI version: $(crossplane --version)"
echo ""

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run validation test
run_validation_test() {
    local env="$1"
    local xr_file="$REPO_ROOT/apis/v1alpha1/subscriptions/examples/xr-$env.yml"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Validating: $env environment${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ ! -f "$xr_file" ]; then
        echo -e "${RED}✗ XR file not found: $xr_file${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
    
    # Render and pipe to validate
    echo "Rendering composition..."
    if RENDER_OUTPUT=$(crossplane render \
        "$xr_file" \
        "$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml" \
        "$REPO_ROOT/apis/v1alpha1/subscriptions/functions/patch-and-transform.yml" \
        --include-full-xr 2>&1); then
        
        echo -e "${GREEN}✓${NC} Composition rendered successfully"
        
        # Validate against XRD
        echo "Validating against XRD schema..."
        if echo "$RENDER_OUTPUT" | crossplane beta validate \
            "$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml" \
            - > /dev/null 2>&1; then
            
            echo -e "${GREEN}✓${NC} XRD schema validation passed"
            echo -e "${GREEN}✅ $env environment validation PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        else
            echo -e "${RED}✗${NC} XRD schema validation failed"
            echo ""
            echo "Validation output:"
            echo "$RENDER_OUTPUT" | crossplane beta validate \
                "$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml" \
                - 2>&1 || true
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to render composition${NC}"
        echo "Error output:"
        echo "$RENDER_OUTPUT"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Optional: Download and validate against provider schemas
validate_against_provider_schemas() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Advanced: Validating against provider schemas${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "${YELLOW}ℹ️  Provider schema validation requires provider CRD files${NC}"
    echo -e "${YELLOW}   This is optional and can be skipped${NC}"
    echo ""
    
    # Example validation against provider schema (if CRD files are available)
    # This would require downloading the Azure provider CRDs first
    
    echo -e "${YELLOW}⚠️  Skipping provider schema validation (requires provider CRDs)${NC}"
    echo -e "${YELLOW}   To enable: download provider CRDs and uncomment validation code${NC}"
    
    # Uncomment and modify this section when you have provider CRDs:
    # 
    # PROVIDER_CRDS="path/to/provider-azure-crds.yaml"
    # 
    # for env in dev staging prod; do
    #     echo "Validating $env against provider schemas..."
    #     crossplane render \
    #         "$REPO_ROOT/apis/v1alpha1/subscriptions/examples/xr-$env.yml" \
    #         "$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml" \
    #         "$REPO_ROOT/apis/v1alpha1/subscriptions/functions/patch-and-transform.yml" \
    #         --include-full-xr | \
    #     crossplane beta validate \
    #         "$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml" \
    #         "$PROVIDER_CRDS" \
    #         -
    # done
}

# Run validation tests for each environment
run_validation_test "dev"
echo ""
run_validation_test "staging"
echo ""
run_validation_test "prod"
echo ""

# Optional provider schema validation
validate_against_provider_schemas

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Validation Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total environments validated: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
else
    echo -e "${GREEN}Failed: $FAILED_TESTS${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ All validation tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  • Run policy tests: ./scripts/run-policy-tests.sh (if configured)"
    echo "  • Deploy to cluster: kubectl apply -f apis/v1alpha1/subscriptions/"
    exit 0
else
    echo -e "${RED}❌ Some validation tests failed${NC}"
    exit 1
fi
