#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <project-name> <display-name>" >&2
    exit 1
fi

project_name="$1"
display_name="$2"

rm -rf "${HOME}/.local/lib/lv2/${project_name}.lv2"
rm -rf "${HOME}/.local/lib/vst3/${project_name}.vst3"
rm -rf "${HOME}/.local/lib/clap/${project_name}.clap"
rm -f "${HOME}/.local/lib/vst/${project_name}.so"
rm -f "${HOME}/.local/lib/vst/lib${project_name}.so"
rm -f "${HOME}/.local/bin/${project_name}"
rm -f "${HOME}/.local/share/applications/${project_name}.desktop"
rm -f "${HOME}/.local/share/metainfo/${project_name}.metainfo.xml"
rm -f "${HOME}/.local/share/metainfo/${project_name}.appdata.xml"
find "${HOME}/.local/share/icons" -type f \( -iname "${project_name}*.png" -o -iname "${project_name}*.svg" \) -delete 2>/dev/null || true

echo "${display_name} removed from ${HOME}/.local"
