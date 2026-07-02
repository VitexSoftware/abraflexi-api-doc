#!/bin/sh
# Build-verification test for the bilingual AbraFlexi REST API reference.
#
# 1. Both cs/ and en/ must build with Sphinx with zero warnings (-W turns
#    warnings into errors, catching broken toctrees, bad refs, malformed
#    tables, title-underline mismatches, etc.)
# 2. Both language trees must have the same number of chapters, so a new
#    chapter added in one language isn't silently forgotten in the other.
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "== Building cs/ =="
python3 -m sphinx -b html -W "$ROOT/cs" "$WORKDIR/cs"

echo "== Building en/ =="
python3 -m sphinx -b html -W "$ROOT/en" "$WORKDIR/en"

cs_count=$(find "$ROOT/cs" -maxdepth 1 -name '*.rst' | wc -l)
en_count=$(find "$ROOT/en" -maxdepth 1 -name '*.rst' | wc -l)

echo "== Chapter count: cs=$cs_count en=$en_count =="
if [ "$cs_count" -ne "$en_count" ]; then
    echo "FAIL: cs/ and en/ have a different number of chapters ($cs_count vs $en_count)" >&2
    exit 1
fi

echo "All checks passed."
