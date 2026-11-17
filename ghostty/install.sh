#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin ghostty install
release_dir=${DESKBOX_RELEASE_DIR:?}
cd "$release_dir"
fetch() {
    name=$1 checksum=$2
    url=${3:-"https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/ghostty-v1.4.0-deskbox.5/ghostty/$name"}
    if [ -f "$name" ] && printf "%s  %s\n" "$checksum" "$name" | sha256sum -c - >/dev/null; then return; fi
    curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
        --connect-timeout 10 --max-time 60 --output "$name.part" "$url"
    printf "%s  %s\n" "$checksum" "$name.part" | sha256sum -c - >/dev/null
    mv -f "$name.part" "$name"
}

fetch catalog.json 7f3dd097cf70fdd62ce67f55238abcf10ebfcb3c147f8a3d9d9059e47b0b7325
fetch configure.sh 66107e5f77dc3526dfe1e1134e54c95609d59c3f072c32365387e53857154784
fetch resolve-shared-tools.sh de83f5aedb64cbee498f45c27703b1536b3a08e3076b01b8df91e3e262b181de "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/shared-tools-v1/common/resolve-shared-tools.sh"

# Use the Turnip build paired with the catalog's Mesa on the validated Adreno 750.
# Keep the Vulkan manifest out of the shared prefix.
if [ "$(/system/bin/getprop ro.soc.model)" = SM8650 ]; then
    driver_dir="$release_dir/turnip"
    manifests="$driver_dir/vulkan/icd.d"
    archive=mesa-vulkan-icd-freedreno.deb
    fetch "$archive" 9d8968db6ca9013fdd8ab4018b3cb6695dd4920630205690f1084445b6c26f20 \
        "https://github.com/lfdevs/termux-packages/releases/download/freedreno-27.0.0-devel-20261025-r2/mesa-vulkan-icd-freedreno_27.0.0-92_aarch64.deb"
    mkdir -p "$manifests"
    driver="$driver_dir/libvulkan_freedreno.so"
    dpkg-deb --fsys-tarfile "$archive" |
        tar -xOf - ./data/data/com.termux/files/usr/lib/libvulkan_freedreno.so > "$driver.part"
    printf '%s  %s\n' b47de348ee862e557a9063ecb6dd329064320c65e08d1fe2c344aafb601bc0e6 "$driver.part" |
        sha256sum -c - >/dev/null
    mv -f "$driver.part" "$driver"
    jq -n --arg driver "$driver" '{file_format_version:"1.0.0",ICD:{library_path:$driver,api_version:"1.4.363"}}' \
        > "$manifests/freedreno_icd.aarch64.json.part"
    mv -f "$manifests/freedreno_icd.aarch64.json.part" "$manifests/freedreno_icd.aarch64.json"
fi

resolver="$release_dir/resolve-shared-tools.sh"
deskbox-bridge progress PREPARING ghostty '{}'
current=$(pkg installed ghostty 2>/dev/null || true)
target=$(jq -er '.version' catalog.json)
if [ -n "$current" ] && dpkg --compare-versions "$target" lt "$current"; then
    program_fail '不自动降级已安装版本'
fi
result=$(pkg ensure ghostty "$release_dir/catalog.json" repair "$resolver")
version=$target
program_result "$(printf '%s' "$result" | jq --arg version "$version" '. + {version:$version}')"
