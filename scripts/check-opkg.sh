#!/bin/sh
# Build and inspect only; never install a package or invoke router services.
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT"
sh scripts/build-opkg.sh
sh scripts/build-feed.sh dist
python3 - <<'PY'
import gzip
import hashlib
import io
from pathlib import Path
import re
import tarfile


def require(condition, message):
    if not condition:
        raise SystemExit(message)


def fields(data):
    return dict(line.split(": ", 1) for line in data.splitlines() if line)


def read_member(archive, name):
    stream = archive.extractfile(name)
    require(stream is not None, f"Missing regular file: {name}")
    return stream.read()


root = Path.cwd()
version = re.search(r'^const version = "([^"]+)"$', (root / "main.go").read_text(),
                    re.MULTILINE).group(1)
package = root / "dist" / f"dns-monitor_{version}_aarch64-3.10.ipk"
require(package.is_file(), "Builder default and application version differ")
with tarfile.open(package, "r:gz") as outer:
    require(set(outer.getnames()) ==
            {"./debian-binary", "./control.tar.gz", "./data.tar.gz"},
            "Expected Entware gzip/tar package layout")
    require(read_member(outer, "./debian-binary") == b"2.0\n", "Bad package format")
    with tarfile.open(fileobj=io.BytesIO(read_member(outer, "./control.tar.gz")),
                      mode="r:gz") as control:
        metadata = fields(read_member(control, "./control").decode())
        require(metadata["Package"] == "dns-monitor", "Bad package name")
        require(metadata["Version"] == version, "Bad package version")
        require(metadata["Architecture"] == "aarch64-3.10", "Bad opkg architecture")
        require(metadata["License"] == "MIT", "Bad license metadata")
        for name in ("postinst", "prerm", "conffiles"):
            member = f"./{name}"
            require(read_member(control, member) ==
                    (root / "packaging/opkg" / name).read_bytes(),
                    f"Changed control file: {name}")
            if name != "conffiles":
                require(control.getmember(member).mode & 0o777 == 0o755,
                        f"Hook not executable: {name}")
    with tarfile.open(fileobj=io.BytesIO(read_member(outer, "./data.tar.gz")),
                      mode="r:gz") as data:
        expected = {
            "./opt/bin/dns-monitor",
            "./opt/etc/init.d/S90dns-monitor",
            "./opt/share/licenses/dns-monitor/LICENSE",
        }
        require({m.name for m in data.getmembers() if not m.isdir()} == expected,
                "Unexpected installed files")
        binary = read_member(data, "./opt/bin/dns-monitor")
        require(binary[:6] == b"\x7fELF\x02\x01" and
                int.from_bytes(binary[18:20], "little") == 183,
                "Expected a 64-bit little-endian AArch64 ELF")
        for name in ("./opt/bin/dns-monitor", "./opt/etc/init.d/S90dns-monitor"):
            require(data.getmember(name).mode & 0o777 == 0o755,
                    f"Installed file not executable: {name}")
        require(read_member(data, "./opt/etc/init.d/S90dns-monitor") ==
                (root / "package/S90dns-monitor").read_bytes(), "Init script differs")
        require(read_member(data, "./opt/share/licenses/dns-monitor/LICENSE") ==
                (root / "LICENSE").read_bytes(), "License differs")

index = (root / "dist/Packages").read_bytes()
require(gzip.decompress((root / "dist/Packages.gz").read_bytes()) == index,
        "Compressed feed differs")
entries = [fields(entry) for entry in index.decode().strip().split("\n\n")]
matches = [entry for entry in entries if entry.get("Filename") == package.name]
require(len(matches) == 1, "Expected exactly one entry for the built package")
entry = matches[0]
require(all(entry.get(k) == v for k, v in metadata.items()), "Feed metadata differs")
payload = package.read_bytes()
require(entry["Size"] == str(len(payload)), "Feed size differs")
require(entry["SHA256sum"] == hashlib.sha256(payload).hexdigest(), "SHA256 differs")
require(entry["MD5sum"] == hashlib.md5(payload).hexdigest(), "MD5 differs")
print(f"Package and feed OK: {package.name}")
PY
