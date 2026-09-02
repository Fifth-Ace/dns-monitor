# DNS Monitor — manual installation

DNS monitoring and diagnostics for **Keenetic / Netcraze ARM64 (aarch64)** routers
with Entware mounted at `/opt`. Root access and the Keenetic `ndmc` command
are required.

This directory supplies the manual release archive. For features, limitations
and the recommended opkg installation, see the
[project README](https://github.com/Fifth-Ace/dns-monitor#readme).

## Install

Download the ARM64 archive from
[GitHub Releases](https://github.com/Fifth-Ace/dns-monitor/releases), unpack it on
the router and run the installer from the extracted directory:

```sh
cd /opt/tmp/dns-monitor-v0.1.0
./install.sh
```

The archive must contain `dns-monitor-linux-arm64`, `install.sh`, `uninstall.sh`,
`S90dns-monitor`, `README.md` and `LICENSE`. The installer copies the binary and
init script into `/opt`, installs the license and starts the service.

Open `http://<router-ip>:2233` from a trusted management device. The web interface
has no built-in authentication or TLS; restrict access using the router firewall.

## Service and logs

```sh
/opt/etc/init.d/S90dns-monitor stop
/opt/etc/init.d/S90dns-monitor start
/opt/etc/init.d/S90dns-monitor restart
tail -f /opt/var/log/dns-monitor.log
```

## Update or remove

To update a manual installation, unpack the new release and run its
`./install.sh`. To remove a manual installation, run `./uninstall.sh` from the
archive directory. Logs are retained in `/opt/var/log/dns-monitor.log`.

For installations managed by opkg, use `opkg upgrade dns-monitor` or
`opkg remove dns-monitor` instead of the manual scripts.

## License

DNS Monitor is distributed under the MIT License.
Copyright (c) 2026 Fifth-Ace. See the `LICENSE` file included in the archive.
