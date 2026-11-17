#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
set --
terminal_command="$DESKBOX_FILES_DIR/usr/bin/deskbox-shell"
if [ "${DESKBOX_GRAPHICS:-}" = kgsl ]; then
    set -- \
        --env="GALLIUM_DRIVER=$GALLIUM_DRIVER" \
        --env="MESA_LOADER_DRIVER_OVERRIDE=$MESA_LOADER_DRIVER_OVERRIDE" \
        --env="LIBGL_ALWAYS_SOFTWARE=${LIBGL_ALWAYS_SOFTWARE:-0}"
    driver_dir="$DESKBOX_RELEASE_DIR/turnip"
    if [ -r "$driver_dir/vulkan/icd.d/freedreno_icd.aarch64.json" ] &&
        [ -r "$driver_dir/libvulkan_freedreno.so" ]; then
        # Use the same isolated Turnip device for all Zink contexts.
        export VK_DRIVER_FILES="$driver_dir/vulkan/icd.d/freedreno_icd.aarch64.json" TU_DEBUG=noconform
        export GALLIUM_DRIVER=zink MESA_LOADER_DRIVER_OVERRIDE=zink
        # Keep the video bridge's KGSL export modes available to commands in the terminal.
        for name in FD_KGSL_ENABLE_DMABUF TERMUX_VA_BRIDGE TERMUX_VA_GPU_BACKEND TERMUX_VA_X11_DRI3; do
            value=$(printenv "$name") || continue
            set -- "$@" "--env=$name=$value"
            unset "$name"
        done
        terminal_command="shell:unset VK_DRIVER_FILES TU_DEBUG; exec $terminal_command"
    else
        export GALLIUM_DRIVER=llvmpipe MESA_LOADER_DRIVER_OVERRIDE=swrast LIBGL_ALWAYS_SOFTWARE=1
    fi
fi
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
exec "$PREFIX/bin/ghostty" --config-default-files=false --config-file="$DESKBOX_TERMINAL_CONFIG" "$@"
