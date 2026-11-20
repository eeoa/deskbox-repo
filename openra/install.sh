#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin openra install
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
release_dir=${DESKBOX_RELEASE_DIR:?}
catalog="$release_dir/catalog.json"
checksum=e61d4a3bfc7dcf5e57018a0d6465cf8830537148d54a228526c2ae061adc7c84
if ! printf '%s  %s\n' "$checksum" "$catalog" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$catalog.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/openra-v20261026-playtest-deskbox.2/openra/catalog.json"
    printf '%s  %s\n' "$checksum" "$catalog.part" | sha256sum -c - >/dev/null
    mv -f "$catalog.part" "$catalog"
fi
configure="$release_dir/configure.sh"
configure_checksum=3c9bfc385129eaf0b8c49f0554ad16641054e63122c89ee4566c9c16017470b6
if ! printf '%s  %s\n' "$configure_checksum" "$configure" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$configure.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/openra-v20261026-playtest-deskbox.2/openra/configure.sh"
    printf '%s  %s\n' "$configure_checksum" "$configure.part" | sha256sum -c - >/dev/null
    mv -f "$configure.part" "$configure"
fi
deskbox-bridge progress PREPARING openra '{}'
result=$(pkg ensure openra "$catalog" repair)
program_result "$result"
