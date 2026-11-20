#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
. "$DESKBOX_LIB_DIR/lib/gnu-desktop.sh"
deskbox_gnu_desktop
gnu_root="$PREFIX/gnu/root"
key=$({ printf 'gimp-environment-v2\n'; readlink -f "$gnu_root/usr/bin/gimp-3.0"; } | sha256sum | cut -d ' ' -f 1)
view="$HOME/.cache/deskbox/gimp/$key"
if [ ! -f "$view/.ready" ]; then
    mkdir -p "$view/interpreters"
    # Use GIMP's standard interpreter registry for the GNU Python plug-in ABI.
    # The shared package payloads and upstream Python plug-ins remain unchanged.
    printf 'python3=%s/usr/bin/python3.13\n' "$gnu_root" > "$view/interpreters/python.interp"
    cat "$gnu_root/etc/gimp/3.0/gimprc" > "$view/gimprc"
    printf '\n(interpreter-path "${gimp_dir}/interpreters:%s/interpreters:${gimp_plug_in_dir}/interpreters")\n' "$view" >> "$view/gimprc"
    printf '%s\n' '<?xml version="1.0"?><fontconfig>' \
        "<include>$gnu_root/etc/fonts/fonts.conf</include>" \
        "<dir>$gnu_root/usr/share/fonts</dir><dir>$PREFIX/share/fonts</dir>" \
        '<dir>/system/fonts</dir></fontconfig>' > "$view/fonts.conf"
    touch "$view/.ready"
fi
export GIMP3_DIRECTORY="$HOME/.config/GIMP/3.0"
export GIMP3_CACHEDIR="$HOME/.cache/GIMP/3.0"
export GIMP3_TEMPDIR="${DESKBOX_GNU_TMPDIR:-$TMPDIR}"
export GIMP3_DATADIR="$gnu_root/usr/share/gimp/3.0"
export GIMP3_LOCALEDIR="$gnu_root/usr/share/locale"
export GIMP3_SYSCONFDIR="$gnu_root/etc/gimp/3.0"
export GIMP3_PLUGINDIR="$gnu_root/usr/lib/aarch64-linux-gnu/gimp/3.0"
export GEGL_PATH="$gnu_root/usr/lib/aarch64-linux-gnu/gegl-0.4"
export BABL_PATH="$gnu_root/usr/lib/aarch64-linux-gnu/babl-0.1"
export GEGL_USE_OPENCL=no
# Debian alternatives keep these ABI-compatible providers in subdirectories.
export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$gnu_root/usr/lib/aarch64-linux-gnu/blas:$gnu_root/usr/lib/aarch64-linux-gnu/lapack${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
export GI_TYPELIB_PATH="$gnu_root/usr/lib/aarch64-linux-gnu/girepository-1.0"
export PYTHONHOME="$gnu_root/usr"
export PYTHONPATH="$gnu_root/usr/lib/python3/dist-packages"
# GNU helpers share their normal ABI and namespace. Common installed tools stay
# available through the rest of the platform PATH, without a per-caller list.
export PATH="$gnu_root/usr/bin:$PATH"
export FONTCONFIG_FILE="$view/fonts.conf"
export FONTCONFIG_PATH="$gnu_root/etc/fonts"
# GTK 3 scales widgets separately from the Xft font DPI supplied by the host.
widget_scale=$(awk -v scale="${DESKBOX_SCALE:-1}" 'BEGIN {n=int(scale+0.5);print n<1?1:n}')
font_scale=$(awk -v factor="${DESKBOX_FONT_FACTOR:-1}" -v widgets="$widget_scale" 'BEGIN {printf "%.4f",factor/widgets}')
export GDK_SCALE="$widget_scale" GDK_DPI_SCALE="$font_scale"
mkdir -p "$GIMP3_DIRECTORY" "$GIMP3_CACHEDIR"
