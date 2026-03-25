#!/bin/bash
#
# augent-obsidian test suite
# Run after setup.sh to verify everything is installed and working correctly.
#

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; ((PASS++)); }
fail() { echo -e "  ${RED}✗${NC} $1"; ((FAIL++)); }

echo ""
echo -e "${BOLD}augent-obsidian test suite${NC}"
echo "---"
echo ""

# --- Apps ---
echo -e "${BOLD}Apps${NC}"

if [[ -d "/Applications/Open in Obsidian.app" ]]; then
    pass "Open in Obsidian.app exists"
else
    fail "Open in Obsidian.app not found"
fi

if [[ -d "/Applications/Obsidian File Watcher.app" ]]; then
    pass "Obsidian File Watcher.app exists"
else
    fail "Obsidian File Watcher.app not found"
fi

if [[ -x "/Applications/Open in Obsidian.app/Contents/MacOS/open-in-obsidian" ]]; then
    pass "Open in Obsidian binary is executable"
else
    fail "Open in Obsidian binary missing or not executable"
fi

if [[ -x "/Applications/Obsidian File Watcher.app/Contents/MacOS/obsidian-file-watcher" ]]; then
    pass "File Watcher binary is executable"
else
    fail "File Watcher binary missing or not executable"
fi

echo ""

# --- File Handlers ---
echo -e "${BOLD}File Handlers${NC}"

TXT_HANDLER=$(duti -x txt 2>/dev/null | head -1)
if [[ "$TXT_HANDLER" == *"Open in Obsidian"* ]]; then
    pass ".txt handler: $TXT_HANDLER"
else
    fail ".txt handler: $TXT_HANDLER (expected Open in Obsidian)"
fi

MD_HANDLER=$(duti -x md 2>/dev/null | head -1)
if [[ "$MD_HANDLER" == *"Open in Obsidian"* ]]; then
    pass ".md handler: $MD_HANDLER"
else
    fail ".md handler: $MD_HANDLER (expected Open in Obsidian)"
fi

echo ""

# --- LaunchAgent ---
echo -e "${BOLD}LaunchAgent${NC}"

PLIST="$HOME/Library/LaunchAgents/com.local.obsidian-file-watcher.plist"

if [[ -f "$PLIST" ]]; then
    pass "LaunchAgent plist exists"
else
    fail "LaunchAgent plist not found at $PLIST"
fi

if [[ -f "$PLIST" ]] && plutil -lint "$PLIST" > /dev/null 2>&1; then
    pass "LaunchAgent plist is valid XML"
else
    fail "LaunchAgent plist is invalid"
fi

if [[ -f "$PLIST" ]] && grep -q "KeepAlive" "$PLIST" 2>/dev/null; then
    pass "LaunchAgent has KeepAlive enabled"
else
    fail "LaunchAgent missing KeepAlive"
fi

echo ""

# --- File Watcher Process ---
echo -e "${BOLD}File Watcher Process${NC}"

if ps aux | grep -v grep | grep -q "obsidian-file-watcher"; then
    pass "File Watcher is running"
else
    fail "File Watcher is not running"
fi

# Auto-restart test
if ps aux | grep -v grep | grep -q "obsidian-file-watcher"; then
    OLD_PID=$(ps aux | grep -v grep | grep "obsidian-file-watcher" | awk '{print $2}')
    kill "$OLD_PID" 2>/dev/null
    sleep 3
    if ps aux | grep -v grep | grep -q "obsidian-file-watcher"; then
        NEW_PID=$(ps aux | grep -v grep | grep "obsidian-file-watcher" | awk '{print $2}')
        if [[ "$NEW_PID" != "$OLD_PID" ]]; then
            pass "File Watcher auto-restarted (PID $OLD_PID -> $NEW_PID)"
        else
            fail "File Watcher PID unchanged after kill"
        fi
    else
        fail "File Watcher did not auto-restart after kill"
    fi
fi

echo ""

# --- Obsidian Vault ---
echo -e "${BOLD}Obsidian Vault${NC}"

VAULT_DIRS=()
while IFS= read -r line; do
    VAULT_DIRS+=("$(dirname "$line")")
done < <(find ~/Desktop ~/Documents ~/ -maxdepth 3 -name ".obsidian" -type d 2>/dev/null | head -5)

if [[ ${#VAULT_DIRS[@]} -gt 0 ]]; then
    pass "Found ${#VAULT_DIRS[@]} Obsidian vault(s)"
else
    fail "No Obsidian vaults found"
fi

VAULT="${VAULT_DIRS[0]}"

if [[ -f "$VAULT/.obsidian/community-plugins.json" ]]; then
    if python3 -c "
import json, sys
plugins = json.load(open('$VAULT/.obsidian/community-plugins.json'))
if 'obsidian-custom-file-extensions-plugin' not in plugins:
    sys.exit(1)
" 2>/dev/null; then
        pass "Custom File Extensions plugin installed"
    else
        fail "Custom File Extensions plugin not found"
    fi
fi

echo ""

# --- Live Edit Test ---
echo -e "${BOLD}Live Edit Test${NC}"

TEST_FILE=$(mktemp ~/Desktop/augent-test-XXXXX.txt)
echo "augent-obsidian test file" > "$TEST_FILE"

if [[ -f "$TEST_FILE" ]]; then
    pass "Test file created: $(basename "$TEST_FILE")"

    # Edit the file and check it persists
    echo "edited by test suite" >> "$TEST_FILE"
    if grep -q "edited by test suite" "$TEST_FILE" 2>/dev/null; then
        pass "File edit persisted on disk"
    else
        fail "File edit did not persist"
    fi

    rm -f "$TEST_FILE"
    pass "Test file cleaned up"
else
    fail "Could not create test file"
fi

echo ""

# --- Summary ---
echo "==========================================="
TOTAL=$((PASS + FAIL))
if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}  All $TOTAL tests passed${NC}"
else
    echo -e "${YELLOW}${BOLD}  $PASS passed, $FAIL failed${NC}"
fi
echo "==========================================="
echo ""

exit $FAIL
