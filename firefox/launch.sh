#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
# Program and libraries come from the shared, independently relocated package view.
# The exec adapter wraps private ELF execution through Android's system linker.
echo "$$" > "$DESKBOX_CLIENT_PID_FILE"
if [ "${DESKBOX_AUTOMATION:-0}" = 1 ]; then
    # Debug APK only; loopback and an ephemeral port from this launch's private profile.
    exec "$PREFIX/lib/firefox/firefox" --marionette --no-remote --new-instance --profile "$DESKBOX_FIREFOX_PROFILE" "$DESKBOX_START_URL"
fi
exec "$PREFIX/lib/firefox/firefox" --no-remote --new-instance --profile "$DESKBOX_FIREFOX_PROFILE" "$DESKBOX_START_URL"
