#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin terminal uninstall
PROGRAM_ERROR='Ghostty 卸载失败，请查看卸载日志'
result=$(pkg uninstall terminal)
program_result "$result"
