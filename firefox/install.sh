#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin firefox install
release_dir=${DESKBOX_RELEASE_DIR:?}
cd "$release_dir"
fetch() {
    name=$1 checksum=$2
    if [ -f "$name" ] && printf "%s  %s\n" "$checksum" "$name" | sha256sum -c - >/dev/null; then return; fi
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$name.part" "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/firefox-v159.0.1-deskbox.3/firefox/$name"
    printf "%s  %s\n" "$checksum" "$name.part" | sha256sum -c - >/dev/null
    mv -f "$name.part" "$name"
}

fetch catalog.json 29b00e1f2afc6af35628e620c1d356ab5847cda3a820d0bb2bdd478926454be0
fetch configure.sh 4c68dab632e267ea0dd4ecae6025854e2fc898214047f1558e3b71658eaf53c6
fetch ui.css 8903c22e4efd4c61193bffae2962f46ee05dd9882a806851807f894dc35d3ca4
deskbox-bridge progress PREPARING firefox '{}'
current=$(pkg installed firefox 2>/dev/null || true)
target=$(jq -er '.version' catalog.json)
if [ -n "$current" ] && dpkg --compare-versions "$target" lt "$current"; then
    program_fail '不自动降级已安装版本'
fi
result=$(pkg ensure firefox "$release_dir/catalog.json" repair)
version=$target
program_result "$(printf '%s' "$result" | jq --arg version "$version" '. + {version:$version}')"
