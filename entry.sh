#!/usr/bin/env bash
set -Eeuo pipefail

[ -n "$DNS1" ] && sed -i -e "s/1.0.0.1/$DNS1/g" /etc/dnsmasq.conf
[ -n "$DNS2" ] && sed -i -e "s/1.1.1.1/$DNS2/g" /etc/dnsmasq.conf

exec dnsmasq --no-daemon --user=dnsmasq --group=dnsmasq
