#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin quake2 uninstall
result=$(pkg uninstall quake2)
program_result "$result"
