#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
cd "$openra_root"
gnu_exec "$openra_root/OpenRA" Game.Mod=ra "Engine.EngineDir=$openra_root"     "Engine.SupportDir=$profile" Graphics.Mode=Windowed "Graphics.UIScale=$ui_scale"
