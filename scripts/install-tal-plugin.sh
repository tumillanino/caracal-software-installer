#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <plugin-id> <display-name> <url> <primary-bundle-name>" >&2
    exit 1
fi

plugin_id="$1"
display_name="$2"
url="$3"
primary_bundle_name="$4"

workdir="$(mktemp -d)"
archive_path="${workdir}/${plugin_id}.zip"
extract_dir="${workdir}/extract"
target_vst_dir="${HOME}/.vst"
target_vst3_dir="${HOME}/.vst3"
target_lv2_dir="${HOME}/.lv2"
target_clap_dir="${HOME}/.clap"

cleanup() {
    rm -rf "${workdir}"
}

extract_zip() {
    local archive="$1"
    local destination="$2"

    mkdir -p "${destination}"
    if command -v unzip >/dev/null 2>&1; then
        unzip -q "${archive}" -d "${destination}"
        return
    fi

    if command -v 7z >/dev/null 2>&1; then
        7z x -y "-o${destination}" "${archive}" >/dev/null
        return
    fi

    if command -v bsdtar >/dev/null 2>&1; then
        bsdtar -xf "${archive}" -C "${destination}"
        return
    fi

    echo "Need one of: unzip, 7z, or bsdtar to unpack ZIP archives." >&2
    exit 1
}

copy_bundle_dir() {
    local source="$1"
    local destination_root="$2"
    local name
    name="$(basename "${source}")"

    mkdir -p "${destination_root}"
    rm -rf "${destination_root}/${name}"
    cp -a "${source}" "${destination_root}/"
}

copy_plugin_file() {
    local source="$1"
    local destination_root="$2"

    mkdir -p "${destination_root}"
    install -m755 "${source}" "${destination_root}/$(basename "${source}")"
}

trap cleanup EXIT

echo "Downloading ${display_name}..."
curl -fL --retry 3 --retry-delay 2 -o "${archive_path}" "${url}"
extract_zip "${archive_path}" "${extract_dir}"

mkdir -p "${target_vst_dir}" "${target_vst3_dir}" "${target_lv2_dir}" "${target_clap_dir}"

while IFS= read -r -d '' clap_file; do
    copy_plugin_file "${clap_file}" "${target_clap_dir}"
done < <(find "${extract_dir}" -type f -name '*.clap' -print0)

while IFS= read -r -d '' vst3_bundle; do
    copy_bundle_dir "${vst3_bundle}" "${target_vst3_dir}"
done < <(find "${extract_dir}" -type d -name '*.vst3' -print0)

while IFS= read -r -d '' lv2_bundle; do
    copy_bundle_dir "${lv2_bundle}" "${target_lv2_dir}"
done < <(find "${extract_dir}" -type d -name '*.lv2' -print0)

while IFS= read -r -d '' vst2_file; do
    copy_plugin_file "${vst2_file}" "${target_vst_dir}"
done < <(
    find "${extract_dir}" \
        -type f \
        -name '*.so' \
        ! -path '*/Contents/*' \
        ! -path '*/.lv2/*' \
        -print0
)

echo "${display_name} installed into:"
echo "  ${target_clap_dir}"
echo "  ${target_vst3_dir}"
echo "  ${target_lv2_dir}"
echo "  ${target_vst_dir}"

if [[ ! -e "${target_clap_dir}/${primary_bundle_name}.clap" ]]; then
    echo "Warning: expected CLAP file ${primary_bundle_name}.clap was not found after install." >&2
fi
if [[ ! -e "${target_vst3_dir}/${primary_bundle_name}.vst3" ]]; then
    echo "Warning: expected VST3 bundle ${primary_bundle_name}.vst3 was not found after install." >&2
fi
