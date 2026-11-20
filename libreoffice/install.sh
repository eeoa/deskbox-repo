#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin libreoffice install
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
release_dir=${DESKBOX_RELEASE_DIR:?}
catalog="$release_dir/catalog.json"
checksum=13f8f7956c324442a4515ecfe0a8a68c7de79d7e6c348a063c596d94cc7899d8
if ! printf '%s  %s\n' "$checksum" "$catalog" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$catalog.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/libreoffice-v25.2.3-deskbox.4/libreoffice/catalog.json"
    printf '%s  %s\n' "$checksum" "$catalog.part" | sha256sum -c - >/dev/null
    mv -f "$catalog.part" "$catalog"
fi
configure="$release_dir/configure.sh"
configure_checksum=1b1bd70fdcf031892a3187b338f8aa26aee700957b15c66142349c3229fe83b0
if ! printf '%s  %s\n' "$configure_checksum" "$configure" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$configure.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/libreoffice-v25.2.3-deskbox.4/libreoffice/configure.sh"
    printf '%s  %s\n' "$configure_checksum" "$configure.part" | sha256sum -c - >/dev/null
    mv -f "$configure.part" "$configure"
fi
deskbox-bridge progress PREPARING libreoffice '{}'
result=$(pkg ensure libreoffice "$catalog" repair)
program_result "$result"
