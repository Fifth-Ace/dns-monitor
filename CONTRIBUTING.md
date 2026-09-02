# Contributing

DNS Monitor targets Keenetic / Netcraze ARM64 routers running Entware.
Bug reports and pull requests are welcome in Russian or English.

## Reporting a problem

Use the GitHub issue forms and include the router model, firmware version,
CPU architecture, DNS Monitor version, installation method, reproduction steps
and expected behavior. Remove public IPs, MAC addresses, private device names,
internal domains, credentials and tunnel secrets from diagnostics.
For suspected vulnerabilities, follow [SECURITY](SECURITY.md).

## Repository layout

| Path | Purpose |
| --- | --- |
| Root `*.go` | One Go application: capture, discovery, statistics, diagnostics and HTTP API |
| Root `*_test.go` | Tests grouped by the behavior they cover |
| `web/` | Embedded HTML, CSS and JavaScript; no frontend build step |
| `package/` | Manual release archive installer, uninstaller, init script and user instructions |
| `packaging/opkg/` | Package control template, lifecycle hooks and conffiles list |
| `scripts/` | Feed installation/removal, package/feed builders and development checks |
| `.github/` | CI and contribution templates |
| `dist/` | Generated build output, ignored by Git |

Keep `package/` and `packaging/opkg/` in place: the builders reference these paths.
The empty `conffiles` is intentional; the package currently declares no opkg-managed
configuration files.

## Development checks

Use Linux (or WSL) with Go 1.21 or newer. Native Windows/macOS builds are not
supported: capture and routing use Linux-specific APIs. Tests do not require
a router or root privileges.

Run from the repository root:

```sh
gofmt -l .
go test ./...
go vet ./...
sh scripts/check-shell.sh
```

The formatting command must print no files. Use `gofmt -w <changed-file.go>`
to format Go changes. Keep test names descriptive and retain existing regression
coverage. Keep router-specific parsing defensive: Keenetic output can vary
between firmware versions and hardware families.

Changes to user-facing documentation should update both [README.md](README.md)
and [README_EN.md](README_EN.md). The manual archive has a separate, short
[installation guide](package/README.md).

## Package checks

On Linux with Go, Python 3, GNU tar, gzip and standard Unix tools:

```sh
sh scripts/check-opkg.sh
```

This builds the ARM64 package and feed in `dist/`, then checks their metadata,
checksums, archive layout, installed files, executable permissions and ELF target.
It does not install the package or run router services. CI runs the same checks.
Actual installation and service operation still require a supported router.

For a manual build:

```sh
sh scripts/build-opkg.sh 0.1.0
sh scripts/build-feed.sh dist
```

The output is `dist/dns-monitor_0.1.0_aarch64-3.10.ipk` plus `Packages` and
`Packages.gz`. An optional second build argument adds an opkg revision, for
example `sh scripts/build-opkg.sh 0.1.0 1`. The version argument sets package
metadata; the application version remains defined in `main.go`.

## Release maintenance

Published tags and release assets should stay unchanged. For a future release:

1. Choose a new version and align `main.go`, the UI version fallback in
   `web/js/app.js`, the package builder default and release documentation.
2. Run the development and package checks; verify installation, upgrade,
   service restart and removal on a supported Keenetic/Entware router.
3. Update [CHANGELOG](CHANGELOG.md) and build the release archive with the binary,
   files from `package/`, and the root `LICENSE`. Preserve executable permissions
   for the installers and init script.
4. Publish the new tag, archives, package and checksums. Update the `opkg` branch
   with the intended packages and regenerated `Packages` / `Packages.gz` together.

CI validates pull requests and pushes to `main`; it does not publish releases
or modify the `opkg` feed.
