#!/bin/bash

SYSTEMD_CONF="/etc/systemd/resolved.conf"
BACKUP_CONF="/etc/systemd/resolved.conf.backup"

add_shekan_pro() {
  echo "[+] Adding Shekan free DNS=178.22.122.101 185.51.200.1"

  # Backup original config if not already backed up
  if [ ! -f "$BACKUP_CONF" ]; then
    cp "$SYSTEMD_CONF" "$BACKUP_CONF"
    echo "[+] Backup created at $BACKUP_CONF"
  else
    echo "[i] Backup already exists: $BACKUP_CONF"
  fi

  # Update DNS to Shekan
  sed -i 's/^#DNS=.*/DNS=178.22.122.101 185.51.200.1/' $SYSTEMD_CONF ||
  echo "DNS=178.22.122.101 185.51.200.1" >>$SYSTEMD_CONF

  # Add DNS Fallback
  sed -i 's/^#FallbackDNS=.*/FallbackDNS=8.8.8.8/' $SYSTEMD_CONF
  sed -i 's/^FallbackDNS=.*/FallbackDNS=8.8.8.8/' $SYSTEMD_CONF

  # Ensure DNSStubListener=no
  sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/' $SYSTEMD_CONF
  sed -i 's/^DNSStubListener=.*/DNSStubListener=no/' $SYSTEMD_CONF

  # Link resolv.conf to systemd-resolved
  ln -sf /etc/systemd/resolved.conf /etc/resolved.conf

  systemctl restart systemd-resolved
  echo "--------------------------------------------------------------"
  cat /etc/resolved.conf
  echo "--------------------------------------------------------------"
  echo "[+] Shekan DNS applied successfully!"
}

add_shekan_Free() {
  echo "[+] Adding Shekan free DNS=178.22.122.100 185.51.200.2"

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
  
  # Add DNS Fallback
  sed -i 's/^#FallbackDNS=.*/FallbackDNS=8.8.8.8/' $SYSTEMD_CONF
  sed -i 's/^FallbackDNS=.*/FallbackDNS=8.8.8.8/' $SYSTEMD_CONF

  # Ensure DNSStubListener=no
  sed -i 's/^#DNSStubListener=.*/DNSStubListener=no/' $SYSTEMD_CONF
  sed -i 's/^DNSStubListener=.*/DNSStubListener=no/' $SYSTEMD_CONF

  # Link resolv.conf to systemd-resolved
  ln -sf /etc/systemd/resolved.conf /etc/resolved.conf

  systemctl restart systemd-resolved
  echo "--------------------------------------------------------------"
  cat /etc/resolved.conf
  echo "--------------------------------------------------------------"
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
# This is /run/systemd/resolve/resolv.conf managed by man:systemd-resolved(8).
# Do not edit.
#
# This file might be symlinked as /etc/resolv.conf. If you're looking at
# /etc/resolv.conf and seeing this text, you have followed the symlink.
#
# This is a dynamic resolv.conf file for connecting local clients directly to
# all known uplink DNS servers. This file lists all configured search domains.
#
# Third party programs should typically not access this file directly, but only
# through the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

[Resolve]
#DNS=
#FallbackDNS=
#DNSStubListener=yes
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
echo "1) Add Pro Shekan"
echo "2) Add Free Shekan"
echo "3) Roll back DNS settings"
echo -n "Choose an option (1~3): "
read choice

case $choice in
1) add_shekan_pro ;;
2) add_shekan_dns ;;
3) rollback_dns ;;
*)
  echo "Invalid option"
  exit 1
  ;;
esac
