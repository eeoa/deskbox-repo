#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box 以启用公共进程启动环境}"
# Static metadata resource. Android's app UID boundary remains in
# effect; the Linux-only Codex filesystem sandbox is disabled for this program.
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
gnu_exec "$PREFIX/gnu/root/usr/lib/chatgpt/resources/codex" \
    -c 'sandbox_mode="danger-full-access"' "$@"
