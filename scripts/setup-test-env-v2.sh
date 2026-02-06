#!/bin/bash

# setup-test-env.sh
# Setup script for Crossplane unit testing tools
# Primary: Crossplane CLI
# Optional: Conftest, yq

set -e

echo "🔧 Setting up Crossplane unit testing environment..."

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

# Normalize architecture names
case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    arm64|aarch64)
        ARCH="arm64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "📋 Detected: $OS $ARCH"
echo ""

# ============================================================================
# REQUIRED: Crossplane CLI
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Installing Crossplane CLI (Required)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v crossplane &> /dev/null; then
    CURRENT_VERSION=$(crossplane --version 2>&1 | head -n1)
    echo "ℹ️  Crossplane CLI already installed: $CURRENT_VERSION"
    echo "   Updating to latest version..."
fi

# Install Crossplane CLI using official install script
echo "Downloading and installing Crossplane CLI..."
curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh

# Move to PATH
if [ ! -w /usr/local/bin ]; then
    echo "Moving crossplane to /usr/local/bin (requires sudo)..."
    sudo mv crossplane /usr/local/bin/
else
    mv crossplane /usr/local/bin/
fi

# Verify installation
if command -v crossplane &> /dev/null; then
    echo "✅ Crossplane CLI installed successfully!"
    crossplane --version
else
    echo "❌ Failed to install Crossplane CLI"
    exit 1
fi

echo ""

# ============================================================================
# OPTIONAL: Additional Tools
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Installing Optional Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ask user if they want optional tools
echo "The following tools are optional but recommended:"
echo "  • conftest - Policy testing with OPA"
echo "  • yq - YAML processing"
echo ""
read -p "Install optional tools? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    INSTALL_OPTIONAL=true
else
    INSTALL_OPTIONAL=false
fi

echo ""

# Install Conftest (optional)
if [ "$INSTALL_OPTIONAL" = true ]; then
    echo "📦 Installing Conftest..."
    CONFTEST_VERSION="0.45.0"
    
    if command -v conftest &> /dev/null; then
        echo "✅ Conftest already installed: $(conftest --version | head -n1)"
    else
        if [[ "$OS" == "Darwin" ]]; then
            if command -v brew &> /dev/null; then
                brew install conftest
            else
                CONFTEST_ARCH="$ARCH"
                [ "$ARCH" = "amd64" ] && CONFTEST_ARCH="x86_64"
                curl -L "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Darwin_${CONFTEST_ARCH}.tar.gz" | tar xz
                if [ ! -w /usr/local/bin ]; then
                    sudo mv conftest /usr/local/bin/
                else
                    mv conftest /usr/local/bin/
                fi
            fi
        elif [[ "$OS" == "Linux" ]]; then
            CONFTEST_ARCH="$ARCH"
            [ "$ARCH" = "amd64" ] && CONFTEST_ARCH="x86_64"
            curl -L "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_${CONFTEST_ARCH}.tar.gz" | tar xz
            if [ ! -w /usr/local/bin ]; then
                sudo mv conftest /usr/local/bin/
            else
                mv conftest /usr/local/bin/
            fi
        fi
        
        if command -v conftest &> /dev/null; then
            echo "✅ Conftest installed successfully!"
        else
            echo "⚠️  Failed to install Conftest (optional tool)"
        fi
    fi
    echo ""
    
    # Install yq (optional)
    echo "📦 Installing yq..."
    if command -v yq &> /dev/null; then
        echo "✅ yq already installed: $(yq --version)"
    else
        if [[ "$OS" == "Darwin" ]]; then
            if command -v brew &> /dev/null; then
                brew install yq
            else
                YQ_VERSION="4.35.1"
                curl -L "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_darwin_${ARCH}" -o /tmp/yq
                chmod +x /tmp/yq
                if [ ! -w /usr/local/bin ]; then
                    sudo mv /tmp/yq /usr/local/bin/yq
                else
                    mv /tmp/yq /usr/local/bin/yq
                fi
            fi
        elif [[ "$OS" == "Linux" ]]; then
            YQ_VERSION="4.35.1"
            curl -L "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH}" -o /tmp/yq
            chmod +x /tmp/yq
            if [ ! -w /usr/local/bin ]; then
                sudo mv /tmp/yq /usr/local/bin/yq
            else
                mv /tmp/yq /usr/local/bin/yq
            fi
        fi
        
        if command -v yq &> /dev/null; then
            echo "✅ yq installed successfully!"
        else
            echo "⚠️  Failed to install yq (optional tool)"
        fi
    fi
else
    echo "⏭️  Skipping optional tools installation"
fi

echo ""

# ============================================================================
# Verify and Summary
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Verification & Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Required tools:"
if command -v crossplane &> /dev/null; then
    echo "  ✅ crossplane: $(crossplane --version 2>&1 | head -n1)"
else
    echo "  ❌ crossplane: not installed"
fi

echo ""
echo "Optional tools:"
if command -v conftest &> /dev/null; then
    echo "  ✅ conftest: $(conftest --version | head -n1)"
else
    echo "  ⚠️  conftest: not installed (policy tests will be skipped)"
fi

if command -v yq &> /dev/null; then
    echo "  ✅ yq: $(yq --version)"
else
    echo "  ⚠️  yq: not installed (some helper scripts may not work)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. Test your setup:"
echo "     crossplane render --help"
echo ""
echo "  2. Run render tests:"
echo "     ./scripts/run-render-tests.sh"
echo ""
echo "  3. Run validation tests:"
echo "     ./scripts/run-validate-tests.sh"
echo ""
echo "  4. Run all tests:"
echo "     ./scripts/run-all-tests.sh"
echo ""
echo "For more information, see README.md"
echo ""
echo "Code Smell Detective 🔍 - Willem van Heemstra"
