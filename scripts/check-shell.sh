#!/bin/sh
# Parse every shipped shell entry point, including extensionless opkg hooks.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
for SCRIPT in "$ROOT"/scripts/*.sh "$ROOT"/package/*.sh \
    "$ROOT/package/S90dns-monitor" "$ROOT/packaging/opkg/postinst" \
    "$ROOT/packaging/opkg/prerm"; do
    sh -n "$SCRIPT"
done
printf 'Shell syntax OK\n'
