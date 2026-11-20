#!/data/data/dev.deskbox.app/files/usr/bin/sh
# Select the upstream JavaScript locator instead of experimental native PET.
set -eu
. "${DESKBOX_LIB_DIR:?}/profile.sh"
settings="$HOME/.config/deskbox/vscode/user-data/User/settings.json"
mkdir -p "${settings%/*}"
[ -f "$settings" ] || printf '{}\n' > "$settings"
temporary=$(mktemp "${settings%/*}/.python.XXXXXX")
trap 'rm -f "$temporary"' 0
jq '. + {"python.useEnvironmentsExtension":false,"python.locator":"js","python.experiments.enabled":false}' \
    "$settings" > "$temporary"
mv "$temporary" "$settings"
printf '%s\n' 'Reload VS Code to use the JavaScript Python environment locator.'
