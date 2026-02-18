# DNS Manager v2.0 - DNS Configuration Tool

A powerful bash utility for managing DNS settings on Linux systems. Features a two-step interactive menu (choose DNS → choose method), a dedicated System Management submenu with 11 granular operations, and real-time multi-source DNS status display.

## ✨ Features

- 🌍 **Multiple DNS Providers**: Iranian (Shekan, Arvan) & International (Google, Cloudflare, Quad9, OpenDNS, AdGuard)
- 🔧 **Custom DNS**: Enter your own DNS IPs with IPv4 validation
- 🚀 **Two-Step Flow**: Choose DNS provider → Choose apply method (NetPlan or resolv.conf)
- ⚙️ **System Management Submenu**: 11 operations — view, edit, disable, delete, rollback for both NetPlan and resolv.conf, plus full reset
- 📊 **Multi-Source Status**: Shows NetPlan config, resolv.conf, and resolvectl status simultaneously with provider identification
- 🧪 **Connectivity Test**: Verifies DNS is working after applying (`nslookup`/`dig`)
- 💾 **Automatic Backup**: Saves original settings before changes
- ↩️ **Rollback & Disable**: Non-destructive disable (keeps file) or full rollback from backup
- 🎨 **Modern UI**: Clean, color-coded terminal interface with status indicators

## 📋 Requirements

- **Linux**: Ubuntu 17.10+ or any system with NetPlan (optional) or systemd-resolved
- **Privileges**: Root/sudo access required
- **Shell**: Bash
- **Utilities**: `ip`, `grep`, `awk`, `sed` (pre-installed on most systems)

## 🚀 Installation

### Option 1: System-wide (Recommended)

```bash
git clone https://github.com/USFAkbari/Set_Shekan_DNS.git
cd Set_Shekan_DNS
sudo cp dnsManager /usr/local/bin/dnsManager
sudo chmod +x /usr/local/bin/dnsManager
```

Run from anywhere:

```bash
sudo dnsManager
```

### Option 2: One-Liner

```bash
sudo curl -sSL https://raw.githubusercontent.com/USFAkbari/Set_Shekan_DNS/main/dnsManager -o /usr/local/bin/dnsManager && sudo chmod +x /usr/local/bin/dnsManager
```

### Option 3: Run Without Installing

```bash
git clone https://github.com/USFAkbari/Set_Shekan_DNS.git
cd Set_Shekan_DNS
sudo ./dnsManager
```

## 📖 How It Works

### Configuration Flow

```
Step 1: Select DNS Provider (1-8) or Custom DNS (C)
                    ↓
Step 2: Choose Apply Method
        ├── 1) NetPlan      → /etc/netplan/99-dns-manager.yaml
        └── 2) resolv.conf  → /etc/systemd/resolved.conf
                    ↓
Step 3: Apply → Test Connectivity → Show Result → Exit
```

## 📖 Menu Overview

### Main Menu

```
╔══════════════════════════════════════════════════════════════╗
║           🌐  DNS Manager  v2.0.0                           ║
╚══════════════════════════════════════════════════════════════╝

┌── Current DNS Status ────────────────────────────────────────┐
│ Interface: eth0                                              │
│                                                              │
│ NetPlan (/etc/netplan/99-dns-manager.yaml):                  │
│   DNS: 1.1.1.1, 1.0.0.1  (Cloudflare)                       │
│                                                              │
│ resolv.conf (/etc/resolv.conf):                              │
│   nameserver 127.0.0.53  (systemd-stub)                      │
│                                                              │
│ Resolvectl Status:                                           │
│   1.1.1.1  (Cloudflare)                                      │
│                                                              │
│ systemd-resolved: ● Active                                   │
└──────────────────────────────────────────────────────────────┘

 ── Iranian DNS ────────────    ── International DNS ───────────
  1) Shekan Pro                 5) Cloudflare
  2) Shekan Free                6) Quad9 (Malware Block)
  3) Arvan Cloud                7) OpenDNS
  4) Google DNS                 8) AdGuard (Ad Block)

  C) Custom DNS (enter your own)

 ── System Management ──────────────────────────────────────────
  S) System Management (view, edit, disable, delete, rollback)
  0) Exit
```

