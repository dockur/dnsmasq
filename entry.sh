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

  [ -n "${DNS1:-}" ] && echo "server=$DNS1" >> "$conf"
  [ -n "${DNS2:-}" ] && echo "server=$DNS2" >> "$conf"
  [ -n "${DNS3:-}" ] && echo "server=$DNS3" >> "$conf"
  [ -n "${DNS4:-}" ] && echo "server=$DNS4" >> "$conf"
  
  if [ -n "${CACHE_SIZE:-}" ]; then
    sed -i -e "s/^cache-size=.*/cache-size=$CACHE_SIZE/g" "$conf"
  fi
  
  if [ -n "${DOMAIN_NEEDED:-}" ]; then
    sed -i -e "s/^#domain-needed/domain-needed/g" "$conf"
  fi
  
  if [ -n "${LOG_QUERIES:-}" ]; then
    sed -i -e "s/^#log-queries/log-queries/g" "$conf"
  fi

fi

exec dnsmasq "--conf-file=$conf" --no-daemon --no-resolv
