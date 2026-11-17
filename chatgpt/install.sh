#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin chatgpt install
release_dir=${DESKBOX_RELEASE_DIR:?}
cd "$release_dir"
fetch() {
    name=$1 checksum=$2
    url=${3:-"https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/chatgpt-v26.1111.21308-deskbox.5/chatgpt/$name"}
    if [ -f "$name" ] && printf "%s  %s\n" "$checksum" "$name" | sha256sum -c - >/dev/null; then return; fi
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$name.part" "$url"
    printf "%s  %s\n" "$checksum" "$name.part" | sha256sum -c - >/dev/null
    mv -f "$name.part" "$name"
}

fetch catalog.json 50c0e3148afe6182a21cd16bd468666cb63bfb54eb21e3f596f82bfe806ae501
fetch configure.sh feb585918b2c252f5057642f42884d6188b7ab83aa2229c2a7894cddcff9545f
fetch backend.sh 585fb17347c0358d8fa1dd5ed26a86b3492c803bfd825ab3e56832e50a48fe3c
chmod 700 backend.sh
fetch resolve-shared-tools.sh de83f5aedb64cbee498f45c27703b1536b3a08e3076b01b8df91e3e262b181de "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/shared-tools-v1/common/resolve-shared-tools.sh"
resolver="$release_dir/resolve-shared-tools.sh"
deskbox-bridge progress PREPARING chatgpt '{}'
current=$(pkg catalog chatgpt | jq -r '.version // empty' 2>/dev/null || true)
target=$(jq -er '.version' catalog.json)
if [ -n "$current" ] && dpkg --compare-versions "$target" lt "$current"; then
    program_fail '不自动降级已安装版本'
fi
result=$(pkg ensure chatgpt "$release_dir/catalog.json" repair "$resolver")
version=$target
program_result "$(printf '%s' "$result" | jq --arg version "$version" '. + {version:$version}')"
