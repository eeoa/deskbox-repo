#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin ghostty uninstall
PROGRAM_ERROR='Ghostty 卸载失败，请查看卸载日志'
result=$(pkg uninstall ghostty)
program_result "$result"
