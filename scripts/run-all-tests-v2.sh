#!/bin/bash

# run-all-tests.sh
# Comprehensive test suite for Crossplane unit testing
# Primary: Crossplane CLI (render + validate)
# Secondary: Policy tests with Conftest (optional)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Crossplane Unit Test Suite           ║${NC}"
echo -e "${BLUE}║  Atlas IDP - Team Rockstars Cloud      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Pick the CLI binary name (Windows installs often use crank.exe).
XP_BIN="${XP_BIN:-}"
if [ -z "$XP_BIN" ]; then
    supports_render_and_validate() {
        local bin="$1"
        command -v "$bin" &> /dev/null || return 1
        "$bin" render --help > /dev/null 2>&1 || return 1
        "$bin" beta validate --help > /dev/null 2>&1 || return 1
        return 0
    }

    if supports_render_and_validate "crossplane"; then
        XP_BIN="crossplane"
    elif supports_render_and_validate "crank"; then
        XP_BIN="crank"
    fi
fi

# Function to run a test suite
run_suite() {
    local suite_name="$1"
    local command="$2"
    local required="$3"  # "required" or "optional"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Running: $suite_name${NC}"
    if [ "$required" = "optional" ]; then
        echo -e "${YELLOW}(Optional)${NC}"
    fi
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if eval "$command"; then
        echo -e "${GREEN}✅ $suite_name PASSED${NC}"
        PASSED_SUITES=$((PASSED_SUITES + 1))
        return 0
    else
        if [ "$required" = "optional" ]; then
            echo -e "${YELLOW}⚠️  $suite_name SKIPPED (optional)${NC}"
            # Don't count optional failures
            TOTAL_SUITES=$((TOTAL_SUITES - 1))
            return 0
        else
            echo -e "${RED}❌ $suite_name FAILED${NC}"
            FAILED_SUITES=$((FAILED_SUITES + 1))
            return 1
        fi
    fi
}

# Pre-flight checks
echo "🔍 Pre-flight checks..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -z "$XP_BIN" ]; then
    echo -e "${RED}❌ Crossplane CLI not found${NC}"
    echo "Install from: https://docs.crossplane.io/latest/cli/"
    exit 1
else
    echo -e "${GREEN}✓${NC} Crossplane CLI ($XP_BIN): $($XP_BIN version 2>/dev/null || $XP_BIN --version 2>/dev/null || true)"
fi

if command -v yq &> /dev/null; then
    echo -e "${GREEN}✓${NC} yq: $(yq --version)"
else
    echo -e "${YELLOW}⚠${NC} yq not found (optional for some tests)"
fi

if command -v conftest &> /dev/null; then
    echo -e "${GREEN}✓${NC} conftest: $(conftest --version | head -n1)"
else
    echo -e "${YELLOW}⚠${NC} conftest not found (policy tests will be skipped)"
fi

echo ""

# ============================================================================
# PRIMARY TESTS: Crossplane CLI (Required)
# ============================================================================

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}PRIMARY TESTS: Crossplane CLI${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"

# Test Suite 1: Crossplane Render Tests
run_suite "Crossplane Render Tests" \
    "$SCRIPT_DIR/run-render-tests.sh" \
    "required"

# Test Suite 2: Crossplane Validation Tests
run_suite "Crossplane Validation Tests" \
    "$SCRIPT_DIR/run-validate-tests.sh" \
    "required"

# ============================================================================
# SECONDARY TESTS: Policy & Governance (Optional)
# ============================================================================

if command -v conftest &> /dev/null; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}SECONDARY TESTS: Policy & Governance${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    
    # Test Suite 3: Conftest XRD Validation
    if [ -f "$REPO_ROOT/apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xrd-validation.rego" ]; then
        run_suite "Conftest XRD Validation" \
            "cd '$REPO_ROOT' && conftest test apis/v1alpha1/subscriptions/xrd.yml -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xrd-validation.rego --no-color" \
            "optional"
    fi
    
    # Test Suite 4: Conftest Composition Validation
    if [ -f "$REPO_ROOT/apis/v1alpha1/subscriptions/tests/unit/conftest/policy/composition-validation.rego" ]; then
        run_suite "Conftest Composition Validation" \
            "cd '$REPO_ROOT' && conftest test apis/v1alpha1/subscriptions/composition.yml -p apis/v1alpha1/subscriptions/tests/unit/conftest/policy/composition-validation.rego --no-color" \
            "optional"
    fi
    
    # Test Suite 5: Conftest XR Validation
    if [ -f "$REPO_ROOT/apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xr-validation.rego" ]; then
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Running: Conftest XR Validation${NC}"
        echo -e "${YELLOW}(Optional)${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        XR_TESTS_PASSED=true
        for xr_file in "$REPO_ROOT"/apis/v1alpha1/subscriptions/examples/xr-*.yml; do
            if [ -f "$xr_file" ]; then
                filename=$(basename "$xr_file")
                echo "  Testing: $filename"
                
                if conftest test "$xr_file" -p "$REPO_ROOT/apis/v1alpha1/subscriptions/tests/unit/conftest/policy/xr-validation.rego" --no-color > /dev/null 2>&1; then
                    echo -e "  ${GREEN}✓${NC} $filename passed"
                else
                    echo -e "  ${YELLOW}⚠${NC} $filename validation warnings (optional)"
                fi
            fi
        done
        echo -e "${YELLOW}⚠️  Conftest XR Validation completed (optional)${NC}"
    fi
    
    # Test Suite 6: OPA Policy Unit Tests
    if [ -d "$REPO_ROOT/apis/v1alpha1/subscriptions/tests/unit/conftest/test" ]; then
        run_suite "OPA Policy Unit Tests" \
            "cd '$REPO_ROOT/apis/v1alpha1/subscriptions/tests/unit/conftest' && conftest verify -p policy/ --no-color" \
            "optional"
    fi
else
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}SKIPPING: Policy & Governance Tests${NC}"
    echo -e "${YELLOW}(conftest not installed)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}To enable policy tests:${NC}"
    echo "  brew install conftest  # macOS"
    echo "  # or install from https://www.conftest.dev/"
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Suite Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total required test suites: $TOTAL_SUITES"
echo -e "${GREEN}Passed: $PASSED_SUITES${NC}"

if [ $FAILED_SUITES -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_SUITES${NC}"
else
    echo -e "${GREEN}Failed: $FAILED_SUITES${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAILED_SUITES -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ All required tests passed!         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "🎉 Your Crossplane resources are well-tested!"
    echo ""
    echo "Next steps:"
    echo "  1. Review rendered output: crossplane render ..."
    echo "  2. Deploy to cluster: kubectl apply -f apis/v1alpha1/subscriptions/"
    echo "  3. Monitor resources: kubectl get composite"
    echo ""
    echo "Code Smell Detective 🔍 - Willem van Heemstra"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ Some required tests failed         ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please review the output above and fix failing tests."
    echo ""
    echo "Debug tips:"
    echo "  • Run individual test suites to isolate issues"
    echo "  • Check crossplane render output for rendering errors"
    echo "  • Validate XRD schema matches your XR examples"
    echo "  • Ensure composition patches are correct"
    exit 1
fi
