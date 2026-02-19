#!/usr/bin/env bash
set -euo pipefail

DOCS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v dot >/dev/null 2>&1; then
  echo "Error: graphviz 'dot' is required to generate diagrams."
  exit 1
fi

dot -Tpng "$DOCS_DIR/architecture_diagram.dot" -o "$DOCS_DIR/architecture_diagram.png"
dot -Tpng "$DOCS_DIR/data_model.dot" -o "$DOCS_DIR/data_model.png"

echo "Generated diagrams:"
ls -lh "$DOCS_DIR/architecture_diagram.png" "$DOCS_DIR/data_model.png"
