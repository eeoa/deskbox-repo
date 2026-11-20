#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
: "${DESKBOX_EXEC_ACTIVE:?Desk Box common process environment is required}"
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
gnu_root="$PREFIX/gnu/root"
openra_root="$gnu_root/usr/lib/openra"
profile="$HOME/.config/openra"
mkdir -p "$profile"
export ENGINE_DIR="$openra_root"
export SDL_VIDEODRIVER=x11
export XLOCALEDIR="$gnu_root/usr/share/X11/locale"
export OPENRA_DISPLAY_SCALE="${DESKBOX_SCALE:-1}"
export ALSOFT_DRIVERS=pulse
if [ "${DESKBOX_GRAPHICS:-llvmpipe}" = kgsl ]; then
    mesa_lib="$gnu_root/usr/lib/deskbox-mesa-kgsl/lib/aarch64-linux-gnu"
    export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$mesa_lib:$openra_root:$gnu_root/usr/lib/aarch64-linux-gnu/pulseaudio${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
    export LIBGL_DRIVERS_PATH="$mesa_lib/dri"
    export GALLIUM_DRIVER=freedreno MESA_LOADER_DRIVER_OVERRIDE=kgsl
    export SDL_VIDEO_X11_FORCE_EGL=1 vblank_mode=0
    unset LIBGL_ALWAYS_SOFTWARE LIBGL_DRI3_DISABLE
else
    export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$openra_root:$gnu_root/usr/lib/aarch64-linux-gnu/pulseaudio${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
    export LIBGL_DRIVERS_PATH="$gnu_root/usr/lib/aarch64-linux-gnu/dri"
    export LIBGL_ALWAYS_SOFTWARE=1 MESA_LOADER_DRIVER_OVERRIDE=swrast
    export LIBGL_DRI3_DISABLE=1 GALLIUM_DRIVER=llvmpipe
fi
ui_scale="${DESKBOX_FONT_FACTOR:-1}"
