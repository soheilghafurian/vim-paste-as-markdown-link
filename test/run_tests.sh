#!/bin/bash
# Run unit tests for paste_as_markdown_link plugin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

echo "Running paste_as_markdown_link unit tests..."
echo ""

cd "$PLUGIN_DIR"

# Run vim in ex mode with the test script
vim -es -N -u NONE -i NONE \
    -c "set nocompatible" \
    -c "source $PLUGIN_DIR/test/run_tests.vim" \
    2>&1

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "All tests passed!"
else
    echo "Some tests failed. See output above."
fi

exit $EXIT_CODE
