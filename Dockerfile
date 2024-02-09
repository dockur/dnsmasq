FROM alpine:edge

RUN apk add --no-cache dnsmasq \
  && rm -rf /tmp/* /var/cache/apk/*
 
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq

COPY dnsmasq.conf /etc/dnsmasq.conf

EXPOSE 53/tcp 53/udp 67/udp

ENTRYPOINT ["dnsmasq", "--no-daemon", "--user=dnsmasq", "--group=dnsmasq"]
