#!/bin/bash

# ================================================
# DNS Manager Script
# Supports Shekan, Arvan, and Major World DNS
# ================================================

SYSTEMD_CONF="/etc/systemd/resolved.conf"
BACKUP_CONF="/etc/systemd/resolved.conf.backup"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Function to create backup
create_backup() {
  if [ ! -f "$BACKUP_CONF" ]; then
    cp "$SYSTEMD_CONF" "$BACKUP_CONF"
    print_message "$GREEN" "✓ [$TIMESTAMP] Backup created at $BACKUP_CONF"
  else
    print_message "$YELLOW" "ℹ [$TIMESTAMP] Backup already exists: $BACKUP_CONF"
  fi
}

# Function to show current DNS configuration
show_current_config() {
  print_message "$BLUE" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_message "$BLUE" "Current DNS Configuration:"
  print_message "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Show systemd-resolved status
  if command -v resolvectl &> /dev/null; then
    resolvectl status | grep -A 5 "DNS Servers"
  elif command -v systemd-resolve &> /dev/null; then
    systemd-resolve --status | grep -A 5 "DNS Servers"
  fi
  
  print_message "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# Function to apply DNS settings
apply_dns() {
  local dns_primary=$1
  local dns_secondary=$2
  local dns_name=$3
  local fallback_dns=$4
  
  print_message "$BLUE" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_message "$GREEN" "Applying $dns_name DNS Settings"
  print_message "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  create_backup
  
  print_message "$YELLOW" "► [$TIMESTAMP] Configuring DNS servers..."
  print_message "$YELLOW" "  Primary DNS: $dns_primary"
  print_message "$YELLOW" "  Secondary DNS: $dns_secondary"
  print_message "$YELLOW" "  Fallback DNS: $fallback_dns"
  
  # Update DNS settings
  sed -i '/^DNS=/d' "$SYSTEMD_CONF"
  sed -i '/^#DNS=/d' "$SYSTEMD_CONF"
  sed -i "/^\[Resolve\]/a DNS=$dns_primary $dns_secondary" "$SYSTEMD_CONF"
  
  # Add DNS Fallback
  sed -i '/^FallbackDNS=/d' "$SYSTEMD_CONF"
  sed -i '/^#FallbackDNS=/d' "$SYSTEMD_CONF"
  sed -i "/^\[Resolve\]/a FallbackDNS=$fallback_dns" "$SYSTEMD_CONF"
  
  # Ensure DNSStubListener=no for better compatibility
  sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/' "$SYSTEMD_CONF"
  sed -i 's/^DNSStubListener=.*/DNSStubListener=no/' "$SYSTEMD_CONF"
  
  print_message "$YELLOW" "► [$TIMESTAMP] Restarting systemd-resolved service..."
  
  # Restart service
  if systemctl restart systemd-resolved; then
    print_message "$GREEN" "✓ [$TIMESTAMP] systemd-resolved restarted successfully"
  else
    print_message "$RED" "✗ [$TIMESTAMP] Failed to restart systemd-resolved"
    return 1
  fi
  
  # Link resolv.conf
  ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  print_message "$GREEN" "✓ [$TIMESTAMP] DNS configuration applied successfully!"
  
  show_current_config
  
  print_message "$GREEN" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_message "$GREEN" "✓ $dns_name DNS Setup Complete!"
  print_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# DNS Configuration Functions

add_shekan_pro() {
  apply_dns "178.22.122.101" "185.51.200.1" "Shekan Pro" "8.8.8.8 8.8.4.4"
}

add_shekan_free() {
  apply_dns "178.22.122.100" "185.51.200.2" "Shekan Free" "8.8.8.8 8.8.4.4"
}

add_arvan_dns() {
  apply_dns "217.218.127.127" "217.218.155.155" "Arvan Cloud" "1.1.1.1 1.0.0.1"
}

add_google_dns() {
  apply_dns "8.8.8.8" "8.8.4.4" "Google Public DNS" "1.1.1.1 1.0.0.1"
}

add_cloudflare_dns() {
  apply_dns "1.1.1.1" "1.0.0.1" "Cloudflare" "8.8.8.8 8.8.4.4"
}

add_quad9_dns() {
  apply_dns "9.9.9.9" "149.112.112.112" "Quad9 (Malware Blocking)" "8.8.8.8 1.1.1.1"
}

add_opendns() {
  apply_dns "208.67.222.222" "208.67.220.220" "OpenDNS" "8.8.8.8 1.1.1.1"
}

add_adguard_dns() {
  apply_dns "94.140.14.14" "94.140.15.15" "AdGuard DNS (Ad Blocking)" "8.8.8.8 1.1.1.1"
}

rollback_dns() {
  print_message "$BLUE" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_message "$YELLOW" "Rolling Back DNS Settings"
  print_message "$BLUE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if [ -f "$BACKUP_CONF" ]; then
    print_message "$YELLOW" "► [$TIMESTAMP] Restoring from backup..."
    cp "$BACKUP_CONF" "$SYSTEMD_CONF"
    print_message "$GREEN" "✓ [$TIMESTAMP] Restored original resolved.conf from backup"
  else
    print_message "$RED" "⚠ [$TIMESTAMP] No backup found. Applying system default settings..."
    
    # Create proper systemd resolved.conf format
    cat <<'EOF' >"$SYSTEMD_CONF"
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See resolved.conf(5) for details

[Resolve]
#DNS=
#FallbackDNS=
#Domains=
#LLMNR=yes
#MulticastDNS=yes
#DNSSEC=allow-downgrade
#DNSOverTLS=no
#Cache=yes
#DNSStubListener=yes
EOF
    print_message "$GREEN" "✓ [$TIMESTAMP] Applied default systemd-resolved configuration"
  fi
  
  print_message "$YELLOW" "► [$TIMESTAMP] Restoring resolv.conf symlink..."
  ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  
  print_message "$YELLOW" "► [$TIMESTAMP] Restarting systemd-resolved service..."
  if systemctl restart systemd-resolved; then
    print_message "$GREEN" "✓ [$TIMESTAMP] systemd-resolved restarted successfully"
  else
    print_message "$RED" "✗ [$TIMESTAMP] Failed to restart systemd-resolved"
    return 1
  fi
  
  show_current_config
  
  print_message "$GREEN" "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_message "$GREEN" "✓ DNS Rollback Complete!"
  print_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
}

# Main Menu
clear
echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           DNS Manager - System Configuration         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Iranian DNS Services:${NC}"
echo -e "  ${YELLOW}1)${NC} Shekan Pro DNS        (178.22.122.101, 185.51.200.1)"
echo -e "  ${YELLOW}2)${NC} Shekan Free DNS       (178.22.122.100, 185.51.200.2)"
echo -e "  ${YELLOW}3)${NC} Arvan Cloud DNS       (217.218.127.127, 217.218.155.155)"
echo ""
echo -e "${GREEN}International DNS Services:${NC}"
echo -e "  ${YELLOW}4)${NC} Google Public DNS     (8.8.8.8, 8.8.4.4)"
echo -e "  ${YELLOW}5)${NC} Cloudflare DNS        (1.1.1.1, 1.0.0.1)"
echo -e "  ${YELLOW}6)${NC} Quad9 DNS             (9.9.9.9, 149.112.112.112) - Malware Protection"
echo -e "  ${YELLOW}7)${NC} OpenDNS               (208.67.222.222, 208.67.220.220)"
echo -e "  ${YELLOW}8)${NC} AdGuard DNS           (94.140.14.14, 94.140.15.15) - Ad Blocking"
echo ""
echo -e "${GREEN}System Management:${NC}"
echo -e "  ${YELLOW}9)${NC} Roll back to original DNS settings"
echo -e "  ${YELLOW}0)${NC} Exit / Quit"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -n -e "${GREEN}Choose an option (0-9): ${NC}"
read choice

case $choice in
  1) add_shekan_pro ;;
  2) add_shekan_free ;;
  3) add_arvan_dns ;;
  4) add_google_dns ;;
  5) add_cloudflare_dns ;;
  6) add_quad9_dns ;;
  7) add_opendns ;;
  8) add_adguard_dns ;;
  9) rollback_dns ;;
  0)
    print_message "$GREEN" "✓ Exiting DNS Manager. Goodbye!"
    exit 0
    ;;
  *)
    print_message "$RED" "✗ Invalid option. Please choose 0-9."
    exit 1
    ;;
esac
