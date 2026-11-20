#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin openra uninstall
result=$(pkg uninstall openra)
program_result "$result"
