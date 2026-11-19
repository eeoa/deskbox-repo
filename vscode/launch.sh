#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
. "$DESKBOX_LIB_DIR/lib/gnu-desktop.sh"

profile="$HOME/.config/deskbox/vscode"
mkdir -p "$profile/user-data" "$profile/extensions"
if command -v deskbox_bionic_commands >/dev/null 2>&1; then
    deskbox_bionic_commands "$profile/bionic-commands" "$PREFIX/bin/git" "$PREFIX/bin/gh"
    if [ -f "$profile/bionic-commands/targets/gh" ]; then
        export GH_PATH="$profile/bionic-commands/bin/gh"
    fi
fi
export FONTCONFIG_FILE="$HOME/.config/fontconfig/fonts.conf"
deskbox_gnu_desktop
scale=$(awk -v display="$DESKBOX_SCALE" -v font="$DESKBOX_FONT_FACTOR" 'BEGIN {printf "%.6f",display*font}')

printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
# The Android app UID provides isolation. Linux namespaces and the setuid helper are unavailable.
gnu_exec "$PREFIX/gnu/root/usr/share/code/code" --ozone-platform=x11 \
    --force-device-scale-factor="$scale" --disable-dev-shm-usage --disable-gpu --no-sandbox \
    --disable-updates --user-data-dir="$profile/user-data" --extensions-dir="$profile/extensions"
