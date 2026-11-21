#!/data/data/dev.deskbox.app/files/usr/bin/sh
# Firefox's Linux configuration only. Android capabilities arrive in common env.
profile=$HOME/.config/deskbox/firefox
mkdir -p "$profile/chrome"
if [ ! -f "$profile/.deskbox-profile-id" ]; then printf '%s\n' "$DESKBOX_GENERATION" > "$profile/.deskbox-profile-id"; fi
if [ ! -f "$profile/user.js" ]; then
    cat > "$profile/user.js" <<PREFS
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("deskbox.profile.id", "$(cat "$profile/.deskbox-profile-id")");
PREFS
fi
accelerated=false; software=true; video=false
canvas=true
case "$DESKBOX_GRAPHICS" in kgsl|android) accelerated=true; software=false ;; esac
if [ "$DESKBOX_GRAPHICS" = android ]; then
    # GPU readback of a full desktop is slower than SW WebRender on this bridge.
    # Keep WebGL on the real GPU while compositing and Canvas2D use the fast CPU path.
    accelerated=false; software=true; canvas=false
fi
if [ "${DESKBOX_VIDEO_ACTIVE:-0}" = 1 ]; then video=true; fi
font_size=$(awk -v factor="$DESKBOX_FONT_FACTOR" 'BEGIN {print int(14*factor+0.5)}')
font_css=$(awk -v factor="$DESKBOX_FONT_FACTOR" 'BEGIN {printf "%.2f",14*factor}')
port=${DESKBOX_AUTOMATION_PORT:-0}
# Replace only our complete marked block, preserving user preferences around it.
jq -Rs -j 'gsub("(?s)// BEGIN DESKBOX DISPLAY.*?// END DESKBOX DISPLAY\\n?";"")' "$profile/user.js" > "$profile/user.js.new"
cat >> "$profile/user.js.new" <<PREFS

// BEGIN DESKBOX DISPLAY
user_pref("layout.css.devPixelsPerPx", "1.0");
user_pref("layers.acceleration.force-enabled", $accelerated);
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.software", $software);
user_pref("gfx.canvas.accelerated", $canvas);
user_pref("media.ffmpeg.vaapi.enabled", $video);
user_pref("media.hardware-video-decoding.enabled", $video);
user_pref("media.hardware-video-decoding.force-enabled", $video);
user_pref("widget.dmabuf.force-enabled", $video);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("font.size.variable.x-western", $font_size);
user_pref("font.size.variable.zh-CN", $font_size);
user_pref("marionette.port", $port);
user_pref("marionette.host", "127.0.0.1");
// END DESKBOX DISPLAY
PREFS
mv "$profile/user.js.new" "$profile/user.js"
css=$profile/chrome/userChrome.css
if [ -f "$css" ]; then jq -Rs -j 'gsub("(?s)/\\* BEGIN DESKBOX UI \\*/.*?/\\* END DESKBOX UI \\*/\\n?";"")' "$css" > "$css.new"; else : > "$css.new"; fi
sed "s/14px/${font_css}px/g" "${DESKBOX_RELEASE_DIR:?}/ui.css" >> "$css.new"
mv "$css.new" "$css"
state=$DESKBOX_SESSION_STATE/display.json
jq --argjson port "$port" --argjson font "$font_css" '. + {automationPort:$port,fontCss:$font}' "$state" > "$state.new"; mv "$state.new" "$state"
export LD_LIBRARY_PATH="$PREFIX/lib/firefox:$PREFIX/lib"
export MOZ_ENABLE_WAYLAND=0
if [ "$DESKBOX_GRAPHICS" = android ]; then
    export MOZ_X11_EGL=1 GALLIUM_DRIVER=virpipe MESA_LOADER_DRIVER_OVERRIDE=swrast LIBGL_DRI3_DISABLE=1
    unset LIBGL_ALWAYS_SOFTWARE
fi
export DESKBOX_FIREFOX_PROFILE="$profile"
export DESKBOX_START_URL=about:home
if [ "${DESKBOX_AUTOMATION:-0}" = 1 ]; then export MOZ_REMOTE_ALLOW_SYSTEM_ACCESS=1; fi
if [ "$video" = true ]; then
    export MOZ_DRM_DEVICE=/dev/kgsl-3d0 MOZ_FAKE_NO_SANDBOX=1
    if [ "${DESKBOX_AUTOMATION:-0}" = 1 ]; then export MOZ_LOG='PlatformDecoderModule:5,FFmpegVideo:5,DMABuf:5' MOZ_LOG_FILE="$DESKBOX_SESSION_STATE/gecko-video.log"; fi
fi
