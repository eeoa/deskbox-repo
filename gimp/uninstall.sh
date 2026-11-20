#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin gimp uninstall
result=$(pkg uninstall gimp)
program_result "$result"
