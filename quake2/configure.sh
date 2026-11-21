#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
: "${DESKBOX_EXEC_ACTIVE:?Desk Box common process environment is required}"
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
gnu_root="$PREFIX/gnu/root"
engine="$gnu_root/usr/lib/yamagi-quake2"
data="$HOME/Games/QuakeII"
# Seed only a new profile. Subsequent launches keep in-game key changes.
profile="$HOME/.yq2/baseq2"
mkdir -p "$profile"
if [ ! -e "$profile/config.cfg" ]; then
    (set -C; cat > "$profile/config.cfg" <<'CONFIG'
// Desk Box first-run defaults; subsequent changes belong to the game.
bind w "+forward"
bind a "+moveleft"
bind s "+back"
bind d "+moveright"
bind SPACE "+moveup"
bind CTRL "+movedown"
CONFIG
    ) || [ -f "$profile/config.cfg" ]
fi
export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$engine:$gnu_root/usr/lib/aarch64-linux-gnu/pulseaudio${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}"
export SDL_VIDEODRIVER=x11 SDL_AUDIODRIVER=pulseaudio ALSOFT_DRIVERS=pulse
export XLOCALEDIR="$gnu_root/usr/share/X11/locale"
render_width=1920
render_height=1080
if [ "${DESKBOX_GRAPHICS:-software}" = kgsl ]; then
    mesa_lib="$gnu_root/usr/lib/deskbox-mesa-kgsl/lib/aarch64-linux-gnu"
    export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$mesa_lib:$DESKBOX_GNU_LIBRARY_PATH_EXTRA"
    export LIBGL_DRIVERS_PATH="$mesa_lib/dri" GALLIUM_DRIVER=freedreno MESA_LOADER_DRIVER_OVERRIDE=kgsl
    export SDL_VIDEO_X11_FORCE_EGL=1
    unset LIBGL_ALWAYS_SOFTWARE LIBGL_DRI3_DISABLE
elif [ "${DESKBOX_GNU_GRAPHICS:-software}" = venus-dri3 ]; then
    gnu_graphics
else
    export LIBGL_DRIVERS_PATH="$gnu_root/usr/lib/aarch64-linux-gnu/dri"
    export LIBGL_ALWAYS_SOFTWARE=1 LIBGL_DRI3_DISABLE=1 GALLIUM_DRIVER=llvmpipe MESA_LOADER_DRIVER_OVERRIDE=swrast LP_NUM_THREADS=4
    render_width=960
    render_height=540
fi
jq -n --arg generation "$DESKBOX_GENERATION" --argjson width "$render_width" --argjson height "$render_height" \
    '{generation:$generation,fullscreen:true,maxWidth:$width,maxHeight:$height}' > "$DESKBOX_SESSION_STATE/rendering-policy.json.part"
mv "$DESKBOX_SESSION_STATE/rendering-policy.json.part" "$DESKBOX_SESSION_STATE/rendering-policy.json"
count=0
stable=0
previous=
render_scale=1
while [ "$count" -lt 60 ]; do
    state=$(jq -er --arg generation "$DESKBOX_GENERATION" \
        'select(.generation == $generation and .fullscreen == true) | select(.scale >= 1 and .scale <= 3) | "\(.width) \(.height) \(.scale)"' \
        "$DESKBOX_SESSION_STATE/rendering-state.json" 2>/dev/null) || state=
    if [ -n "$state" ] && [ "$state" = "$previous" ]; then
        stable=$((stable+1))
        if [ "$stable" -ge 3 ]; then render_scale=${state##* }; break; fi
    else
        stable=0
    fi
    previous=$state
    count=$((count+1)); sleep 0.1
 done
ui_scale=$(awk -v scale="${DESKBOX_SCALE:-1}" -v render="$render_scale" -v font="${DESKBOX_FONT_FACTOR:-1}" \
    'BEGIN {s=2*scale*font/render;printf "%.3f",s<1?1:s}')
