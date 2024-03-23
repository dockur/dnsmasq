<div align="center">
<a href="https://github.com/dockur/dnsmasq"><img src="https://raw.githubusercontent.com/dockur/dnsmasq/master/.github/logo.png" title="Logo" style="max-width:100%;" width="256" /></a>
</div>
<div align="center">

[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Pulls]][hub_url]

</div></h1>

Docker container of dnsmasq, an open-source DNS and DHCP server.

## How to use

Via `docker-compose`

```yaml
version: "3"
services:
  dnsmasq:
    image: dockurr/dnsmasq
    container_name: dnsmasq
    environment:
      DNS1: "1.0.0.1"
      DNS2: "1.1.1.1"
    ports:
      - 53:53/udp
      - 53:53/tcp
    cap_add:
      - NET_ADMIN
    restart: on-failure
```

Via `docker run`

```bash
docker run -it --rm -p 53:53/udp -p 53:53/tcp -e "DNS1=1.0.0.1" -e "DNS2=1.1.1.1" --cap-add=NET_ADMIN dockurr/dnsmasq
```

## Configuration

You can set the `DNS1` and `DNS2` environment variables to change which upstream DNS
servers to use. In the examples above they are set to the public [Cloudflare](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) servers. 

You can add to or extend the [default configuration](https://github.com/dockur/dnsmasq/blob/master/dnsmasq.conf) with a volume that bind mounts a
directory containing `*.conf` configuration files:

    ```yaml
    volumes:
      - /example/dnsmasq.d/:/etc/dnsmasq.d/
    ```

You can also override the [default configuration](https://github.com/dockur/dnsmasq/blob/master/dnsmasq.conf) completely with a volume that bind mounts a custom `dnsmasq.conf` file:

    ```yaml
    volumes:
      - /example/dnsmasq.conf:/etc/dnsmasq.conf
    ```

## FAQ

  * ### Something is already binding to port `53`, how do I workaround that?

  If some process on the host is already binding port `53` you may see an error similar
  to the following:

  ```
  Error response from daemon: driver failed programming external connectivity on
  endpoint dnsmasq (...): Error starting userland proxy: listen tcp4 0.0.0.0:53: bind:
  address already in use
  ```

  You can inspect which process is binding to that port:

  ```bash
  $ netstat -lnpt | grep -E ':53 +'
  tcp    0    0 127.0.0.53:53    0.0.0.0:*    LISTEN    197/systemd-resolve
  ```

  On hosts running `# systemd`, such as in this example, you can workaround this by
  specifying the IP addresses on which to bind port `53`, for example:

  ```yaml
  ports:
    - "192.168.1.###:53:53/udp"
    - "192.168.1.###:53:53/tcp"
  ```

  There are many other host-specific cases where some process and configuration binds
  port `53`. It may be an unused DNS daemon, such as `# bind`, that needs to be
  uninstalled or disabled or a number of other causes but finding out which process is
  binding the port is a good place to start debugging.

## Stars
[![Stars](https://starchart.cc/dockur/dnsmasq.svg?variant=adaptive)](https://starchart.cc/dockur/dnsmasq)

[build_url]: https://github.com/dockur/dnsmasq/
[hub_url]: https://hub.docker.com/r/dockurr/dnsmasq
[tag_url]: https://hub.docker.com/r/dockurr/dnsmasq/tags

[Build]: https://github.com/dockur/dnsmasq/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/dockurr/dnsmasq/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/dockurr/dnsmasq.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/dockurr/dnsmasq/latest?arch=amd64&sort=semver&color=066da5
