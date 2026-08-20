#!/usr/bin/env bash
set -Eeuo pipefail

conf="/etc/dnsmasq.conf"

enabled() {
  case "${1:-}" in
    Y|y|YES|Yes|yes|TRUE|True|true|1|ON|On|on) return 0 ;;
    *) return 1 ;;
  esac
}

has_global_server() {
  local file

  for file in /etc/dnsmasq.d/*.conf; do
    [ -f "$file" ] || continue
    grep -Eq '^[[:space:]]*server=[[:space:]]*[^/[:space:]]' "$file" && return 0
  done

  return 1
}

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

  if ! has_global_server; then
    [ -n "${DNS1:-}" ] && echo "server=$DNS1" >> "$conf"
    [ -n "${DNS2:-}" ] && echo "server=$DNS2" >> "$conf"
    [ -n "${DNS3:-}" ] && echo "server=$DNS3" >> "$conf"
    [ -n "${DNS4:-}" ] && echo "server=$DNS4" >> "$conf"
  fi
  
  if [ -n "${CACHE_SIZE:-}" ]; then
    echo "cache-size=$CACHE_SIZE" >> "$conf"
  fi

  if enabled "${DOMAIN_NEEDED:-}"; then
    echo "domain-needed" >> "$conf"
  fi

  if enabled "${LOG_QUERIES:-}"; then
    echo "log-queries" >> "$conf"
  fi

fi

exec dnsmasq "--conf-file=$conf" --keep-in-foreground --log-facility=- --no-resolv
