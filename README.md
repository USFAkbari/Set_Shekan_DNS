# DNS Manager - NetPlan Configuration Tool

A comprehensive bash script to manage DNS settings on Linux systems using **NetPlan** (primary) with **systemd-resolved** fallback. Features an interactive menu with real-time DNS status display, supporting Iranian DNS services (Shekan, Arvan) and major international DNS providers.

## ✨ Features

- 🌍 **Multiple DNS Providers**: Iranian (Shekan, Arvan) & International (Google, Cloudflare, Quad9, OpenDNS, AdGuard)
- 🔒 **VPN DNS Support**: ExpressVPN recommended DNS configuration
- 🚀 **NetPlan-First**: Prioritizes NetPlan for persistent, reliable DNS configuration
- 📊 **Live DNS Table**: Real-time display of current DNS settings in the menu
- 🔄 **Reset to Default**: Easily restore system default DNS configuration
- 💾 **Automatic Backup**: Saves original settings before making changes
- ↩️ **Rollback Support**: One-click restoration of original DNS settings
- 🎨 **Modern UI**: Color-coded, table-based interactive menu
- 🔌 **Auto-Detection**: Automatically identifies active network interface

## 📋 Requirements

- **Linux**: Ubuntu 17.10+ or any system with NetPlan (recommended), or systemd-resolved (fallback)
- **Privileges**: Root/sudo access required
- **Shell**: Bash
- **Utilities**: `ip`, `grep`, `awk`, `sed` (pre-installed on most systems)

## 🚀 Installation

### Option 1: System-wide Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/USFAkbari/Set_Shekan_DNS.git
cd Set_Shekan_DNS

# Install to /usr/local/bin/
sudo cp dnsManager.sh /usr/local/bin/dnsManager
sudo chmod +x /usr/local/bin/dnsManager
```

Run from anywhere:

```bash
sudo dnsManager
```

### Option 2: One-Liner Install

```bash
sudo curl -sSL https://raw.githubusercontent.com/USFAkbari/Set_Shekan_DNS/main/dnsManager.sh -o /usr/local/bin/dnsManager && sudo chmod +x /usr/local/bin/dnsManager
```

### Option 3: Run Without Installing

```bash
git clone https://github.com/USFAkbari/Set_Shekan_DNS.git
cd Set_Shekan_DNS
sudo ./dnsManager.sh
```

## 📖 Menu Overview

When you run the script, you'll see an interactive menu with live DNS status:

```
╔═════════════════════════════════════════════════════════════════════════════════╗
║                    DNS Manager - NetPlan Configuration                          ║
╚═════════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────── Current DNS Configuration ───────────────────────────┐
│ Interface: eth0                    │ Method: NetPlan                             │
│ Primary:   1.1.1.1                 │ Status: ● Active                            │
│ Secondary: 1.0.0.1                 │                                             │
└─────────────────────────────────────────────────────────────────────────────────┘

 ┌── Iranian DNS ──┐   ┌── International DNS ─────────┐   ┌── VPN DNS ───┐
 │ 1) Shekan Pro   │   │ 4) Google                    │   │ 9) ExpressVPN│
 │ 2) Shekan Free  │   │ 5) Cloudflare                │   └──────────────┘
 │ 3) Arvan Cloud  │   │ 6) Quad9 (Malware Block)     │
 └─────────────────┘   │ 7) OpenDNS                   │
                       │ 8) AdGuard (Ad Block)        │
                       └───────────────────────────────┘

 ┌── System Management ────────────────────────────────────────────────────────────┐
 │ N) Remove/Deactivate NetPlan DNS   R) Reset resolv.conf to default              │
 │ B) Rollback to original settings   0) Exit                                      │
 └─────────────────────────────────────────────────────────────────────────────────┘
```

## 📡 Supported DNS Servers

### Iranian DNS Services

| Provider | Primary | Secondary | Notes |
|----------|---------|-----------|-------|
| Shekan Pro | 178.22.122.101 | 185.51.200.1 | Premium anti-censorship |
| Shekan Free | 178.22.122.100 | 185.51.200.2 | Free tier |
| Arvan Cloud | 217.218.127.127 | 217.218.155.155 | Iranian CDN provider |

### International DNS Services

| Provider | Primary | Secondary | Features |
|----------|---------|-----------|----------|
| Google | 8.8.8.8 | 8.8.4.4 | Fast, reliable |
| Cloudflare | 1.1.1.1 | 1.0.0.1 | Privacy-focused, fastest |
| Quad9 | 9.9.9.9 | 149.112.112.112 | Malware blocking |
| OpenDNS | 208.67.222.222 | 208.67.220.220 | Family filter options |
| AdGuard | 94.140.14.14 | 94.140.15.15 | Ad & tracker blocking |

### VPN DNS

| Provider | Primary | Secondary | Notes |
|----------|---------|-----------|-------|
| ExpressVPN | 208.67.222.222 | 208.67.220.220 | Uses OpenDNS (recommended by ExpressVPN) |

## ⚙️ How It Works

### NetPlan Method (Primary)

1. **Detects** active network interface (e.g., `eth0`, `wlan0`)
2. **Creates** configuration at `/etc/netplan/99-dns-manager.yaml`
3. **Applies** using `netplan apply`
4. **Overrides** DHCP DNS with custom settings

### systemd-resolved Method (Fallback)

Used when NetPlan is not available:

1. **Backs up** `/etc/systemd/resolved.conf`
2. **Modifies** DNS settings directly
3. **Restarts** systemd-resolved service

## 🔧 System Management Options

### Remove/Deactivate NetPlan DNS (N)

Specifically removes the DNS Manager's NetPlan configuration:

- Shows current NetPlan DNS configuration before removal
- Removes `/etc/netplan/99-dns-manager.yaml`
- Applies NetPlan changes
- DNS reverts to DHCP-provided or system default servers

### Reset to Default (R)

Completely removes all DNS Manager configurations and restores system defaults:

- Removes `/etc/netplan/99-dns-manager.yaml`
- Clears custom DNS entries from systemd-resolved
- Restores default `resolv.conf` symlink

### Rollback (B)

Reverts to the original DNS configuration that was backed up:

- Removes NetPlan configuration
- Restores backed-up `resolved.conf`
- Ideal for undoing recent changes

## 📚 Documentation

For detailed information about NetPlan and how this tool integrates with it, see:

- [NetPlan Guide](docs/netplan-guide.md) - Comprehensive NetPlan documentation

## 🔍 Troubleshooting

### Permission Denied

```bash
sudo dnsManager
```

### Verify Current DNS

```bash
# For NetPlan systems
resolvectl status

# View generated config
cat /etc/netplan/99-dns-manager.yaml
```

### Manual Removal

If you need to manually remove DNS Manager configurations:

**NetPlan:**

```bash
sudo rm /etc/netplan/99-dns-manager.yaml
sudo netplan apply
```

**systemd-resolved:**

```bash
sudo cp /etc/systemd/resolved.conf.backup /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
```

## 📄 License

This script is provided as-is for free use.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## ⚠️ Disclaimer

Use this script at your own risk. Always ensure you have backups of important system configurations before making changes.
