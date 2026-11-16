#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin chatgpt uninstall
PROGRAM_ERROR='ChatGPT 卸载失败，请查看卸载日志'
result=$(pkg uninstall chatgpt)
program_result "$result"
