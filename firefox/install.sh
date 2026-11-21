#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin firefox install
release_dir=${DESKBOX_RELEASE_DIR:?}
cd "$release_dir"
fetch() {
    name=$1 checksum=$2
    if [ -f "$name" ] && printf "%s  %s\n" "$checksum" "$name" | sha256sum -c - >/dev/null; then return; fi
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$name.part" "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/firefox-v159.0.1-deskbox.4/firefox/$name"
    printf "%s  %s\n" "$checksum" "$name.part" | sha256sum -c - >/dev/null
    mv -f "$name.part" "$name"
}

fetch catalog.json 3b342f2e906ac59693b518e595f2cb899af2cce43b47627df8b5970f937b1374
fetch configure.sh d9475780648826f51ee6af6e9d93849282b88b0c2b19d3d461d7dc5fe930d9e6
fetch ui.css 8903c22e4efd4c61193bffae2962f46ee05dd9882a806851807f894dc35d3ca4
deskbox-bridge progress PREPARING firefox '{}'
current=$(pkg installed firefox 2>/dev/null || true)
target=$(jq -er '.version' catalog.json)
if [ -n "$current" ] && dpkg --compare-versions "$target" lt "$current"; then
    program_fail '不自动降级已安装版本'
fi
result=$(pkg ensure firefox "$release_dir/catalog.json" install)
version=$target
program_result "$(printf '%s' "$result" | jq --arg version "$version" '. + {version:$version}')"
