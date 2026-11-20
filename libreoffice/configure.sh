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
key=$({ printf 'libreoffice-view-v5\n'; readlink -f "$office/share/.registry/main.xcd"; } | sha256sum | cut -d ' ' -f 1)
view="$HOME/.cache/deskbox/libreoffice/$key"
if [ ! -f "$view/.ready" ] || ! cmp -s "$office/program/soffice.bin" "$view/program/soffice.bin"; then
    mkdir -p "$view/program" "$view/share/registry" "$view/share/psprint" "$view/share/prereg/bundled" "$view/share/uno_packages/cache"
    # Relative dlopen calls are anchored beside libmergedlo. Give the app one
    # actual program directory across Debian's split package payloads. Only the
    # tiny upstream executable is copied byte-for-byte; libraries remain links.
    cp -Rsf --no-preserve=mode "$office/program/." "$view/program/"
    cp -L "$office/program/soffice.bin" "$view/program/soffice.bin.part"
    chmod u+rx,u-w "$view/program/soffice.bin.part"
    cmp -s "$office/program/soffice.bin" "$view/program/soffice.bin.part"
    mv -f "$view/program/soffice.bin.part" "$view/program/soffice.bin"
    for resource in "$office/"*; do
        name=$(basename "$resource")
        case "$name" in program|share|presets) continue;; esac
        ln -sfn "$resource" "$view/$name"
    done
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
    sed "s|file:///usr/share/|file://$PREFIX/gnu/root/usr/share/|g" \
        "$office/share/.registry/main.xcd" > "$view/share/registry/main.xcd"
    ln -sfn "$PREFIX/gnu/root/etc/libreoffice/psprint.conf" "$view/share/psprint/psprint.conf"
    ln -sfn "$PREFIX/gnu/root/usr/share/liblangtag" "$view/share/liblangtag"
    # LibreOffice's first-run copier treats a symlinked directory as a file.
    # Give it actual directories/files, retaining the immutable package source.
    cp -RL --no-preserve=mode "$office/presets" "$view/presets"
    chmod -R u+rwX "$view/presets"
    printf '%s\n' '<?xml version="1.0"?><fontconfig>' \
        "<include>$PREFIX/gnu/root/etc/fonts/fonts.conf</include>" \
        "<dir>$PREFIX/gnu/root/usr/share/fonts</dir><dir>$PREFIX/share/fonts</dir>" \
        '<dir>/system/fonts</dir></fontconfig>' > "$view/fonts.conf"
    touch "$view/.ready"
fi
export FONTCONFIG_FILE="$view/fonts.conf"
export FONTCONFIG_PATH="$PREFIX/gnu/root/etc/fonts"
export GDK_DPI_SCALE="${DESKBOX_FONT_FACTOR:-1}"
export SAL_USE_VCLPLUGIN=gtk3
export UNO_PATH="$view/program"
export URE_BOOTSTRAP="vnd.sun.star.pathname:$view/program/fundamentalrc"
export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$view/program:$PREFIX/gnu/root/usr/lib/aarch64-linux-gnu/blas:$PREFIX/gnu/root/usr/lib/aarch64-linux-gnu/lapack${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
