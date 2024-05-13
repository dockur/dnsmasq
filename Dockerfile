FROM alpine:edge

RUN apk --no-cache add \
  tini \
  bash \
  dnsmasq-dnssec && \
  rm -rf /tmp/* /var/cache/apk/*

RUN set -eu && \
    mkdir -p /etc/default/  && \
    echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq && \
    rm -f /etc/dnsmasq.conf

COPY --chmod=755 entry.sh /usr/bin/dnsmasq.sh
COPY --chmod=644 dnsmasq.conf /etc/dnsmasq.default

ENV DNS1 "1.0.0.1"
ENV DNS2 "1.1.1.1"

EXPOSE 53/tcp 53/udp 67/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/dnsmasq.sh"]
