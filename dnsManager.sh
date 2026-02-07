#!/bin/bash

# ════════════════════════════════════════════════════════════════════════════
# DNS Manager - NetPlan Configuration Tool
# Supports Iranian DNS (Shekan, Arvan) and Major International DNS Services
# Primary: NetPlan | Fallback: systemd-resolved
# ════════════════════════════════════════════════════════════════════════════

# Configuration paths
NETPLAN_FILE="/etc/netplan/99-dns-manager.yaml"
SYSTEMD_CONF="/etc/systemd/resolved.conf"
BACKUP_CONF="/etc/systemd/resolved.conf.backup"
RESOLV_CONF="/etc/resolv.conf"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ─────────────────────────────────────────────────────────────────────────────
# Utility Functions
# ─────────────────────────────────────────────────────────────────────────────

print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

print_separator() {
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ─────────────────────────────────────────────────────────────────────────────
# System Detection Functions
# ─────────────────────────────────────────────────────────────────────────────

check_netplan_installed() {
  command -v netplan &> /dev/null
}

check_systemd_resolved() {
  systemctl is-active --quiet systemd-resolved
}

get_active_interface() {
  ip route | grep '^default' | awk '{print $5}' | head -n1
}

get_interface_type() {
  local iface=$1
  if [[ $iface == wl* ]]; then
    echo "wifis"
  else
    echo "ethernets"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# DNS Information Functions
# ─────────────────────────────────────────────────────────────────────────────

get_current_dns() {
  local dns_primary=""
  local dns_secondary=""
  
  # Try resolvectl first
  if command -v resolvectl &> /dev/null; then
    local dns_list=$(resolvectl status 2>/dev/null | grep -A 10 "DNS Servers" | grep -E "^\s+[0-9]" | head -2)
    dns_primary=$(echo "$dns_list" | head -1 | awk '{print $1}')
    dns_secondary=$(echo "$dns_list" | tail -1 | awk '{print $1}')
  fi
  
  # Fallback to resolv.conf
  if [ -z "$dns_primary" ]; then
    dns_primary=$(grep "^nameserver" /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')
    dns_secondary=$(grep "^nameserver" /etc/resolv.conf 2>/dev/null | sed -n '2p' | awk '{print $2}')
  fi
  
  echo "${dns_primary:-N/A}|${dns_secondary:-N/A}"
}

get_config_method() {
  if [ -f "$NETPLAN_FILE" ]; then
    echo "NetPlan"
  elif [ -f "$BACKUP_CONF" ]; then
    echo "systemd-resolved"
  else
    echo "System Default"
  fi
}

get_dns_status() {
  if check_systemd_resolved; then
    echo -e "${GREEN}● Active${NC}"
  else
    echo -e "${RED}● Inactive${NC}"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Display Functions
# ─────────────────────────────────────────────────────────────────────────────

show_dns_table() {
  local interface=$(get_active_interface)
  local dns_info=$(get_current_dns)
  local dns_primary=$(echo "$dns_info" | cut -d'|' -f1)
  local dns_secondary=$(echo "$dns_info" | cut -d'|' -f2)
  local method=$(get_config_method)
  local status=$(get_dns_status)
  
  echo ""
  echo -e "${CYAN}┌─────────────────────────── Current DNS Configuration ───────────────────────────┐${NC}"
  printf "${CYAN}│${NC} %-20s ${WHITE}%-20s${NC} ${CYAN}│${NC} %-15s %-20s ${CYAN}│${NC}\n" "Interface:" "${interface:-N/A}" "Method:" "$method"
  printf "${CYAN}│${NC} %-20s ${GREEN}%-20s${NC} ${CYAN}│${NC} %-15s $status ${CYAN}│${NC}\n" "Primary DNS:" "$dns_primary" "Status:"
  printf "${CYAN}│${NC} %-20s ${GREEN}%-20s${NC} ${CYAN}│${NC} %-36s ${CYAN}│${NC}\n" "Secondary DNS:" "$dns_secondary" ""
  echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"
}

show_menu() {
  clear
  echo ""
  echo -e "${BLUE}╔═════════════════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}${BOLD}${WHITE}                    DNS Manager - NetPlan Configuration                         ${NC}${BLUE}║${NC}"
  echo -e "${BLUE}╚═════════════════════════════════════════════════════════════════════════════════╝${NC}"
  
  show_dns_table
  
  echo ""
  echo -e "${GREEN}┌─── Iranian DNS Services ───┐${NC}  ${YELLOW}┌─── International DNS ──────────┐${NC}  ${MAGENTA}┌─── VPN DNS ───┐${NC}"
  echo -e "${GREEN}│${NC} ${WHITE}1)${NC} Shekan Pro             ${GREEN}│${NC}  ${YELLOW}│${NC} ${WHITE}4)${NC} Google DNS               ${YELLOW}│${NC}  ${MAGENTA}│${NC} ${WHITE}9)${NC} ExpressVPN ${MAGENTA}│${NC}"
  echo -e "${GREEN}│${NC} ${WHITE}2)${NC} Shekan Free            ${GREEN}│${NC}  ${YELLOW}│${NC} ${WHITE}5)${NC} Cloudflare               ${YELLOW}│${NC}  ${MAGENTA}└───────────────┘${NC}"
  echo -e "${GREEN}│${NC} ${WHITE}3)${NC} Arvan Cloud            ${GREEN}│${NC}  ${YELLOW}│${NC} ${WHITE}6)${NC} Quad9 (Malware Block)    ${YELLOW}│${NC}"
  echo -e "${GREEN}└────────────────────────────┘${NC}  ${YELLOW}│${NC} ${WHITE}7)${NC} OpenDNS                  ${YELLOW}│${NC}"
  echo -e "                               ${YELLOW}│${NC} ${WHITE}8)${NC} AdGuard (Ad Block)       ${YELLOW}│${NC}"
  echo -e "                               ${YELLOW}└─────────────────────────────────┘${NC}"
  echo ""
  echo -e "${CYAN}┌─── System Management ───────────────────────────────────────────────────────────┐${NC}"
  echo -e "${CYAN}│${NC} ${WHITE}N)${NC} Remove/Deactivate NetPlan DNS   ${WHITE}R)${NC} Reset resolv.conf to default          ${CYAN}│${NC}"
  echo -e "${CYAN}│${NC} ${WHITE}B)${NC} Rollback to original settings   ${WHITE}0)${NC} Exit                                  ${CYAN}│${NC}"
  echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"
  echo ""
}

show_dns_details() {
  echo ""
  echo -e "${BLUE}┌─── DNS Server Details ──────────────────────────────────────────────────────────┐${NC}"
  echo -e "${BLUE}│${NC} ${GREEN}Iranian DNS:${NC}                                                                    ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   Shekan Pro   : 178.22.122.101, 185.51.200.1                                  ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   Shekan Free  : 178.22.122.100, 185.51.200.2                                  ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   Arvan Cloud  : 217.218.127.127, 217.218.155.155                              ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}                                                                                ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC} ${YELLOW}International DNS:${NC}                                                              ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   Google       : 8.8.8.8, 8.8.4.4                                              ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   Cloudflare   : 1.1.1.1, 1.0.0.1                                              ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   Quad9        : 9.9.9.9, 149.112.112.112                                      ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   OpenDNS      : 208.67.222.222, 208.67.220.220                                ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   AdGuard      : 94.140.14.14, 94.140.15.15                                    ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}                                                                                ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC} ${MAGENTA}VPN DNS:${NC}                                                                        ${BLUE}│${NC}"
  echo -e "${BLUE}│${NC}   ExpressVPN   : 208.67.222.222, 208.67.220.220 (OpenDNS - Recommended)        ${BLUE}│${NC}"
  echo -e "${BLUE}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Backup Functions
# ─────────────────────────────────────────────────────────────────────────────

create_backup() {
  if [ ! -f "$BACKUP_CONF" ] && [ -f "$SYSTEMD_CONF" ]; then
    cp "$SYSTEMD_CONF" "$BACKUP_CONF"
    print_message "$GREEN" "✓ [$TIMESTAMP] Backup created at $BACKUP_CONF"
  else
    print_message "$DIM" "ℹ [$TIMESTAMP] Backup already exists or source not found"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# NetPlan DNS Configuration (Primary Method)
# ─────────────────────────────────────────────────────────────────────────────

apply_dns_netplan() {
  local dns_primary=$1
  local dns_secondary=$2
  local dns_name=$3
  local fallback_dns=$4
  
  local iface=$(get_active_interface)
  
  if [ -z "$iface" ]; then
    print_message "$RED" "✗ Could not detect active network interface."
    print_message "$YELLOW" "► Falling back to systemd-resolved method..."
    apply_dns_resolved "$dns_primary" "$dns_secondary" "$dns_name" "$fallback_dns"
    return
  fi
  
  local iface_type=$(get_interface_type "$iface")
  
  print_message "$CYAN" "► [$TIMESTAMP] Detected interface: $iface ($iface_type)"
  print_message "$YELLOW" "► [$TIMESTAMP] Configuring DNS via NetPlan..."
  print_message "$DIM" "  Primary: $dns_primary | Secondary: $dns_secondary"
  
  # Build DNS list
  local dns_list="$dns_primary, $dns_secondary"
  if [ -n "$fallback_dns" ]; then
    local formatted_fallback=$(echo "$fallback_dns" | sed 's/ /, /g')
    dns_list="$dns_list, $formatted_fallback"
  fi
  
  # Create NetPlan configuration
  cat <<EOF > "$NETPLAN_FILE"
# DNS Manager Configuration
# Generated: $TIMESTAMP
# DNS Provider: $dns_name
network:
  version: 2
  $iface_type:
    $iface:
      nameservers:
        addresses: [$dns_list]
        search: []
      dhcp4-overrides:
        use-dns: false
EOF

  print_message "$YELLOW" "► [$TIMESTAMP] Applying NetPlan configuration..."
  
  if netplan apply 2>/dev/null; then
    print_message "$GREEN" "✓ [$TIMESTAMP] NetPlan configuration applied successfully!"
    
    # Ensure resolv.conf symlink is correct
    if [ ! -L "$RESOLV_CONF" ] || [ "$(readlink "$RESOLV_CONF")" != "/run/systemd/resolve/stub-resolv.conf" ]; then
      ln -sf /run/systemd/resolve/stub-resolv.conf "$RESOLV_CONF"
    fi
    
    print_separator
    print_message "$GREEN" "✓ $dns_name DNS configured successfully via NetPlan!"
    print_separator
  else
    print_message "$RED" "✗ [$TIMESTAMP] NetPlan apply failed. Reverting..."
    rm -f "$NETPLAN_FILE"
    apply_dns_resolved "$dns_primary" "$dns_secondary" "$dns_name" "$fallback_dns"
    return
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# systemd-resolved DNS Configuration (Fallback Method)
# ─────────────────────────────────────────────────────────────────────────────

apply_dns_resolved() {
  local dns_primary=$1
  local dns_secondary=$2
  local dns_name=$3
  local fallback_dns=$4
  
  create_backup
  
  print_message "$YELLOW" "► [$TIMESTAMP] Configuring DNS via systemd-resolved..."
  print_message "$DIM" "  Primary: $dns_primary | Secondary: $dns_secondary"
  
  # Update DNS settings in resolved.conf
  sed -i '/^DNS=/d' "$SYSTEMD_CONF"
  sed -i '/^#DNS=/d' "$SYSTEMD_CONF"
  sed -i "/^\[Resolve\]/a DNS=$dns_primary $dns_secondary" "$SYSTEMD_CONF"
  
  # Update FallbackDNS
  sed -i '/^FallbackDNS=/d' "$SYSTEMD_CONF"
  sed -i '/^#FallbackDNS=/d' "$SYSTEMD_CONF"
  sed -i "/^\[Resolve\]/a FallbackDNS=$fallback_dns" "$SYSTEMD_CONF"
  
  # Disable DNSStubListener for compatibility
  sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/' "$SYSTEMD_CONF"
  sed -i 's/^DNSStubListener=.*/DNSStubListener=no/' "$SYSTEMD_CONF"
  
  print_message "$YELLOW" "► [$TIMESTAMP] Restarting systemd-resolved..."
  
  if systemctl restart systemd-resolved; then
    print_message "$GREEN" "✓ [$TIMESTAMP] systemd-resolved restarted successfully"
  else
    print_message "$RED" "✗ [$TIMESTAMP] Failed to restart systemd-resolved"
    return 1
  fi
  
  # Update resolv.conf symlink
  ln -sf /run/systemd/resolve/stub-resolv.conf "$RESOLV_CONF"
  
  print_separator
  print_message "$GREEN" "✓ $dns_name DNS configured successfully via systemd-resolved!"
  print_separator
}

# ─────────────────────────────────────────────────────────────────────────────
# Main Apply DNS Function
# ─────────────────────────────────────────────────────────────────────────────

apply_dns() {
  local dns_primary=$1
  local dns_secondary=$2
  local dns_name=$3
  local fallback_dns=$4
  
  echo ""
  print_separator
  print_message "$CYAN" "Applying $dns_name DNS Configuration"
  print_separator
  
  if check_netplan_installed; then
    apply_dns_netplan "$dns_primary" "$dns_secondary" "$dns_name" "$fallback_dns"
  else
    print_message "$YELLOW" "ℹ NetPlan not found. Using systemd-resolved."
    apply_dns_resolved "$dns_primary" "$dns_secondary" "$dns_name" "$fallback_dns"
  fi
  
  echo ""
  show_dns_table
}

# ─────────────────────────────────────────────────────────────────────────────
# DNS Provider Functions
# ─────────────────────────────────────────────────────────────────────────────

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

add_expressvpn_dns() {
  # ExpressVPN recommends OpenDNS servers for DNS configuration outside VPN
  apply_dns "208.67.222.222" "208.67.220.220" "ExpressVPN (OpenDNS)" "8.8.8.8 1.1.1.1"
}

# ─────────────────────────────────────────────────────────────────────────────
# NetPlan Remove/Deactivate, Reset and Rollback Functions
# ─────────────────────────────────────────────────────────────────────────────

remove_netplan_dns() {
  echo ""
  print_separator
  print_message "$YELLOW" "Removing/Deactivating NetPlan DNS Configuration"
  print_separator
  
  if [ ! -f "$NETPLAN_FILE" ]; then
    print_message "$YELLOW" "ℹ No NetPlan DNS configuration found at $NETPLAN_FILE"
    print_message "$DIM" "  The system is not using DNS Manager's NetPlan configuration."
    echo ""
    show_dns_table
    return
  fi
  
  # Show current NetPlan configuration before removal
  print_message "$CYAN" "► Current NetPlan DNS configuration:"
  echo -e "${DIM}"
  cat "$NETPLAN_FILE" 2>/dev/null | sed 's/^/  /'
  echo -e "${NC}"
  
  print_message "$YELLOW" "► [$TIMESTAMP] Removing NetPlan DNS configuration..."
  rm -f "$NETPLAN_FILE"
  
  if [ $? -eq 0 ]; then
    print_message "$GREEN" "✓ [$TIMESTAMP] NetPlan configuration file removed"
  else
    print_message "$RED" "✗ [$TIMESTAMP] Failed to remove NetPlan configuration file"
    return 1
  fi
  
  print_message "$YELLOW" "► [$TIMESTAMP] Applying NetPlan changes..."
  
  if netplan apply 2>/dev/null; then
    print_message "$GREEN" "✓ [$TIMESTAMP] NetPlan changes applied successfully"
  else
    print_message "$RED" "✗ [$TIMESTAMP] Failed to apply NetPlan changes"
    print_message "$YELLOW" "  Try running: sudo netplan apply"
    return 1
  fi
  
  # Ensure resolv.conf symlink is correct
  print_message "$YELLOW" "► [$TIMESTAMP] Verifying resolv.conf symlink..."
  ln -sf /run/systemd/resolve/stub-resolv.conf "$RESOLV_CONF"
  
  # Restart systemd-resolved to pick up changes
  if systemctl restart systemd-resolved 2>/dev/null; then
    print_message "$GREEN" "✓ [$TIMESTAMP] systemd-resolved restarted"
  fi
  
  print_separator
  print_message "$GREEN" "✓ NetPlan DNS Configuration Removed!"
  print_message "$DIM" "  DNS will now use system defaults or DHCP-provided servers."
  print_separator
  
  echo ""
  show_dns_table
}

reset_resolv_conf() {
  echo ""
  print_separator
  print_message "$YELLOW" "Resetting resolv.conf to System Default"
  print_separator
  
  local changes_made=false
  
  # Remove NetPlan DNS configuration if exists
  if [ -f "$NETPLAN_FILE" ]; then
    print_message "$YELLOW" "► [$TIMESTAMP] Removing NetPlan DNS configuration..."
    rm -f "$NETPLAN_FILE"
    
    if netplan apply 2>/dev/null; then
      print_message "$GREEN" "✓ [$TIMESTAMP] NetPlan configuration removed"
      changes_made=true
    else
      print_message "$RED" "✗ [$TIMESTAMP] Failed to apply NetPlan changes"
    fi
  fi
  
  # Restore systemd-resolved defaults
  if [ -f "$SYSTEMD_CONF" ]; then
    print_message "$YELLOW" "► [$TIMESTAMP] Restoring systemd-resolved defaults..."
    
    # Remove custom DNS and FallbackDNS entries
    sed -i '/^DNS=/d' "$SYSTEMD_CONF"
    sed -i '/^FallbackDNS=/d' "$SYSTEMD_CONF"
    
    # Re-enable default DNSStubListener
    sed -i 's/^DNSStubListener=no/#DNSStubListener=yes/' "$SYSTEMD_CONF"
    
    if systemctl restart systemd-resolved 2>/dev/null; then
      print_message "$GREEN" "✓ [$TIMESTAMP] systemd-resolved restarted with defaults"
      changes_made=true
    else
      print_message "$RED" "✗ [$TIMESTAMP] Failed to restart systemd-resolved"
    fi
  fi
  
  # Ensure proper symlink
  print_message "$YELLOW" "► [$TIMESTAMP] Restoring resolv.conf symlink..."
  ln -sf /run/systemd/resolve/stub-resolv.conf "$RESOLV_CONF"
  print_message "$GREEN" "✓ [$TIMESTAMP] resolv.conf symlink restored"
  
  if [ "$changes_made" = true ]; then
    print_separator
    print_message "$GREEN" "✓ DNS Reset to System Default Complete!"
    print_separator
  else
    print_message "$YELLOW" "ℹ System was already using default configuration"
  fi
  
  echo ""
  show_dns_table
}

rollback_dns() {
  echo ""
  print_separator
  print_message "$YELLOW" "Rolling Back DNS Configuration"
  print_separator
  
  local restored=false
  
  # Remove NetPlan config if exists
  if [ -f "$NETPLAN_FILE" ]; then
    print_message "$YELLOW" "► [$TIMESTAMP] Removing NetPlan configuration..."
    rm -f "$NETPLAN_FILE"
    
    if netplan apply 2>/dev/null; then
      print_message "$GREEN" "✓ [$TIMESTAMP] NetPlan configuration rolled back"
      restored=true
    else
      print_message "$RED" "✗ [$TIMESTAMP] Failed to apply NetPlan rollback"
    fi
  fi
  
  # Restore systemd-resolved from backup
  if [ -f "$BACKUP_CONF" ]; then
    print_message "$YELLOW" "► [$TIMESTAMP] Restoring systemd-resolved from backup..."
    cp "$BACKUP_CONF" "$SYSTEMD_CONF"
    print_message "$GREEN" "✓ [$TIMESTAMP] Restored original resolved.conf"
    
    if systemctl restart systemd-resolved 2>/dev/null; then
      print_message "$GREEN" "✓ [$TIMESTAMP] systemd-resolved restarted"
      restored=true
    else
      print_message "$RED" "✗ [$TIMESTAMP] Failed to restart systemd-resolved"
    fi
  fi
  
  if [ "$restored" = false ]; then
    print_message "$YELLOW" "ℹ No custom configuration found to rollback"
  fi
  
  # Ensure proper symlink
  ln -sf /run/systemd/resolve/stub-resolv.conf "$RESOLV_CONF"
  
  print_separator
  print_message "$GREEN" "✓ DNS Rollback Complete!"
  print_separator
  
  echo ""
  show_dns_table
}

# ─────────────────────────────────────────────────────────────────────────────
# Main Interactive Loop
# ─────────────────────────────────────────────────────────────────────────────

main() {
  while true; do
    show_menu
    echo -n -e "${WHITE}Choose an option: ${NC}"
    read -r choice
    
    case $choice in
      1) add_shekan_pro ;;
      2) add_shekan_free ;;
      3) add_arvan_dns ;;
      4) add_google_dns ;;
      5) add_cloudflare_dns ;;
      6) add_quad9_dns ;;
      7) add_opendns ;;
      8) add_adguard_dns ;;
      9) add_expressvpn_dns ;;
      [Nn]) remove_netplan_dns ;;
      [Rr]) reset_resolv_conf ;;
      [Bb]) rollback_dns ;;
      0)
        echo ""
        print_message "$GREEN" "✓ Exiting DNS Manager. Goodbye!"
        echo ""
        exit 0
        ;;
      *)
        print_message "$RED" "✗ Invalid option. Please try again."
        ;;
    esac
    
    echo ""
    echo -e "${DIM}Press Enter to continue...${NC}"
    read -r
  done
}

# Run main function
main
