#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin firefox uninstall
PROGRAM_ERROR='Firefox 卸载失败，请查看卸载日志'
result=$(pkg uninstall firefox)
program_result "$result"
