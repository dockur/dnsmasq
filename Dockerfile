FROM alpine:edge

EXPOSE 53/udp
EXPOSE 53 8080

ENV WEBPROC_VERSION 0.4.0

RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  file="webproc_${WEBPROC_VERSION}_linux_amd64.gz" ;; \
         "linux/arm64")  file="webproc_${WEBPROC_VERSION}_linux_arm64.gz" ;; \
         "linux/arm"*)   file="webproc_${WEBPROC_VERSION}_linux_armv7.gz" ;; \
         *) exit 1 ;; \
    esac \
  && apk add --no-cache dnsmasq \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL https://github.com/jpillora/webproc/releases/download/v$WEBPROC_VERSION/$file | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps \
  && rm -rf /tmp/* /var/cache/apk/*
 
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq

COPY dnsmasq.conf /etc/dnsmasq.conf

ENTRYPOINT ["webproc","--config","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
