#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
set -- --config-default-files=false --config-file="$DESKBOX_TERMINAL_CONFIG"
if [ "${DESKBOX_GRAPHICS:-}" = kgsl ]; then
    set -- "$@" \
        --env="GALLIUM_DRIVER=$GALLIUM_DRIVER" \
        --env="MESA_LOADER_DRIVER_OVERRIDE=$MESA_LOADER_DRIVER_OVERRIDE" \
        --env="LIBGL_ALWAYS_SOFTWARE=${LIBGL_ALWAYS_SOFTWARE:-0}"
    driver_dir="$DESKBOX_RELEASE_DIR/turnip"
    if [ -r "$driver_dir/vulkan/icd.d/freedreno_icd.aarch64.json" ] &&
        [ -r "$driver_dir/libvulkan_freedreno.so" ]; then
        # Present through Zink on Adreno 750 to avoid the Freedreno redraw artifact.
        set -- "$@" --env="XDG_DATA_DIRS=$XDG_DATA_DIRS"
        export XDG_DATA_DIRS="$driver_dir:$XDG_DATA_DIRS" GALLIUM_DRIVER=zink MESA_LOADER_DRIVER_OVERRIDE=zink
    else
        export GALLIUM_DRIVER=llvmpipe MESA_LOADER_DRIVER_OVERRIDE=swrast LIBGL_ALWAYS_SOFTWARE=1
    fi
fi
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
exec "$PREFIX/bin/ghostty" "$@"
