#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
gnu_exec "$gnu_root/usr/bin/gimp-3.0" --new-instance --no-splash --no-shm --system-gimprc "$view/gimprc"
