#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_LIB_DIR:?}/profile.sh"
directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
lock="$directory/dotnet-sdk.lock.json"
version=$(jq -er '.version' "$lock")
url=$(jq -er '.url' "$lock")
sha=$(jq -er '.sha512' "$lock")
case "$version" in ''|*[!0-9.]*) exit 2;; esac
case "$url" in https://builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*-linux-arm64.tar.gz) ;; *) exit 2;; esac
case "$sha" in ''|*[!0-9a-f]*) exit 2;; esac
[ "${#sha}" = 128 ] || exit 2
base="$HOME/.local/share/deskbox/toolchains/dotnet"
root="$base/$version"
bin="$HOME/.local/bin"
mkdir -p "$base" "$bin"
if [ -e "$bin/dotnet" ] && ! grep -q '^# Desk Box dotnet launcher$' "$bin/dotnet"; then
    printf '%s\n' 'An existing user dotnet launcher was preserved.' >&2
    exit 1
fi
if [ ! -f "$root/.deskbox-sha512" ] || [ "$(cat "$root/.deskbox-sha512")" != "$sha" ]; then
    [ ! -e "$root" ] || { printf '%s\n' 'An unowned SDK directory was preserved.' >&2; exit 1; }
    temporary=$(mktemp -d "$base/.install.XXXXXX")
    trap 'rm -rf "$temporary"' 0
    curl --proto '=https' --proto-redir '=https' --fail --location --retry 2 \
        --connect-timeout 20 --max-time 900 --output "$temporary/sdk.tar.gz" "$url"
    printf '%s  %s\n' "$sha" "$temporary/sdk.tar.gz" | sha512sum -c -
    mkdir "$temporary/sdk"
    tar -xzf "$temporary/sdk.tar.gz" -C "$temporary/sdk"
    printf '%s\n' "$sha" > "$temporary/sdk/.deskbox-sha512"
    mv "$temporary/sdk" "$root"
    rm -rf "$temporary"
    trap - 0
fi
mkdir -p "$root/native"
jq -r '.nativePackages[] | [.name,.sha256,.url] | @tsv' "$lock" > "$root/native/packages.tsv"
while IFS="$(printf '\t')" read -r name native_sha native_url; do
    case "$name" in ''|*[!a-z0-9+.-]*) exit 2;; esac
    case "$native_url" in https://deb.debian.org/debian/pool/*) ;; *) exit 2;; esac
    case "$native_sha" in ''|*[!0-9a-f]*) exit 2;; esac
    [ "${#native_sha}" = 64 ] || exit 2
    receipt="$root/native/.$name.sha256"
    if [ ! -f "$receipt" ] || [ "$(cat "$receipt")" != "$native_sha" ]; then
        temporary=$(mktemp -d "$base/.native.XXXXXX")
        trap 'rm -rf "$temporary"' 0
        curl --proto '=https' --proto-redir '=https' --fail --location --retry 2 \
            --connect-timeout 20 --max-time 300 --output "$temporary/package.deb" "$native_url"
        printf '%s  %s\n' "$native_sha" "$temporary/package.deb" | sha256sum -c -
        dpkg-deb --extract "$temporary/package.deb" "$root/native"
        printf '%s\n' "$native_sha" > "$receipt"
        rm -rf "$temporary"
        trap - 0
    fi
done < "$root/native/packages.tsv"
for library in "$root/native/usr/lib/aarch64-linux-gnu/"*.so*; do
    [ -f "$library" ] || continue
    target="$root/${library##*/}"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        printf '%s\n' 'An existing SDK library was preserved.' >&2
        exit 1
    fi
    ln -sfn "$library" "$target"
done
cat > "$bin/dotnet.new" <<'EOF'
#!/data/data/dev.deskbox.app/files/usr/bin/sh
# Desk Box dotnet launcher
set -eu
. "${DESKBOX_LIB_DIR:?}/profile.sh"
. "$DESKBOX_LIB_DIR/lib/gnu.sh"
export DOTNET_ROOT="$HOME/.local/share/deskbox/toolchains/dotnet/@VERSION@"
export DOTNET_MULTILEVEL_LOOKUP=0 DOTNET_CLI_TELEMETRY_OPTOUT=1
gnu_exec "$DOTNET_ROOT/dotnet" "$@"
EOF
sed -i "s/@VERSION@/$version/g" "$bin/dotnet.new"
chmod 700 "$bin/dotnet.new"
mv "$bin/dotnet.new" "$bin/dotnet"
environment_dir="$HOME/.config/deskbox/environment.d"
mkdir -p "$environment_dir"
if [ -f "$environment_dir/dotnet.sh" ] && ! grep -q '^# Desk Box dotnet environment$' "$environment_dir/dotnet.sh"; then
    printf '%s\n' 'An existing user dotnet environment was preserved.' >&2
    exit 1
fi
cat > "$environment_dir/dotnet.sh.new" <<'EOF'
# Desk Box dotnet environment
export DOTNET_ROOT="$HOME/.local/share/deskbox/toolchains/dotnet/@VERSION@"
export DOTNET_MULTILEVEL_LOOKUP=0 DOTNET_CLI_TELEMETRY_OPTOUT=1
case ":${DESKBOX_GNU_LIBRARY_PATH_EXTRA:-}:" in
    *":$DOTNET_ROOT/native/usr/lib/aarch64-linux-gnu:"*) ;;
    *) export DESKBOX_GNU_LIBRARY_PATH_EXTRA="$DOTNET_ROOT/native/usr/lib/aarch64-linux-gnu${DESKBOX_GNU_LIBRARY_PATH_EXTRA:+:$DESKBOX_GNU_LIBRARY_PATH_EXTRA}";;
esac
EOF
sed -i "s/@VERSION@/$version/g" "$environment_dir/dotnet.sh.new"
chmod 600 "$environment_dir/dotnet.sh.new"
mv "$environment_dir/dotnet.sh.new" "$environment_dir/dotnet.sh"
printf 'Installed .NET SDK %s in %s\n' "$version" "$root"
