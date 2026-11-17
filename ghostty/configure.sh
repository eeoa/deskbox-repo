#!/data/data/dev.deskbox.app/files/usr/bin/sh
# GTK/Ghostty mapping of the common display contract; no Android calls.
config=$HOME/.config/deskbox/terminal/config.ghostty
mkdir -p "$(dirname "$config")"
widget_scale=$(awk -v scale="$DESKBOX_SCALE" 'BEGIN {n=int(scale+0.5);print n<1?1:n}')
points=$(awk -v factor="$DESKBOX_FONT_FACTOR" -v widgets="$widget_scale" 'BEGIN {printf "%.3f",10.5*factor/widgets}')
font=$(awk -v factor="$DESKBOX_FONT_FACTOR" -v widgets="$widget_scale" 'BEGIN {printf "%.2f",10.5*factor/widgets}')
css=$(dirname "$config")/gtk.css
printf '%s\n' "* { font-size: ${points}pt; } headerbar .title, headerbar .subtitle { font-size: ${points}pt; } headerbar button { min-width: 36px; min-height: 36px; padding: 2px; }" > "$css"
cat > "$config" <<CONFIG
font-family = JetBrains Mono
font-size = $font
background = #18212f
foreground = #e5edf8
cursor-color = #b8d9ff
selection-background = #35577e
selection-foreground = #ffffff
window-theme = dark
window-padding-x = 12
window-padding-y = 8
window-decoration = auto
window-inherit-working-directory = true
window-save-state = never
maximize = true
gtk-titlebar = true
gtk-titlebar-hide-when-maximized = $DESKBOX_PHONE_LAYOUT
gtk-custom-css = $css
gtk-single-instance = false
linux-cgroup = never
quit-after-last-window-closed = true
undo-timeout = 0
shell-integration = none
term = xterm-ghostty
clipboard-read = ask
clipboard-write = allow
clipboard-paste-protection = true
confirm-close-surface = true
command = ${terminal_command:-$DESKBOX_FILES_DIR/usr/bin/deskbox-shell}
working-directory = $HOME
CONFIG
state=$DESKBOX_SESSION_STATE/display.json
jq --argjson font "$font" '. + {fontPoints:$font,chromeRenderer:"cairo",terminalRenderer:"OpenGL; actual device verified separately"}' "$state" > "$state.new"; mv "$state.new" "$state"
export GDK_SCALE="$widget_scale" GDK_DPI_SCALE=1 GSK_RENDERER=cairo
export TERM=xterm-ghostty DESKBOX_TERM=xterm-ghostty TERMINFO="$PREFIX/share/terminfo" TERMINFO_DIRS="$PREFIX/share/terminfo" COLORTERM=truecolor
export DESKBOX_TERMINAL_CONFIG="$config"
