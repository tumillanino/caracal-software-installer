#!/usr/bin/env bash
set -euo pipefail

find "${HOME}/.lv2" -maxdepth 1 -iname '*neural*amp*model*' -exec rm -rf {} + 2>/dev/null || true

echo "Neural Amp Modeler removed from user plugin directories."
