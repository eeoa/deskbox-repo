#!/data/data/dev.deskbox.app/files/usr/bin/sh
set -eu
. "${DESKBOX_RELEASE_DIR:?}/configure.sh"
printf '%s\n' "$$" > "$DESKBOX_CLIENT_PID_FILE"
# The upstream splash wrapper unconditionally stats /proc/version, which the
# Android app domain cannot read. Keep its documented restart exit semantics in
# shell, using the original soffice.bin through the common execution mechanism.
set -- --nologo --nofirststartwizard
while :; do
    status=0
    (gnu_exec "$office/program/soffice.bin" "-env:UserInstallation=file://$profile" \
        "-env:BRAND_BASE_DIR=file://$view" \
        "-env:FHS_CONFIG_FILE=file://$PREFIX/gnu/root/etc/libreoffice/sofficerc" "$@") || status=$?
    case "$status" in
        81) continue;;
        79) set --; continue;;
        *) exit "$status";;
    esac
done
