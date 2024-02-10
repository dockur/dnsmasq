FROM alpine:edge

RUN apk --no-cache add \
  tini \
  bash \
  dnsmasq && \
  rm -rf /tmp/* /var/cache/apk/*
 
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq

COPY dnsmasq.conf /etc/dnsmasq.default

COPY entry.sh /usr/bin/dnsmasq.sh
RUN chmod +x /usr/bin/dnsmasq.sh

ENV DNS1 "1.0.0.1"
ENV DNS2 "1.1.1.1"

EXPOSE 53/tcp 53/udp 67/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/dnsmasq.sh"]
