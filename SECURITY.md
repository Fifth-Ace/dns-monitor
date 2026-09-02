# Security Policy

## Deployment boundaries

The web UI and API have no built-in authentication or TLS. The default listen
address is `:2233`, which binds to all interfaces. Restrict access to trusted
management devices using the router firewall; do not expose this port to the
Internet or untrusted LAN/guest clients. A specific address can be selected
with `-listen <management-ip>:2233`.

The API exposes observed DNS activity and client metadata. Packet capture and
policy-aware diagnostics require elevated privileges. Logs may contain queried
domains; treat both logs and exported diagnostics as private data.

## Reporting a vulnerability

Please do **not** publish credentials, public IP addresses, MAC addresses,
private hostnames, tunnel keys or complete router configuration dumps in a
public issue.

If the repository Security tab offers "Report a vulnerability", use that private
reporting channel. Otherwise, open a minimal GitHub issue requesting a private
contact method, without exploit details or sensitive diagnostics. Wait for a
maintainer to arrange that channel before sharing them.

When attaching normal diagnostics, sanitize:

- public IP addresses;
- MAC addresses;
- private device/host names;
- internal domains;
- VPN/WireGuard/AmneziaWG keys and credentials;
- tokens, passwords and cookies.

DNS Monitor performs passive packet capture and requires root privileges on the
router, so only install builds obtained from this repository or builds you have
compiled yourself.
