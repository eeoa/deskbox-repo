#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin openra install
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
release_dir=${DESKBOX_RELEASE_DIR:?}
catalog="$release_dir/catalog.json"
checksum=303baa64b6bd44c4bc87f49fddc538b38e610d46763159fed7e49d3d017addff
if ! printf '%s  %s\n' "$checksum" "$catalog" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$catalog.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/openra-v20261026-playtest-deskbox.8/openra/catalog.json"
    printf '%s  %s\n' "$checksum" "$catalog.part" | sha256sum -c - >/dev/null
    mv -f "$catalog.part" "$catalog"
fi
configure="$release_dir/configure.sh"
configure_checksum=44f4abd4dc79a049385d7abd03d2f69b36c3f252014d1474e9663fd23c80f999
if ! printf '%s  %s\n' "$configure_checksum" "$configure" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$configure.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/openra-v20261026-playtest-deskbox.8/openra/configure.sh"
    printf '%s  %s\n' "$configure_checksum" "$configure.part" | sha256sum -c - >/dev/null
    mv -f "$configure.part" "$configure"
fi
deskbox-bridge progress PREPARING openra '{}'
result=$(pkg ensure openra "$catalog" install)
program_result "$result"
