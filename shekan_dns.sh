#!/bin/bash

SYSTEMD_CONF="/etc/systemd/resolved.conf"
BACKUP_CONF="/etc/systemd/resolved.conf.backup"

add_shekan_dns() {
  echo "[+] Adding Shekan free DNS..."

  # Backup original config if not already backed up
  if [ ! -f "$BACKUP_CONF" ]; then
    cp "$SYSTEMD_CONF" "$BACKUP_CONF"
    echo "[+] Backup created at $BACKUP_CONF"
  else
    echo "[i] Backup already exists: $BACKUP_CONF"
  fi

  # Update DNS to Shekan
  sed -i 's/^#DNS=.*/DNS=178.22.122.100 185.51.200.2/' $SYSTEMD_CONF ||
    echo "DNS=178.22.122.100 185.51.200.2" >>$SYSTEMD_CONF

  # Ensure DNSStubListener=no
  sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/' $SYSTEMD_CONF
  sed -i 's/^DNSStubListener=.*/DNSStubListener=no/' $SYSTEMD_CONF

  # Link resolv.conf to systemd-resolved
  ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

  systemctl restart systemd-resolved

  echo "[+] Shekan DNS applied successfully!"
}

rollback_dns() {
  echo "[+] Rolling back DNS settings..."

  if [ -f "$BACKUP_CONF" ]; then
    cp "$BACKUP_CONF" "$SYSTEMD_CONF"
    echo "[+] Restored original resolved.conf"
  else
    echo "[!] No backup found. Applying default settings."

    # Restore minimal defaults
    cat <<EOF >$SYSTEMD_CONF
[Resolve]
DNS=
FallbackDNS=
DNSStubListener=yes
EOF
  fi

  ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

  systemctl restart systemd-resolved

  echo "[+] DNS rollback completed."
}

clear
echo "======================================="
echo "     Shekan DNS Manager (systemd)       "
echo "======================================="
echo "1) Add Shekan free DNS"
echo "2) Roll back DNS settings"
echo -n "Choose an option (1/2): "
read choice

case $choice in
1) add_shekan_dns ;;
2) rollback_dns ;;
*)
  echo "Invalid option"
  exit 1
  ;;
esac
