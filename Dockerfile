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

  # Configure default dnsmasq template
  mv /etc/dnsmasq.conf /etc/dnsmasq.default
  printf '\nuser=dnsmasq\ngroup=dnsmasq\ninterface=*\n' >> /etc/dnsmasq.default

  rm -rf /tmp/* /var/cache/apk/*
EOF

COPY --chmod=755 entrypoint.sh /usr/bin/dnsmasq.sh

ENV DNS1="1.0.0.1"
ENV DNS2="1.1.1.1"

EXPOSE 53/tcp 53/udp 67/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/dnsmasq.sh"]
