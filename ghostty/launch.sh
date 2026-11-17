#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
set -- --config-default-files=false --config-file="$DESKBOX_TERMINAL_CONFIG"
if [ "${DESKBOX_GRAPHICS:-}" = kgsl ]; then
    # Avoid corrupt frames when Ghostty reads back from Freedreno on KGSL.
    # Pass the session's graphics environment to commands in the terminal.
    set -- "$@" \
        --env="GALLIUM_DRIVER=$GALLIUM_DRIVER" \
        --env="MESA_LOADER_DRIVER_OVERRIDE=$MESA_LOADER_DRIVER_OVERRIDE" \
        --env="LIBGL_ALWAYS_SOFTWARE=${LIBGL_ALWAYS_SOFTWARE:-0}"
    export GALLIUM_DRIVER=llvmpipe MESA_LOADER_DRIVER_OVERRIDE=swrast LIBGL_ALWAYS_SOFTWARE=1
fi
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
exec "$PREFIX/bin/ghostty" "$@"
