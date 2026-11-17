#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin vscode uninstall
result=$(pkg uninstall vscode)
program_result "$result"
