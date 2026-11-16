#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
# Static metadata resource. Android's app UID boundary remains in
# effect; the Linux-only Codex filesystem sandbox is disabled for this program.
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
deskbox_bionic_shell "${XDG_CACHE_HOME:?}/shell" "$PREFIX/bin/bash"
deskbox_gnu_static_bundle "${XDG_CACHE_HOME:?}/backend" \
    "$PREFIX/gnu/root/usr/lib/chatgpt/resources/codex" \
    "$PREFIX/gnu/root/usr/lib/chatgpt/resources/codex-code-mode-host"
core=$(readlink -f "$PREFIX/gnu/root/usr/lib/chatgpt/resources/codex")
exec "${DESKBOX_NATIVE_GNU_LAUNCH:?}" --launch "$core" \
    -c 'sandbox_mode="danger-full-access"' "$@"
