#!/data/data/dev.deskbox.app/files/usr/bin/sh
. "$DESKBOX_LIB_DIR/lib/program.sh"
program_begin quake2 install
: "${DESKBOX_EXEC_ACTIVE:?请先更新 Desk Box}"
release_dir=${DESKBOX_RELEASE_DIR:?}
fetch_file() {
    name="$1"; checksum="$2"
    if ! printf '%s  %s\n' "$checksum" "$release_dir/$name" | sha256sum -c - >/dev/null 2>&1; then
        curl --fail --silent --show-error --connect-timeout 15 --max-time 120 --output "$release_dir/$name.part" \
            "https://raw.githubusercontent.com/eeoa/deskbox-repo/refs/tags/quake2-v8.50-deskbox.2/quake2/$name"
        printf '%s  %s\n' "$checksum" "$release_dir/$name.part" | sha256sum -c - >/dev/null
        mv "$release_dir/$name.part" "$release_dir/$name"
    fi
}
fetch_file catalog.json 351659538151dbfe2c0737ea2a48caf716429c1ad33809abed884d6131f804c9
fetch_file configure.sh 80d9e08cd878c72e14a5c0286eef176b20154dcad2a13c4d28c04c3c801d3c8c
fetch_file prepare-data.sh 78a898f5cee6047ef492a399f790f101f3b01208b560f053bae1d1aa573fa2c0
deskbox-bridge progress PREPARING quake2 '{}'
result=$(pkg ensure quake2 "$release_dir/catalog.json" install)
sh "$release_dir/prepare-data.sh"
program_result "$result"
