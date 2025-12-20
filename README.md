# Shekan DNS Manager

A simple bash script to manage DNS settings on Linux systems using systemd-resolved. This script allows you to easily configure your system to use Shekan free DNS servers or rollback to your original DNS configuration.

**Repository**: [https://github.com/USFAkbari/Set_Shekan_DNS](https://github.com/USFAkbari/Set_Shekan_DNS)

## Features

- 🔧 Easy DNS configuration using Shekan free DNS servers
- 💾 Automatic backup of original DNS settings
- 🔄 Simple rollback functionality to restore original settings
- 🛡️ Safe operation with backup verification
- 📋 Interactive menu for easy use

## Requirements

- Linux system with systemd-resolved
- Root/sudo privileges
- Bash shell

## Installation / Getting the Script

### Option 1: Clone the Repository

If you have Git installed, you can clone the entire repository:

```bash
git clone https://github.com/USFAkbari/Set_Shekan_DNS.git
cd Set_Shekan_DNS
```

### Option 2: Download the Script Directly

You can download just the script file using one of these methods:

#### Using wget:
```bash
wget https://raw.githubusercontent.com/USFAkbari/Set_Shekan_DNS/main/shekan_dns.sh
chmod +x shekan_dns.sh
```

#### Using curl:
```bash
curl -O https://raw.githubusercontent.com/USFAkbari/Set_Shekan_DNS/main/shekan_dns.sh
chmod +x shekan_dns.sh
```

#### Using Git (single file):
```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/USFAkbari/Set_Shekan_DNS.git
cd Set_Shekan_DNS
git sparse-checkout set shekan_dns.sh
chmod +x shekan_dns.sh
```

### Option 3: Copy and Paste

1. Open the script file (`shekan_dns.sh`) in your browser or text editor
2. Copy the entire contents
3. Create a new file on your system:
   ```bash
   nano shekan_dns.sh
   ```
4. Paste the contents and save (Ctrl+X, then Y, then Enter)
5. Make it executable:
   ```bash
   chmod +x shekan_dns.sh
   ```

## Usage

### Running the Script

The script requires root privileges to modify system DNS settings:

```bash
sudo ./shekan_dns.sh
```

### Menu Options

When you run the script, you'll see an interactive menu:

```
=======================================
     Shekan DNS Manager (systemd)       
=======================================
1) Add Shekan free DNS
2) Roll back DNS settings
Choose an option (1/2):
```

**Option 1: Add Shekan free DNS**
- Creates a backup of your current DNS configuration (if not already exists)
- Configures your system to use Shekan DNS servers:
  - Primary: `178.22.122.100`
  - Secondary: `185.51.200.2`
- Restarts systemd-resolved service

**Option 2: Roll back DNS settings**
- Restores your original DNS configuration from backup
- If no backup exists, applies default systemd-resolved settings
- Restarts systemd-resolved service

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
sudo ./shekan_dns.sh
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

