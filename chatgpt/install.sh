#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin chatgpt install
release_dir=${DESKBOX_RELEASE_DIR:?}
cd "$release_dir"
fetch() {
    name=$1 checksum=$2
    if [ -f "$name" ] && printf "%s  %s\n" "$checksum" "$name" | sha256sum -c - >/dev/null; then return; fi
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$name.part" "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/chatgpt-v26.1111.21308-deskbox.1/chatgpt/$name"
    printf "%s  %s\n" "$checksum" "$name.part" | sha256sum -c - >/dev/null
    mv -f "$name.part" "$name"
}

fetch catalog.json 6d2407a65e3d22fb819b7356a14aea0ad8d807561ec2c83d317227ebef0f9c31
fetch configure.sh feb585918b2c252f5057642f42884d6188b7ab83aa2229c2a7894cddcff9545f
fetch backend.sh 585fb17347c0358d8fa1dd5ed26a86b3492c803bfd825ab3e56832e50a48fe3c
chmod 700 backend.sh
deskbox-bridge progress PREPARING chatgpt '{}'
current=$(pkg catalog chatgpt | jq -r '.version // empty' 2>/dev/null || true)
target=$(jq -er '.version' catalog.json)
if [ -n "$current" ] && dpkg --compare-versions "$target" lt "$current"; then
    program_fail '不自动降级已安装版本'
fi
jq --arg release "${DESKBOX_RELEASE_NAME:?}" '. + {deskboxRelease:$release}' catalog.json > install-catalog.json.part
mv -f install-catalog.json.part install-catalog.json
result=$(pkg ensure chatgpt "$release_dir/install-catalog.json" repair)
version=$target
program_result "$(printf '%s' "$result" | jq --arg version "$version" '. + {version:$version}')"
