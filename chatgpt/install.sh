#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin chatgpt install
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
release_dir=${DESKBOX_RELEASE_DIR:?}
cd "$release_dir"
fetch() {
    name=$1 checksum=$2
    url=${3:-"https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/chatgpt-v26.1111.21308-deskbox.6/chatgpt/$name"}
    if [ -f "$name" ] && printf "%s  %s\n" "$checksum" "$name" | sha256sum -c - >/dev/null; then return; fi
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$name.part" "$url"
    printf "%s  %s\n" "$checksum" "$name.part" | sha256sum -c - >/dev/null
    mv -f "$name.part" "$name"
}

fetch catalog.json 50c0e3148afe6182a21cd16bd468666cb63bfb54eb21e3f596f82bfe806ae501
fetch configure.sh feb585918b2c252f5057642f42884d6188b7ab83aa2229c2a7894cddcff9545f
fetch backend.sh 2885cbef96fa58845cf9c360da14d3cc12ff9e0ec8f037167e74ff3c18ff5d52
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
