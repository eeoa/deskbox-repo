#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
. "$DESKBOX_LIB_DIR/lib/gnu-desktop.sh"

deskbox_gnu_desktop
office="$PREFIX/gnu/root/usr/lib/libreoffice"
profile="$HOME/.config/libreoffice/4"
mkdir -p "$profile"
# Debian's registry symlink normally relies on ucf/postinst. Assemble an owned
# resource view from the original package files without executing those scripts
# or changing shared payloads. The upstream ELF files remain byte-exact.
key=$(readlink -f "$office/share/.registry/main.xcd" | sha256sum | cut -d ' ' -f 1)
view="$HOME/.cache/deskbox/libreoffice/$key"
if [ ! -f "$view/.ready" ]; then
    mkdir -p "$view/share/registry" "$view/share/psprint" "$view/share/prereg/bundled" "$view/share/uno_packages/cache"
    ln -sfn "$office/program" "$view/program"
    for resource in "$office/share/"*; do
        name=$(basename "$resource")
        case "$name" in registry|psprint|prereg|uno_packages) continue;; esac
        ln -sfn "$resource" "$view/share/$name"
    done
    for resource in "$office/share/registry/"*; do
        name=$(basename "$resource")
        [ "$name" = main.xcd ] && continue
        ln -sfn "$resource" "$view/share/registry/$name"
    done
    ln -sfn "$office/share/.registry/main.xcd" "$view/share/registry/main.xcd"
    ln -sfn "$PREFIX/gnu/root/etc/libreoffice/psprint.conf" "$view/share/psprint/psprint.conf"
    printf '%s\n' '<?xml version="1.0"?><fontconfig>' \
        "<include>$HOME/.config/fontconfig/fonts.conf</include>" \
        "<dir>$PREFIX/gnu/root/usr/share/fonts</dir></fontconfig>" > "$view/fonts.conf"
    touch "$view/.ready"
fi
export FONTCONFIG_FILE="$view/fonts.conf"
export SAL_USE_VCLPLUGIN=gtk3
export UNO_PATH="$office/program"
export URE_BOOTSTRAP="vnd.sun.star.pathname:$office/program/fundamentalrc"
export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$office/program:$PREFIX/gnu/root/usr/lib/aarch64-linux-gnu/blas:$PREFIX/gnu/root/usr/lib/aarch64-linux-gnu/lapack${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
gnu_exec "$office/program/soffice.bin" "-env:UserInstallation=file://$profile" \
    "-env:BRAND_BASE_DIR=file://$view" \
    "-env:FHS_CONFIG_FILE=file://$PREFIX/gnu/root/etc/libreoffice/sofficerc" \
    --nologo --nofirststartwizard
