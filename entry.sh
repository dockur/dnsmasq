#!/usr/bin/env bash
set -Eeuo pipefail

exec dnsmasq --no-daemon --user=dnsmasq --group=dnsmasq
