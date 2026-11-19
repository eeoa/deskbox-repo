#!/data/data/dev.deskbox.app/files/usr/bin/sh
# Configure LLVM's signed VS Code extension with the active Android toolchain.
set -eu
. "${DESKBOX_LIB_DIR:?}/profile.sh"
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
pkg install clang make
profile="$HOME/.config/deskbox/vscode"
mkdir -p "$profile/user-data/User" "$profile/extensions"
work=$(mktemp -d "${TMPDIR:?}/cpp.XXXXXX")
trap 'rm -rf "$work"' 0
clang++ -E -x c++ /dev/null -v >/dev/null 2> "$work/compiler.txt"
awk '/#include <.*> search starts here:/{inside=1;next} /End of search list/{inside=0} inside{sub(/^[ \t]+/,"");print}' \
    "$work/compiler.txt" > "$work/includes"
[ -s "$work/includes" ] || { printf '%s\n' 'Compiler include discovery failed' >&2; exit 1; }
target=$(clang++ -dumpmachine)
flags=$(jq -Rn --arg target "$target" '["--target="+$target] + [inputs | select(length>0) | "-isystem", .]' < "$work/includes")
settings="$profile/user-data/User/settings.json"
[ -f "$settings" ] || printf '{}\n' > "$settings"
# jq rejects unsupported JSONC syntax before replacing anything; retain other settings.
jq --arg clangd "$PREFIX/bin/clangd" --argjson flags "$flags" \
    '. + {"C_Cpp.intelliSenseEngine":"disabled", "clangd.path":(."clangd.path" // $clangd),
      "clangd.fallbackFlags":(."clangd.fallbackFlags" // $flags)}' "$settings" > "$work/settings.json"
(
    export ELECTRON_RUN_AS_NODE=1
    code="$PREFIX/gnu/root/usr/share/code"
    gnu_exec "$code/code" "$code/resources/app/out/cli.js" \
        --user-data-dir="$profile/user-data" --extensions-dir="$profile/extensions" \
        --install-extension llvm-vs-code-extensions.vscode-clangd@0.6.0 --force
)
cp "$work/settings.json" "$settings.new"
mv "$settings.new" "$settings"
printf '%s\n' 'LLVM clangd is ready. Reload VS Code to activate it.'
