#!/data/data/dev.deskbox.app/files/usr/bin/sh
# Download original demo data to HOME; never put copyrighted game data in a package.
set -eu
data="$HOME/Games/QuakeII"
mkdir -p "$data/baseq2"
if [ -s "$data/baseq2/pak0.pak" ]; then
    exit 0
fi
(
    stage=$(mktemp -d "$data/.demo.XXXXXX")
    trap 'rm -rf "$stage"' 0
    deskbox-bridge progress DOWNLOADING quake2 '{"package":"Quake II 试玩数据"}'
    curl --fail --location --silent --show-error --retry 2 --connect-timeout 15 --max-time 600 \
        --output "$stage/demo.zip" 'https://deponie.yamagi.org/quake2/idstuff/q2-314-demo-x86.exe'
    printf '%s  %s\n' 7ace5a43983f10d6bdc9d9b6e17a1032ba6223118d389bd170df89b945a04a1e "$stage/demo.zip" | sha256sum -c - >/dev/null
    unzip -q "$stage/demo.zip" 'Install/Data/baseq2/pak0.pak' 'Install/Data/baseq2/players/*' 'license.txt' -d "$stage/extracted"
    printf '%s  %s\n' cae257182f34d3913f3d663e1d7cf865d668feda6af393d4ecf3e9e408b48d09 \
        "$stage/extracted/Install/Data/baseq2/pak0.pak" | sha256sum -c - >/dev/null
    # Leave user-provided skins and full-game content in place.
    if [ ! -d "$data/baseq2/players" ]; then
        cp -R "$stage/extracted/Install/Data/baseq2/players" "$data/baseq2/players"
    fi
    cp "$stage/extracted/license.txt" "$data/LICENSE-demo.txt"
    mv "$stage/extracted/Install/Data/baseq2/pak0.pak" "$data/baseq2/pak0.pak"
)
