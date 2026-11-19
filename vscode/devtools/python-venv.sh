#!/data/data/dev.deskbox.app/files/usr/bin/sh
# Create an ordinary venv without depending on a wheel inside the frozen base.
set -eu
. "${DESKBOX_LIB_DIR:?}/profile.sh"
[ "$#" = 1 ] || { printf 'Usage: %s VENV_DIRECTORY\n' "$0" >&2; exit 2; }
venv=$1
python3 -m venv --without-pip "$venv"
venv=$(CDPATH= cd -- "$venv" && pwd)
cache="$HOME/.cache/deskbox/python"
mkdir -p "$cache"
wheel="$cache/pip-26.3-py3-none-any.whl"
sha=f3b60b20ffaadd4415ed7957212a38ac63fa4c5fa375bd0f4a797777940fad13
if ! printf '%s  %s\n' "$sha" "$wheel" | sha256sum -c - >/dev/null 2>&1; then
    temporary=$(mktemp "$cache/.pip.XXXXXX")
    trap 'rm -f "$temporary"' 0
    curl --proto '=https' --proto-redir '=https' --fail --location --retry 2 \
        --connect-timeout 20 --max-time 120 --output "$temporary" \
        'https://files.pythonhosted.org/packages/07/25/ee8c38ae72d66b844ce8eb9711ba905dba21ca1a8a0c960057c41cd23337/pip-26.3-py3-none-any.whl'
    printf '%s  %s\n' "$sha" "$temporary" | sha256sum -c -
    mv "$temporary" "$wheel"
    trap - 0
fi
"$venv/bin/python" - "$wheel" <<'PY'
import runpy
import sys
from pathlib import Path
wheel = str(Path(sys.argv[1]).resolve())
sys.path.insert(0, wheel)
sys.argv = ['pip', 'install', '--no-index', '--disable-pip-version-check', wheel]
runpy.run_module('pip', run_name='__main__')
PY
printf 'Activate with: . "%s/bin/activate"\n' "$venv"
