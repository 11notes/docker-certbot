![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - Certbot
![size](https://img.shields.io/docker/image-size/11notes/certbot/2.7.4?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/certbot/2.7.4?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/certbot?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-certbot?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-certbot?color=c91cb8) ![stars](https://img.shields.io/docker/stars/11notes/certbot?color=e6a50e)

# SYNOPSIS
With this image you can create certificates from Let’s Encrypt via different modules. This image will start a Nginx webserver listening for the HTTP challenge. It will produce all different kind of certificates that can then be used in other systems. It will also call an optional webhook on each certificate renewal (success or fail). As a bonus, it will redirect all HTTP calls (not from Certbot) permanent to HTTPS.

Simply configure your desired certificates via yaml (`/certbot/etc/config.yaml`). Configure each module with the information it needs. After that you can periodically run `docker exec certbot renew`. Certbot will then automatically renew or create all certificates defined in `config.yaml`, it will clean up expired certificates and create additional certificate types (`*.pfx, *.pk8`) as well as a tar with all files. If you set the `WEBHOOK_URL`, it will call the webhook on each renewal attempt.

Why use this image at all and not simply use Certbot with Traefik? Simple answer: All though most systems can be proxies via Traefik or other reverse proxies that can auto update their certificates themselves, a lot of systems that can’t be proxied still need valid SSL certificates (like database authentication, MQTT, SMTP, RDP and so on). Since this image will create valid SSL certificates and call a possible webhook on each success or fail, that webhook can be used to update the certificates on these non-proxy systems.

# VOLUMES
* **/certbot/etc** - Directory of config.yaml and dns.ini
* **/certbot/var** - Directory of all certs

# RUN
```shell
docker run --name certbot \
  -p 8080:8080/tcp \
  -v .../etc:/certbot/etc \
  -v .../var:/certbot/var \
  -d 11notes/certbot:[tag]
```

# CONFIG (EXAMPLE)
/certbot/etc/config.yaml
```yaml
certificates:
  # name must be unique and is used for the file names
  - name: "com.domain"
    email: "info@domain.com"
    # up to 100 FQDN or wildcard allowed
    fqdn:
      - domain.com
      - www.domain.com
  - name: "com.contoso"
    email: "info@contoso.com"
    # define module to use
    module: rfc2136
    fqdn:
      - contoso.com
  - name: "com.microsoft"
    email: "info@microsoft.com"
    # use RSA instead of ECDSA
    key: rsa
    fqdn:
      - microsoft.com
      - www.microsoft.com
```

Traefik redirect HTTP:80 to certbot container:
```
(HostRegexp(`{host:.+}`) && PathPrefix(`/.well-known/acme-challenge`))
```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` |  | home directory of user docker |
| `api` | http://${IP}:8080 | Certbot endpoint |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |
| `KEY_TYPE` | set key type (RSA or ECDSA) | ECDSA |
| `WEBHOOK_URL` | Will call `PUT https://api.domain.com/com.domain` with a json payload |  |

# AVAILABLE MODULES
| Module | Parameter | Description | Default |
| --- | --- | --- | --- |
| `http` | HTTP_PORT | port used for HTTP challenge | 80 |
| `rfc2136` | RFC2136_PROPAGATION_SECONDS | time in seconds to wait for DNS propagation | 60 |
| `rfc2136` | RFC2136_CREDENTIALS | path to dns.ini | /certbot/etc/dns.ini |

# PARENT IMAGE
* [11notes/node:stable](https://hub.docker.com/r/11notes/node)

# BUILT WITH
* [certbot](https:/certbot.eff.org)
* [nginx](https://nginx.org)
* [alpine](https://alpinelinux.org)

# TIPS
* Only use rootless container runtime (podman, rootless docker)
* Allow non-root ports < 1024 via `echo "net.ipv4.ip_unprivileged_port_start=53" > /etc/sysctl.d/ports.conf`
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes.
    