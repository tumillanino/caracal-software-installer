#!/usr/bin/env bash
set -euo pipefail

find "${HOME}/.clap" -maxdepth 1 -iname '*dragonfly*' -exec rm -rf {} + 2>/dev/null || true
find "${HOME}/.vst3" -maxdepth 1 -iname '*dragonfly*' -exec rm -rf {} + 2>/dev/null || true
find "${HOME}/.lv2" -maxdepth 1 -iname '*dragonfly*' -exec rm -rf {} + 2>/dev/null || true

echo "Dragonfly Reverb removed from user plugin directories."
