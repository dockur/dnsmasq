<h1 align="center">dnsmasq<br />
<div align="center">
<a href="https://github.com/dockur/dnsmasq"><img src="https://raw.githubusercontent.com/dockur/dnsmasq/master/.github/logo.png" title="Logo" style="max-width:100%;" width="256" /></a>
</div>
<div align="center">

[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Package]][pkg_url]
[![Pulls]][hub_url]

</div></h1>

Docker container of [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html), an open-source DNS server.

## Features ✨

- Provides a lightweight DNS/DHCP server
- Forwards DNS queries to upstream resolvers
- Supports local hostname and domain resolution
- Supports DHCP leases and static reservations
- Supports custom DNS records and hosts files
- Allows custom `dnsmasq.conf` configuration
- Lightweight Alpine-based image

## Usage  🐳

##### Docker Compose:

```yaml
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
    restart: always
```

##### Docker CLI:

```bash
docker run -it --rm --name dnsmasq -p 53:53/udp -p 53:53/tcp -e "DNS1=1.0.0.1" -e "DNS2=1.1.1.1" docker.io/dockurr/dnsmasq
```

## Configuration ⚙️

You can set the `DNS1` till `DNS4` environment variables to configure the upstream DNS
servers.

For example, you can set them to the public [Cloudflare](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) servers like this:

```yaml
environment:
  DNS1: "1.0.0.1"
  DNS2: "1.1.1.1"
```

You can extend the default configuration template with a volume that mounts a directory containing `*.conf` configuration files:

```yaml
volumes:
  - ./dnsmasq.d/:/etc/dnsmasq.d/
```

You can also provide a custom main configuration with a volume that binds your own `dnsmasq.conf` file:

```yaml
volumes:
  - ./dnsmasq.conf:/etc/dnsmasq.conf
```

## FAQ 💬

  * ### How to setup the DNS server?

  By default, dnsmasq acts as a forwarding DNS server. Queries that cannot be answered locally are forwarded to the upstream DNS servers configured with `DNS1` till `DNS4`:

  ```yaml
  environment:
    DNS1: "1.0.0.1"
    DNS2: "1.1.1.1"
  ```

  Clients can then use the IP address of the host running this container as their DNS server.

  Dnsmasq also caches DNS responses, so repeated queries can be answered locally without contacting the upstream resolver again.

  The cache size can be adjusted with the `CACHE_SIZE` environment variable:

  ```yaml
  environment:
    CACHE_SIZE: "1000"
  ```

  You can also provide local DNS records through `/etc/dnsmasq.d/`. For example, create `./dnsmasq.d/local.conf` with:

  ```ini
  address=/server.home/192.168.1.10
  address=/printer.home/192.168.1.20
  ```

  and mount the directory into the container:

  ```yaml
  volumes:
    - ./dnsmasq.d/:/etc/dnsmasq.d/
  ```

  These names are answered locally, while all other queries continue to be forwarded to the configured upstream DNS servers.

  * ### How do `DNS1` till `DNS4` interact with custom configuration?

  `DNS1` till `DNS4` configure the default upstream DNS servers when the image uses its generated configuration.

  If you provide your own `/etc/dnsmasq.conf`, these environment variables are ignored:

  ```yaml
  volumes:
    - ./dnsmasq.conf:/etc/dnsmasq.conf
  ```

  If you extend the default configuration through `/etc/dnsmasq.d/` and define your own global upstream server:

  ```ini
  server=192.168.1.1
  ```

  the default upstream servers are not added.

  Domain-specific servers do not replace the default upstreams. For example:

  ```ini
  server=/example.local/192.168.1.1
  ```

  only changes resolution for `example.local`.

  * ### How to setup the DHCP server?

  To use dnsmasq as a DHCP server, the container will need additional network capabilities added to your compose file:

  ```yaml
  cap_add:
    - NET_RAW
    - NET_ADMIN
  ```

  `NET_RAW` allows dnsmasq to check whether an address is already in use before assigning it to a client. `NET_ADMIN` is required for network operations used by DHCP, such as managing ARP entries.

  The container must also be reachable by DHCP clients on UDP port `67`. Because DHCP discovery uses broadcast traffic, normal container bridge networking may not be suitable.

  On Linux, the simplest option is usually host networking:

  ```yaml
  services:
    dnsmasq:
      image: dockurr/dnsmasq
      network_mode: host
      cap_add:
        - NET_RAW
        - NET_ADMIN
      volumes:
        - ./dnsmasq.d/:/etc/dnsmasq.d/
      restart: always
  ```

  Alternatively, you can use a network driver such as `macvlan` or `ipvlan` when the container should have its own address on the local network.

  DHCP is enabled by adding a `dhcp-range` to the dnsmasq configuration. For example, create `./dnsmasq.d/dhcp.conf` with:

  ```ini
  dhcp-range=192.168.1.100,192.168.1.200,255.255.255.0,12h
  ```

  This assigns addresses from `192.168.1.100` through `192.168.1.200` with a lease time of 12 hours.

  * ### Port 53 is already in use?

  If another process on the host is already listening on port `53`, the container may fail to start with an error similar to:

  ```text
  Error response from daemon: driver failed programming external connectivity on
  endpoint dnsmasq (...): Error starting userland proxy: listen tcp4 0.0.0.0:53:
  bind: address already in use
  ```

  On Linux, you can check which process is using port `53` with:

  ```bash
  sudo ss -lntup | grep ':53'
  ```

  A common example is `systemd-resolved`, but other DNS services such as `bind`, `unbound`, or another dnsmasq instance may also be using the port.

  If the service only occupies port `53` on one host address, you can bind the container to a different address:

  ```yaml
  ports:
    - "192.168.1.10:53:53/udp"
    - "192.168.1.10:53:53/tcp"
  ```

  Otherwise, stop or reconfigure the conflicting service before starting the container.

## Stars 🌟
[![Stargazers](https://raw.githubusercontent.com/star-stats/stars/refs/heads/data/charts/dockur-dnsmasq.svg)](https://github.com/dockur/dnsmasq/stargazers)

[build_url]: https://github.com/dockur/dnsmasq/
[hub_url]: https://hub.docker.com/r/dockurr/dnsmasq
[tag_url]: https://hub.docker.com/r/dockurr/dnsmasq/tags
[pkg_url]: https://github.com/dockur/dnsmasq/pkgs/container/dnsmasq

[Build]: https://github.com/dockur/dnsmasq/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/dockurr/dnsmasq/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/dockurr/dnsmasq.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/dockurr/dnsmasq/latest?arch=amd64&sort=semver&color=066da5
[Package]: https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fipitio.github.io%2Fbackage%2Fdockur%2Fdnsmasq%2Fdnsmasq.json&query=%24.downloads&logo=github&style=flat&color=066da5&label=pulls
