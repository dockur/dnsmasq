#!/usr/bin/env bash
set -Eeuo pipefail

conf="/etc/dnsmasq.conf"

# Check if config file is not a directory
if [ -d "$conf" ]; then
    echo "The bind $conf maps to a file that does not exist!"
    exit 1
fi

if [ ! -f "$conf" ]; then
  conf="/etc/dnsmasq.custom"
  template="/etc/dnsmasq.default"
  
  if [ ! -f "$template" ]; then
    echo "Your /etc directory does not contain a valid dnsmasq.conf file!"
    exit 1
  fi
  
  rm -f "$conf"
  cp "$template"  "$conf"
  
  [ -n "$DNS1" ] && sed -i -e "s/1.0.0.1/$DNS1/g" "$conf"
  [ -n "$DNS2" ] && sed -i -e "s/1.1.1.1/$DNS2/g" "$conf"
  
  if [ -n "$DNS3" ]; then
    echo "server=$DNS3" >> "$conf"
  fi
  
  if [ -n "$DNS4" ]; then
    echo "server=$DNS4" >> "$conf"
  fi
  
  if [ -n "$CACHE_SIZE" ]; then
    sed -i -e "s/^cache-size=.*/cache-size=$CACHE_SIZE/g" "$conf"
  fi
  
  if [ "$DOMAIN_NEEDED" = "true" ]; then
    sed -i -e "s/^#domain-needed/domain-needed/g" "$conf"
  fi
  
  if [ "$LOG_QUERIES" = "true" ]; then
    sed -i -e "s/^#log-queries/log-queries/g" "$conf"
  fi
fi

exec dnsmasq "--conf-file=$conf" --no-daemon --no-resolv
