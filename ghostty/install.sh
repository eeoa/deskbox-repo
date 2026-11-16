#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin ghostty install
release_dir=${DESKBOX_RELEASE_DIR:?}
cd "$release_dir"
fetch() {
    name=$1 checksum=$2
    if [ -f "$name" ] && printf "%s  %s\n" "$checksum" "$name" | sha256sum -c - >/dev/null; then return; fi
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$name.part" "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/ghostty-v1.4.0-deskbox.2/ghostty/$name"
    printf "%s  %s\n" "$checksum" "$name.part" | sha256sum -c - >/dev/null
    mv -f "$name.part" "$name"
}

fetch catalog.json d9e51fd900c93f2220cf698f05f23ff46bbe0eb1b1b248c709bf3c448c81705a
fetch configure.sh 66107e5f77dc3526dfe1e1134e54c95609d59c3f072c32365387e53857154784
deskbox-bridge progress PREPARING ghostty '{}'
current=$(pkg installed ghostty 2>/dev/null || true)
target=$(jq -er '.version' catalog.json)
if [ -n "$current" ] && dpkg --compare-versions "$target" lt "$current"; then
    program_fail '不自动降级已安装版本'
fi
result=$(pkg ensure ghostty "$release_dir/catalog.json" repair)
version=$target
program_result "$(printf '%s' "$result" | jq --arg version "$version" '. + {version:$version}')"
