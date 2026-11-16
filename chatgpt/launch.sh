#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
# Linux namespaces / setuid helpers are unavailable inside an ordinary Android app.
# Electron and Codex use the user-authorized Android app isolation policy.
gnu_exec "$PREFIX/gnu/root/usr/lib/chatgpt/ChatGPT" --ozone-platform=x11 \
    --force-device-scale-factor="$DESKBOX_ELECTRON_SCALE" --disable-dev-shm-usage --disable-gpu \
    --no-sandbox --user-data-dir="$profile/browser" --enable-logging=stderr
