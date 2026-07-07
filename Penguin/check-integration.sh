#!/usr/bin/env bash
# Quick Pixel Agents Integration Test
# This script tests the integration between IGelik and Pixel Agents

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PIXEL_AGENTS_DIR="$SCRIPT_DIR/pixel-agents"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   🚀 Pixel Agents - Integration Test                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_result() {
    local test_name=$1
    local result=$2
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC} - $test_name"
    else
        echo -e "${RED}❌ FAIL${NC} - $test_name"
    fi
}

# Test 1: Check Python
echo "Test 1: Python Installation"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo "  Python version: $PYTHON_VERSION"
    test_result "Python installed" 0
else
    test_result "Python installed" 1
    exit 1
fi

# Test 2: Check free-claude-code
echo ""
echo "Test 2: free-claude-code Repository"
if [ -d "$PIXEL_AGENTS_DIR/free-claude-code" ]; then
    test_result "free-claude-code cloned" 0
else
    echo "  ⚠️  free-claude-code not yet cloned (this is OK)"
    echo "  It will be cloned automatically when starting the server"
fi

# Test 3: Check requirements.txt
echo ""
echo "Test 3: Configuration Files"
if [ -f "$PIXEL_AGENTS_DIR/requirements.txt" ]; then
    test_result "requirements.txt exists" 0
else
    test_result "requirements.txt exists" 1
fi

if [ -f "$PIXEL_AGENTS_DIR/config.yaml" ]; then
    test_result "config.yaml exists" 0
else
    test_result "config.yaml exists" 1
fi

# Test 4: Check server script
echo ""
echo "Test 4: Server Scripts"
if [ -f "$PIXEL_AGENTS_DIR/agent_server.py" ]; then
    test_result "agent_server.py exists" 0
else
    test_result "agent_server.py exists" 1
    exit 1
fi

# Test 5: Check IGelik integration files
echo ""
echo "Test 5: IGelik Integration Files"
IGELIK_DIR="$SCRIPT_DIR/projects/IGelik"

files=(
    "$IGELIK_DIR/js/pixel-agents-client.js"
    "$IGELIK_DIR/js/office-ui.js"
    "$IGELIK_DIR/index.html"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        test_result "$(basename $file) exists" 0
    else
        test_result "$(basename $file) exists" 1
    fi
done

# Test 6: Check IGelik HTML has proper scripts
echo ""
echo "Test 6: HTML Integration"
if grep -q "pixel-agents-client.js" "$IGELIK_DIR/index.html"; then
    test_result "pixel-agents-client.js included in HTML" 0
else
    test_result "pixel-agents-client.js included in HTML" 1
fi

if grep -q "office-ui.js" "$IGELIK_DIR/index.html"; then
    test_result "office-ui.js included in HTML" 0
else
    test_result "office-ui.js included in HTML" 1
fi

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   📋 Integration Status Summary                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [ -f "$PIXEL_AGENTS_DIR/requirements.txt" ] && \
   [ -f "$PIXEL_AGENTS_DIR/agent_server.py" ] && \
   [ -f "$PIXEL_AGENTS_DIR/config.yaml" ] && \
   [ -f "$IGELIK_DIR/js/pixel-agents-client.js" ] && \
   [ -f "$IGELIK_DIR/js/office-ui.js" ]; then
    
    echo -e "${GREEN}✅ All integration files are in place!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Install dependencies:"
    echo "     pip install -r pixel-agents/requirements.txt"
    echo ""
    echo "  2. Start the Pixel Agents server:"
    echo "     ./pixel-agents/start-server.sh"
    echo ""
    echo "  3. Open IGelik in your browser:"
    echo "     projects/IGelik/index.html"
    echo ""
    echo "  4. Navigate to the '🏢 Văn phòng AI' tab"
    echo ""
    echo "For more information, see: PIXEL_AGENTS_INTEGRATION.md"
else
    echo -e "${RED}❌ Some integration files are missing!${NC}"
    exit 1
fi

echo ""
