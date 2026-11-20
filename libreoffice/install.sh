#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin libreoffice install
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
release_dir=${DESKBOX_RELEASE_DIR:?}
catalog="$release_dir/catalog.json"
checksum=13f8f7956c324442a4515ecfe0a8a68c7de79d7e6c348a063c596d94cc7899d8
if ! printf '%s  %s\n' "$checksum" "$catalog" | sha256sum -c - >/dev/null 2>&1; then
    curl --fail --silent --show-error --connect-timeout 10 --max-time 60 --output "$catalog.part" \
        "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/libreoffice-v25.2.3-deskbox.3/libreoffice/catalog.json"
    printf '%s  %s\n' "$checksum" "$catalog.part" | sha256sum -c - >/dev/null
    mv -f "$catalog.part" "$catalog"
fi
deskbox-bridge progress PREPARING libreoffice '{}'
result=$(pkg ensure libreoffice "$catalog" repair)
program_result "$result"
