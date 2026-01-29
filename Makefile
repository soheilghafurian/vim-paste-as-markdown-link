.PHONY: test clean

test:
	@echo "Running paste_as_markdown_link unit tests..."
	@vim -es -N -u NONE -i NONE \
		-c "set nocompatible" \
		-c "source test/run_tests.vim" 2>&1 || true
	@cat test/results.txt

clean:
	@rm -f test/results.txt

help:
	@echo "Available targets:"
	@echo "  test   - Run unit tests"
	@echo "  clean  - Remove test results"
	@echo "  help   - Show this help"
