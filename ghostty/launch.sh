#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
exec "$PREFIX/bin/ghostty" --config-default-files=false --config-file="$DESKBOX_TERMINAL_CONFIG"
