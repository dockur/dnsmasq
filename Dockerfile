# syntax=docker/dockerfile:1

FROM alpine:edge

RUN <<EOF
  set -eu

  apk update
  apk upgrade
  apk --no-cache add \
    tini \
    bash \
    dnsmasq-dnssec

  # Configure dnsmasq defaults
  mkdir -p /etc/default/
  printf 'ENABLED=1\nIGNORE_RESOLVCONF=yes\n' > /etc/default/dnsmasq

  # Remove default dnsmasq config
  rm -f /etc/dnsmasq.conf

  rm -rf /tmp/* /var/cache/apk/*
EOF

COPY --chmod=755 entry.sh /usr/bin/dnsmasq.sh
COPY --chmod=664 dnsmasq.conf /etc/dnsmasq.default

ENV DNS1="1.0.0.1"
ENV DNS2="1.1.1.1"

EXPOSE 53/tcp 53/udp 67/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/dnsmasq.sh"]
