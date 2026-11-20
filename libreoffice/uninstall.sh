#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin libreoffice uninstall
result=$(pkg uninstall libreoffice)
program_result "$result"
