#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
[ -s "$data/baseq2/pak0.pak" ] || { printf '%s\n' '缺少 Quake II 数据，请在首页管理中执行检查 / 修复。' >&2; exit 1; }
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
cd "$engine"
gnu_exec "$engine/quake2" -datadir "$data" \
    +set vid_renderer gl3 +set vid_fullscreen 2 +set r_mode -2 +set vid_highdpiaware 0 \
    +set vid_maxfps 60 +set cl_async 1 +set cl_maxfps -1 +set busywait 0 +set r_vsync 0 \
    +set r_menuscale "$ui_scale" +set r_hudscale "$ui_scale" +set r_consolescale "$ui_scale" \
    +set crosshair_scale "$ui_scale" +set s_openal 1
