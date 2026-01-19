#!/bin/bash
# Validation test for setup.md structure
# Tests that all required checkpoints are present

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_FILE="$SCRIPT_DIR/../commands/setup.md"

# Required checkpoint patterns (in order of appearance)
CHECKPOINTS=(
    "Checkpoint.*specs/readme.md.*✓ PIN created"
    "Checkpoint.*specs/\[name\].md.*✓ spec created"
    "Checkpoint.*specs/\[name\]-plan.md.*✓ plan created"
    "Checkpoint.*\.claude/CLAUDE.md.*✓ CLAUDE.md created"
    "Checkpoint.*prompt.md.*✓ prompt.md created"
)

# Required structure elements
STRUCTURE=(
    "## Step 1: Check PIN"
    "## Step 2: Determine Mode"
    "### Forward Mode"
    "### Reverse Mode"
    "### Investigate Mode"
    "### Resolve Mode"
    "### Specialized Mode"
    "## Step 3: Create CLAUDE.md"
    "## Step 4: Create prompt.md"
    "## Step 5: Summary"
)

# Required spec template sections (must appear in both Forward and Reverse modes)
SPEC_TEMPLATE=(
    "## What It Does"
    "## Constraints"
    "## Key Files"
)

# Mode guidance patterns
MODE_GUIDANCE=(
    "Reverse mode documents existing code.*Forward mode"
)

# Keywords example pattern (must show synonyms/related terms for cache hits)
# Example format: authentication, login, logout, session, jwt, token, oauth, signin, signup
KEYWORDS_EXAMPLE=(
    "Example.*synonyms.*related terms.*cache hits"
    "Auth.*specs/auth.md.*authentication.*login.*logout.*session.*jwt.*token"
)

errors=0

echo "Validating setup.md structure..."

# Check file exists
if [[ ! -f "$SETUP_FILE" ]]; then
    echo "✗ FAIL: setup.md not found at $SETUP_FILE"
    exit 1
fi

# Validate checkpoints
echo ""
echo "Checking checkpoints..."
for pattern in "${CHECKPOINTS[@]}"; do
    if grep -qE "$pattern" "$SETUP_FILE"; then
        echo "✓ Found: $pattern"
    else
        echo "✗ MISSING: $pattern"
        ((errors++))
    fi
done

# Validate structure
echo ""
echo "Checking structure..."
for element in "${STRUCTURE[@]}"; do
    if grep -qF "$element" "$SETUP_FILE"; then
        echo "✓ Found: $element"
    else
        echo "✗ MISSING: $element"
        ((errors++))
    fi
done

# Validate spec template sections appear at least twice (Forward + Reverse modes)
echo ""
echo "Checking spec template sections..."
for section in "${SPEC_TEMPLATE[@]}"; do
    count=$(grep -cF "$section" "$SETUP_FILE" || true)
    if [[ $count -ge 2 ]]; then
        echo "✓ Found $count occurrences: $section"
    else
        echo "✗ MISSING or insufficient: $section (found $count, need 2+)"
        ((errors++))
    fi
done

# Validate mode guidance patterns
echo ""
echo "Checking mode guidance..."
for pattern in "${MODE_GUIDANCE[@]}"; do
    if grep -qE "$pattern" "$SETUP_FILE"; then
        echo "✓ Found: $pattern"
    else
        echo "✗ MISSING: $pattern"
        ((errors++))
    fi
done

# Validate keywords example (synonyms/related terms for cache hits)
echo ""
echo "Checking keywords example..."
for pattern in "${KEYWORDS_EXAMPLE[@]}"; do
    if grep -qE "$pattern" "$SETUP_FILE"; then
        echo "✓ Found: $pattern"
    else
        echo "✗ MISSING: $pattern"
        ((errors++))
    fi
done

# Summary
echo ""
if [[ $errors -eq 0 ]]; then
    echo "✓ All validations passed"
    exit 0
else
    echo "✗ $errors validation(s) failed"
    exit 1
fi
