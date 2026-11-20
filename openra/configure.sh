#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
gnu_root="$PREFIX/gnu/root"
openra_root="$gnu_root/usr/lib/openra"
profile="$HOME/.config/openra"
mkdir -p "$profile"
export ENGINE_DIR="$openra_root"
export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$openra_root${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
export SDL_VIDEODRIVER=x11
# Use the matching GNU Mesa drivers, independently of the Bionic desktop stack.
export LIBGL_DRIVERS_PATH="$gnu_root/usr/lib/aarch64-linux-gnu/dri"
export LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe MESA_LOADER_DRIVER_OVERRIDE=swrast
export LIBGL_DRI3_DISABLE=1
export ALSOFT_DRIVERS=pulse
ui_scale=$(awk -v scale="${DESKBOX_SCALE:-1}" -v factor="${DESKBOX_FONT_FACTOR:-1}" 'BEGIN {s=scale*factor;if(s<1)s=1;if(s>2.5)s=2.5;printf "%.3f",s}')
