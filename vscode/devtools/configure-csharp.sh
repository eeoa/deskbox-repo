#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_LIB_DIR:?}/profile.sh"
dotnet="$HOME/.local/bin/dotnet"
[ -f "$dotnet" ] || { printf '%s\n' 'Run install-dotnet.sh first.' >&2; exit 1; }
settings="$HOME/.config/deskbox/vscode/user-data/User/settings.json"
mkdir -p "${settings%/*}"
[ -f "$settings" ] || printf '{}\n' > "$settings"
temporary=$(mktemp "${settings%/*}/.csharp.XXXXXX")
trap 'rm -f "$temporary"' 0
jq --arg dotnet "$dotnet" '. + {"dotnetAcquisitionExtension.existingDotnetPath":
    ((."dotnetAcquisitionExtension.existingDotnetPath" // [] | map(select(.extensionId != "ms-dotnettools.csharp")))
    + [{extensionId:"ms-dotnettools.csharp",path:$dotnet}])}' "$settings" > "$temporary"
mv "$temporary" "$settings"
printf '%s\n' 'Reload VS Code to let the C# extension use the installed SDK.'