### System Management Submenu (`S`)

```
╔══════════════════════════════════════════════════════════════╗
║              ⚙  System Management                           ║
╚══════════════════════════════════════════════════════════════╝

 ── NetPlan (/etc/netplan/99-dns-manager.yaml) [● active]
   1) View     — Show current NetPlan DNS config
   2) Edit     — Modify DNS addresses in NetPlan
   3) Disable  — Suspend config without deleting
   4) Delete   — Remove NetPlan config permanently
   5) Rollback — Re-enable disabled config

 ── resolv.conf / systemd-resolved [● custom DNS set]
   6) View     — Show resolved.conf & resolv.conf
   7) Edit     — Modify DNS in resolved.conf
   8) Disable  — Remove custom DNS, use DHCP defaults
   9) Delete   — Remove custom DNS entries & backup
  10) Rollback — Restore resolved.conf from backup

 ── Full System ────────────────────────────────────────────────
  11) Reset All — Remove ALL DNS Manager configurations

   0) ← Back to main menu
```

## 📡 Supported DNS Servers

### Iranian DNS Services

| Provider | Primary | Secondary | Notes |
|----------|---------|-----------|-------|
| Shekan Pro | `178.22.122.101` | `185.51.200.1` | Premium anti-censorship |
| Shekan Free | `178.22.122.100` | `185.51.200.2` | Free tier |
| Arvan Cloud | `217.218.127.127` | `217.218.155.155` | Iranian CDN provider |

### International DNS Services

| Provider | Primary | Secondary | Features |
|----------|---------|-----------|----------|
| Google | `8.8.8.8` | `8.8.4.4` | Fast, reliable |
| Cloudflare | `1.1.1.1` | `1.0.0.1` | Privacy-focused, fastest |
| Quad9 | `9.9.9.9` | `149.112.112.112` | Malware blocking |
| OpenDNS | `208.67.222.222` | `208.67.220.220` | Family filter options |
| AdGuard | `94.140.14.14` | `94.140.15.15` | Ad & tracker blocking |

## ⚙️ Apply Methods

### NetPlan (Option 1)

1. Detects active network interface (e.g., `eth0`)
2. Creates config at `/etc/netplan/99-dns-manager.yaml`
3. Validates with `netplan generate`, applies with `netplan apply`
4. Overrides DHCP DNS settings

> **Note:** Wi-Fi interfaces automatically fall back to systemd-resolved due to NetPlan limitations.

### systemd-resolved (Option 2)

1. Backs up `/etc/systemd/resolved.conf`
2. Modifies DNS and FallbackDNS settings
3. Restarts systemd-resolved service

## 🔧 System Management Operations

| # | Target | Operation | Description |
|---|--------|-----------|-------------|
| **1** | NetPlan | View | Display YAML config file and parsed DNS addresses |
| **2** | NetPlan | Edit | Enter new DNS IPs → rewrite config → validate → apply |
| **3** | NetPlan | Disable | Rename to `.disabled` (preserves config, stops applying) |
| **4** | NetPlan | Delete | Permanently remove config file (requires confirmation) |
| **5** | NetPlan | Rollback | Re-enable a previously disabled config |
| **6** | Resolved | View | Show resolved.conf, resolv.conf, resolvectl, backup status |
| **7** | Resolved | Edit | Enter new DNS IPs → update resolved.conf → restart |
| **8** | Resolved | Disable | Remove custom DNS entries → revert to DHCP defaults |
| **9** | Resolved | Delete | Remove custom entries + delete backup (requires confirmation) |
| **10** | Resolved | Rollback | Restore resolved.conf from backup file |
| **11** | Both | Reset All | Remove all DNS Manager configs and restore system defaults |

## 🔍 Troubleshooting

### Permission Denied

```bash
sudo dnsManager
```

### Verify Current DNS

```bash
resolvectl status
cat /etc/netplan/99-dns-manager.yaml
cat /etc/resolv.conf
```

### Manual Removal

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
