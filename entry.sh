#!/usr/bin/env bash
set -Eeuo pipefail

conf="/etc/dnsmasq.conf"

# Check if config file is not a directory
if [ -d "$conf" ]; then

    echo "The file $conf does not exist, please check that you mapped it to a valid path!"
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

fi

exec dnsmasq "--conf-file=$conf" --no-daemon --no-resolv
