#!/system/bin/sh
set -eu
# Resolve the install catalog inside the existing pkg transaction.
consumer="$1"
lock="$2"
output="$3"
byte_count="$4"
work="${DESKBOX_TRANSACTION_DIR:?}"
shared_downloaded=0

resolve_shared_tools() {
    deskbox-native prepare-shared-tools "$lock" "$work"
    lock="$work/shared-catalog.json"
    set -- $(jq -r '.[]' "$work/shared-missing.json")
    if [ "$#" -eq 0 ]; then
        if [ -f "$work/shared-fallback-status" ]; then
            apt-get -o Dir::State::status="$work/shared-fallback-status" check >&2
        fi
        return
    fi

    deskbox-bridge progress QUERYING '' '{}'
    if apt-get -o APT::Status-Fd=-1 update >&2 &&
        apt-get --print-uris --yes --no-install-recommends --no-remove --no-upgrade \
            -o Dir::State::status="$work/shared-status" -o Dir::Cache::archives="$work/archives" \
            install "$@" > "$work/shared-uris" &&
        deskbox-native seed-cache "$work/shared-uris" "$work/archives" "$work/shared-missing.json"; then
        deskbox-bridge progress DOWNLOADING '' '{}'
        apt-get --download-only --yes --no-install-recommends --no-remove --no-upgrade \
            -o Dir::State::status="$work/shared-status" -o Dir::Cache::archives="$work/archives" \
            install "$@" >&2
        for archive in "$work/archives/"*.deb; do
            if [ -f "$archive" ] && [ ! -L "$archive" ]; then
                shared_downloaded=$((shared_downloaded + $(stat -c %s "$archive")))
            fi
        done
        deskbox-native plan-catalog "$consumer" "$work/shared-missing.json" "$work/shared-uris" \
            "$work/archives" "$work/shared-downloaded.json"
        deskbox-native resolve-shared-tools "$work" > "$work/shared-resolved.json"
        lock="$work/shared-resolved.json"
    else
        printf '%s\n' 'Using pinned shared tools from the program catalog' >&2
        if [ -f "$work/shared-fallback-status" ]; then
            apt-get -o Dir::State::status="$work/shared-fallback-status" check >&2
        fi
    fi
}
if jq -e 'has("sharedTools")' "$lock" >/dev/null; then resolve_shared_tools; fi
cp "$lock" "$output"
printf '%s\n' "$shared_downloaded" > "$byte_count"
