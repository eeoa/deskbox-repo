#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin vscode install
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"

release_dir=${DESKBOX_RELEASE_DIR:?}
catalog="$release_dir/catalog.json"
checksum=d2345da1fdfe7123b8c4242ba47a77b8d4a6142c90217fb8801e33c79f7408e2
if ! printf '%s  %s\n' "$checksum" "$catalog" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$catalog.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/vscode-v1.146.0-deskbox.7/vscode/catalog.json"
    printf '%s  %s\n' "$checksum" "$catalog.part" | sha256sum -c - >/dev/null
    mv -f "$catalog.part" "$catalog"
fi

resolver="$release_dir/resolve-shared-tools.sh"
resolver_checksum=de83f5aedb64cbee498f45c27703b1536b3a08e3076b01b8df91e3e262b181de
if ! printf '%s  %s\n' "$resolver_checksum" "$resolver" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$resolver.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/shared-tools-v1/common/resolve-shared-tools.sh"
    printf '%s  %s\n' "$resolver_checksum" "$resolver.part" | sha256sum -c - >/dev/null
    mv -f "$resolver.part" "$resolver"
fi

deskbox-bridge progress PREPARING vscode '{}'
current=$(pkg catalog vscode | jq -r '.version // empty' 2>/dev/null || true)
target=$(jq -er '.version' "$catalog")
if [ -n "$current" ] && dpkg --compare-versions "$target" lt "$current"; then
    program_fail '不自动降级已安装版本'
fi
result=$(pkg ensure vscode "$catalog" repair "$resolver")
program_result "$(printf '%s' "$result" | jq --arg version "$target" '. + {version:$version}')"
