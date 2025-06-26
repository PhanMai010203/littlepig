#!/bin/bash
# Phase 4: Automated Protection Against Manual Edits to Generated Files
# This script verifies that .config.dart files have not been manually modified

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
GENERATED_FILE="lib/core/di/injection.config.dart"
TEMP_FILE="/tmp/injection.config.dart.expected"
BUILD_RUNNER_OUTPUT="/tmp/build_runner.out"

echo -e "${YELLOW}🔍 Phase 4: Checking for manual edits to generated files...${NC}"

# Check if the generated file exists
if [ ! -f "$GENERATED_FILE" ]; then
    echo -e "${RED}❌ ERROR: Generated file $GENERATED_FILE not found${NC}"
    exit 1
fi

# Store current file for comparison
cp "$GENERATED_FILE" "$TEMP_FILE.current"

# Regenerate the file using build_runner
echo -e "${YELLOW}🔄 Regenerating code to check for differences...${NC}"

# Run build_runner to regenerate files
if ! flutter packages pub run build_runner build --delete-conflicting-outputs > "$BUILD_RUNNER_OUTPUT" 2>&1; then
    echo -e "${RED}❌ ERROR: Failed to run build_runner${NC}"
    echo "Build runner output:"
    cat "$BUILD_RUNNER_OUTPUT"
    exit 1
fi

# Compare the files
if diff -q "$TEMP_FILE.current" "$GENERATED_FILE" > /dev/null; then
    echo -e "${GREEN}✅ SUCCESS: No manual edits detected in generated files${NC}"
    echo "   - $GENERATED_FILE is properly generated"
    rm -f "$TEMP_FILE.current" "$BUILD_RUNNER_OUTPUT"
    exit 0
else
    echo -e "${RED}❌ ERROR: Manual edits detected in generated file!${NC}"
    echo ""
    echo -e "${YELLOW}📄 File: $GENERATED_FILE${NC}"
    echo ""
    echo -e "${YELLOW}🔍 Differences found:${NC}"
    diff "$TEMP_FILE.current" "$GENERATED_FILE" || true
    echo ""
    echo -e "${YELLOW}💡 To fix this issue:${NC}"
    echo "   1. Revert any manual changes to $GENERATED_FILE"
    echo "   2. Make changes to the source files (classes with @injectable annotations)"
    echo "   3. Run: flutter packages pub run build_runner build"
    echo "   4. Commit the regenerated file"
    echo ""
    echo -e "${RED}🚫 Manual edits to generated files are not allowed!${NC}"
    
    # Clean up
    rm -f "$TEMP_FILE.current" "$BUILD_RUNNER_OUTPUT"
    exit 1
fi