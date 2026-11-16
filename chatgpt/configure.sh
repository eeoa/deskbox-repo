#!/data/data/dev.deskbox.app/files/usr/bin/sh
profile=$HOME/.config/deskbox/chatgpt
export DESKBOX_ELECTRON_SCALE=$(awk -v dpi="$DESKBOX_SCALE" -v font="$DESKBOX_FONT_FACTOR" 'BEGIN {printf "%.6f",dpi*font}')
mkdir -p "$profile/config" "$profile/cache" "$profile/codex" "$TMPDIR"
export XDG_CONFIG_HOME="$profile/config" XDG_CACHE_HOME="$profile/cache" CODEX_HOME="$profile/codex"
. "$DESKBOX_LIB_DIR/lib/resources.sh"
CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH=$(deskbox_resource_tree "$PREFIX/gnu/root/usr/lib/chatgpt/resources" plugins)
export CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH
. "$DESKBOX_LIB_DIR/lib/gnu-desktop.sh"
deskbox_gnu_desktop
export CODEX_CLI_PATH="${DESKBOX_RELEASE_DIR:?}/backend.sh"
export FONTCONFIG_FILE="$TMPDIR/fonts.conf" FONTCONFIG_PATH="$TMPDIR"
cat > "$FONTCONFIG_FILE" <<EOF
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd"><fontconfig><dir>/system/fonts</dir><dir>$PREFIX/share/fonts</dir><cachedir>$profile/cache/fontconfig</cachedir></fontconfig>
EOF
