#!/bin/bash

# validate-manifests.sh
# Validates Crossplane manifest syntax and structure

set -e

echo "🔍 Validating Crossplane manifests..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
    local test_name="$1"
    local command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "  Testing: $test_name... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# 1. YAML Syntax Validation
echo ""
echo "📋 Step 1: YAML Syntax Validation"
echo "=================================="

for file in "$REPO_ROOT"/apis/v1alpha1/subscriptions/*.yml \
            "$REPO_ROOT"/apis/v1alpha1/subscriptions/examples/*.yml; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        run_test "$filename syntax" "yq eval '.' '$file'"
    fi
done

# 2. Kubernetes Resource Validation
echo ""
echo "🎯 Step 2: Kubernetes Resource Validation"
echo "=========================================="

# Validate XRD
if [[ -f "$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml" ]]; then
    run_test "XRD structure" "kubectl --dry-run=client -f '$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml' validate"
fi

# Validate Composition
if [[ -f "$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml" ]]; then
    run_test "Composition structure" "kubectl --dry-run=client -f '$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml' validate"
fi

# Validate XR examples
for file in "$REPO_ROOT"/apis/v1alpha1/subscriptions/examples/xr-*.yml; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        run_test "XR $filename structure" "kubectl --dry-run=client -f '$file' validate"
    fi
done

# 3. Schema Validation
echo ""
echo "📐 Step 3: Schema Validation"
echo "============================="

# Check if XRD has required fields
if [[ -f "$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml" ]]; then
    run_test "XRD has spec.group" "yq eval '.spec.group' '$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml' | grep -q 'example.io'"
    run_test "XRD has spec.names" "yq eval '.spec.names' '$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml' | grep -q 'kind'"
    run_test "XRD has versions" "yq eval '.spec.versions' '$REPO_ROOT/apis/v1alpha1/subscriptions/xrd.yml' | grep -q 'v1alpha1'"
fi

# Check if Composition has required fields
if [[ -f "$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml" ]]; then
    run_test "Composition has compositeTypeRef" "yq eval '.spec.compositeTypeRef' '$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml' | grep -q 'XAzureSubscription'"
    run_test "Composition uses Pipeline mode" "yq eval '.spec.mode' '$REPO_ROOT/apis/v1alpha1/subscriptions/composition.yml' | grep -q 'Pipeline'"
fi

# 4. Naming Convention Validation
echo ""
echo "📛 Step 4: Naming Convention Validation"
echo "========================================"

for file in "$REPO_ROOT"/apis/v1alpha1/subscriptions/examples/xr-*.yml; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        
        # Check subscription name starts with "atlas-"
        subscription_name=$(yq eval '.spec.parameters.subscriptionName' "$file")
        if [[ "$subscription_name" == atlas-* ]]; then
            echo -e "  ${GREEN}✓${NC} $filename: subscription name follows convention"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}✗${NC} $filename: subscription name should start with 'atlas-'"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        
        # Check resource group name starts with "rg-atlas-"
        rg_name=$(yq eval '.spec.parameters.defaultResourceGroup.name' "$file")
        if [[ "$rg_name" == rg-atlas-* ]]; then
            echo -e "  ${GREEN}✓${NC} $filename: resource group name follows convention"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}✗${NC} $filename: resource group name should start with 'rg-atlas-'"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
    fi
done

# 5. Required Tags Validation
echo ""
echo "🏷️  Step 5: Required Tags Validation"
echo "===================================="

REQUIRED_TAGS=("cost-center" "project" "owner")

for file in "$REPO_ROOT"/apis/v1alpha1/subscriptions/examples/xr-*.yml; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")
        
        for tag in "${REQUIRED_TAGS[@]}"; do
            if yq eval ".spec.parameters.tags.$tag" "$file" | grep -q "null"; then
                echo -e "  ${RED}✗${NC} $filename: missing required tag '$tag'"
                FAILED_TESTS=$((FAILED_TESTS + 1))
            else
                echo -e "  ${GREEN}✓${NC} $filename: has required tag '$tag'"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            fi
            TOTAL_TESTS=$((TOTAL_TESTS + 1))
        done
    fi
done

# Summary
echo ""
echo "📊 Validation Summary"
echo "====================="
echo "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
if [[ $FAILED_TESTS -gt 0 ]]; then
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
else
    echo -e "${GREEN}Failed: $FAILED_TESTS${NC}"
fi

echo ""
if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${GREEN}✅ All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some validations failed. Please review the output above.${NC}"
    exit 1
fi
