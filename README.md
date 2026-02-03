# DNS Manager - System Configuration

A comprehensive bash script to manage DNS settings on Linux systems using systemd-resolved. This script supports multiple DNS providers including Iranian services (Shekan, Arvan) and major international DNS services.

## Features

- 🌍 Support for multiple DNS providers (Iranian & International)
- 🔧 Easy DNS configuration with interactive colored menu
- 💾 Automatic backup of original DNS settings
- 🔄 Simple rollback functionality to restore original settings
- 🛡️ Safe operation with backup
- Detailed, timestamped output for each operation
- ⚡ Color-coded status messages for better readability
- 🎯 DNS verification after configuration
- 🚀 Quick access via shell alias

## Requirements

- Linux system with systemd-resolved
- Root/sudo privileges
- Bash shell

## Installation

### System-wide Installation (Recommended)

Install DNS Manager to `/usr/local/bin/` for easy access from anywhere in your system:

```bash
# Clone the repository
git clone https://github.com/USFAkbari/Set_Shekan_DNS.git
cd Set_Shekan_DNS

# Copy to /usr/local/bin/
sudo cp dnsManager /usr/local/bin/dnsManager

# Make it executable
sudo chmod +x /usr/local/bin/dnsManager
```

After installation, you can run DNS Manager from anywhere:

```bash
dnsManager
```

### Download and Install (One-Liner)

Download and install directly to `/usr/local/bin/`:

```bash
sudo curl -sSL https://raw.githubusercontent.com/USFAkbari/Set_Shekan_DNS/main/dnsManager -o /usr/local/bin/dnsManager && sudo chmod +x /usr/local/bin/dnsManager
```

Then run:

```bash
dnsManager
```

### Run Without Installing

If you prefer to run the script without installing:

```bash
# Clone the repository
git clone https://github.com/USFAkbari/Set_Shekan_DNS.git
cd Set_Shekan_DNS

# Run directly (requires sudo)
sudo ./dnsManager
```

Or download and run directly:

```bash
curl -sSL https://raw.githubusercontent.com/USFAkbari/Set_Shekan_DNS/main/dnsManager -o /tmp/dnsManager && chmod +x /tmp/dnsManager && sudo /tmp/dnsManager
```

### Uninstallation

To remove DNS Manager from your system:

```bash
sudo rm /usr/local/bin/dnsManager
```

### Menu Options

When you run the script, you'll see an interactive, color-coded menu:

```text
╔═══════════════════════════════════════════════════════╗
║           DNS Manager - System Configuration         ║
╚═══════════════════════════════════════════════════════╝

Iranian DNS Services:
  1) Shekan Pro DNS        (178.22.122.101, 185.51.200.1)
  2) Shekan Free DNS       (178.22.122.100, 185.51.200.2)
  3) Arvan Cloud DNS       (217.218.127.127, 217.218.155.155)

International DNS Services:
  4) Google Public DNS     (8.8.8.8, 8.8.4.4)
  5) Cloudflare DNS        (1.1.1.1, 1.0.0.1)
  6) Quad9 DNS             (9.9.9.9, 149.112.112.112) - Malware Protection
  7) OpenDNS               (208.67.222.222, 208.67.220.220)
  8) AdGuard DNS           (94.140.14.14, 94.140.15.15) - Ad Blocking

System Management:
  9) Roll back to original DNS settings

═══════════════════════════════════════════════════════
Choose an option (1-9):
```

### DNS Options Details

#### Iranian DNS Services

1. **Shekan Pro DNS** - Premium Shekan service with fallback to Google DNS
2. **Shekan Free DNS** - Free Shekan service with fallback to Google DNS
3. **Arvan Cloud DNS** - Iranian CDN and cloud provider with fallback to Cloudflare

#### International DNS Services

1. **Google Public DNS** - Google's fast and reliable DNS service
2. **Cloudflare DNS** - Privacy-focused DNS with excellent performance
3. **Quad9 DNS** - Security-focused DNS with built-in malware blocking
4. **OpenDNS** - Cisco's DNS with filtering capabilities
5. **AdGuard DNS** - DNS with built-in ad and tracker blocking

#### System Management

1. **Roll back DNS** - Restores original DNS configuration from backup or applies system defaults

## What the Script Does

1. **Backup Creation**: Automatically creates a backup of `/etc/systemd/resolved.conf` at `/etc/systemd/resolved.conf.backup` before making changes
2. **DNS Configuration**: Updates the DNS settings in systemd-resolved configuration
3. **Service Management**: Restarts the systemd-resolved service to apply changes
4. **Symlink Management**: Ensures `/etc/resolv.conf` is properly linked to systemd-resolved

## Important Notes

- ⚠️ **Root Access Required**: This script modifies system files and requires sudo/root privileges
- 💾 **Backup Safety**: The script automatically creates backups, but it's always good practice to have your own backup
- 🔄 **Service Restart**: The script restarts `systemd-resolved` service, which may briefly interrupt DNS resolution
- 📝 **Configuration File**: The script modifies `/etc/systemd/resolved.conf`

## Troubleshooting

### Permission Denied

If you get a permission denied error, make sure you're running with sudo:

```bash
sudo dnsManager
```

### systemd-resolved Not Running

If systemd-resolved is not running on your system, you may need to enable it:

```bash
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved
```

### Verify DNS Settings

To verify your DNS settings after running the script:

```bash
systemd-resolve --status
# or
resolvectl status
```

### Manual Rollback

If you need to manually restore the backup:

```bash
sudo cp /etc/systemd/resolved.conf.backup /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
```

## License

This script is provided as-is for free use.

## Contributing

Contributions, issues, and feature requests are welcome!

## Disclaimer

Use this script at your own risk. Always ensure you have backups of important system configurations before making changes.
