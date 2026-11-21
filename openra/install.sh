#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin openra install
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
release_dir=${DESKBOX_RELEASE_DIR:?}
catalog="$release_dir/catalog.json"
checksum=432b4042c86e130ef09ea28ff2aa22ac742952d3cdb069e2c8ace8725f68bad2
if ! printf '%s  %s\n' "$checksum" "$catalog" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$catalog.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/openra-v20261026-playtest-deskbox.7/openra/catalog.json"
    printf '%s  %s\n' "$checksum" "$catalog.part" | sha256sum -c - >/dev/null
    mv -f "$catalog.part" "$catalog"
fi
configure="$release_dir/configure.sh"
configure_checksum=248f7751ac1262871a7ca4a7991091cb801ff52e49b8763bf1aca42ffdacb3d3
if ! printf '%s  %s\n' "$configure_checksum" "$configure" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$configure.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/openra-v20261026-playtest-deskbox.7/openra/configure.sh"
    printf '%s  %s\n' "$configure_checksum" "$configure.part" | sha256sum -c - >/dev/null
    mv -f "$configure.part" "$configure"
fi
deskbox-bridge progress PREPARING openra '{}'
result=$(pkg ensure openra "$catalog" install)
program_result "$result"
