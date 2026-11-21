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
render_width=0
render_height=0
if [ "${DESKBOX_GRAPHICS:-llvmpipe}" = kgsl ]; then
    mesa_lib="$gnu_root/usr/lib/deskbox-mesa-kgsl/lib/aarch64-linux-gnu"
    export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$mesa_lib:$openra_root:$gnu_root/usr/lib/aarch64-linux-gnu/pulseaudio${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
    export LIBGL_DRIVERS_PATH="$mesa_lib/dri"
    export GALLIUM_DRIVER=freedreno MESA_LOADER_DRIVER_OVERRIDE=kgsl
    export SDL_VIDEO_X11_FORCE_EGL=1 vblank_mode=0
    unset LIBGL_ALWAYS_SOFTWARE LIBGL_DRI3_DISABLE
elif [ "${DESKBOX_GNU_GRAPHICS:-software}" = venus-dri3 ]; then
    export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$openra_root:$gnu_root/usr/lib/aarch64-linux-gnu/pulseaudio${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
    gnu_graphics
    # Bound pixel work for sustained GPU performance on external 4K displays.
    render_width=1920
    render_height=1080
else
    export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$openra_root:$gnu_root/usr/lib/aarch64-linux-gnu/pulseaudio${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
    export LIBGL_DRIVERS_PATH="$gnu_root/usr/lib/aarch64-linux-gnu/dri"
    export LIBGL_ALWAYS_SOFTWARE=1 MESA_LOADER_DRIVER_OVERRIDE=swrast
    export LIBGL_DRI3_DISABLE=1 GALLIUM_DRIVER=llvmpipe
    export LP_NUM_THREADS=4
    render_width=1280
    render_height=720
fi
# Request the final Android viewport before SDL reads its desktop size. This
# engine version retains that initial size for the lifetime of its window.
jq -n --arg generation "$DESKBOX_GENERATION" --argjson width "$render_width" --argjson height "$render_height" \
    '{generation:$generation,fullscreen:true,maxWidth:$width,maxHeight:$height}' > "$DESKBOX_SESSION_STATE/rendering-policy.json.part"
mv "$DESKBOX_SESSION_STATE/rendering-policy.json.part" "$DESKBOX_SESSION_STATE/rendering-policy.json"
count=0
stable=0
previous_size=
render_scale=1
while [ "$count" -lt 60 ]; do
    state=$(jq -er --arg generation "$DESKBOX_GENERATION" \
        'select(.generation == $generation and .fullscreen == true) | select(.scale >= 1 and .scale <= 3) | "\(.width) \(.height) \(.scale)"' \
        "$DESKBOX_SESSION_STATE/rendering-state.json" 2>/dev/null) || state=
    if [ -n "$state" ] && [ "$state" = "$previous_size" ]; then
        stable=$((stable + 1))
        if [ "$stable" -ge 3 ]; then render_scale=${state##* }; break; fi
    else
        stable=0
    fi
    previous_size=$state
    count=$((count + 1)); sleep 0.1
done
export OPENRA_DISPLAY_SCALE=$(awk -v scale="$OPENRA_DISPLAY_SCALE" -v render="$render_scale" \
    'BEGIN {value=scale/render; printf "%.3f",value<1?1:value}')
ui_scale="${DESKBOX_FONT_FACTOR:-1}"
