#!/usr/bin/env bash
set -Eeuo pipefail

conf="/etc/dnsmasq.conf"

if [ ! -f "$conf" ]; then
  conf="/etc/dnsmasq.custom"
  rm -f "$conf"
  cp /etc/dnsmasq.default "$conf"
  [ -n "$DNS1" ] && sed -i -e "s/1.0.0.1/$DNS1/g" "$conf"
  [ -n "$DNS2" ] && sed -i -e "s/1.1.1.1/$DNS2/g" "$conf"
fi

exec dnsmasq "--conf-file=$conf" --no-daemon --no-resolv
