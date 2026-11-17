#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin vscode install

release_dir=${DESKBOX_RELEASE_DIR:?}
catalog="$release_dir/catalog.json"
checksum=7e70b3f3a081fa96ba88c926e2bf1f4fdc7f796a285b6a03e86e898eb577841f
if ! printf '%s  %s\n' "$checksum" "$catalog" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$catalog.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/vscode-v1.146.0-deskbox.1/vscode/catalog.json"
    printf '%s  %s\n' "$checksum" "$catalog.part" | sha256sum -c - >/dev/null
    mv -f "$catalog.part" "$catalog"
fi

deskbox-bridge progress PREPARING vscode '{}'
current=$(pkg catalog vscode | jq -r '.version // empty' 2>/dev/null || true)
target=$(jq -er '.version' "$catalog")
if [ -n "$current" ] && dpkg --compare-versions "$target" lt "$current"; then
    program_fail '不自动降级已安装版本'
fi
result=$(pkg ensure vscode "$catalog" repair)
program_result "$(printf '%s' "$result" | jq --arg version "$target" '. + {version:$version}')"
