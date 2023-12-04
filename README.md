# Alpine :: Certbot
![size](https://img.shields.io/docker/image-size/11notes/certbot/2.6.0?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/certbot?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/certbot?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-certbot?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-certbot?color=c91cb8)

Run LetsEncrypt Certbot based on Alpine Linux. Small, lightweight, secure and fast 🏔️

This container will start a nginx webserver on port 8080 to retrieve certs via http method (default). It will also redirect any FQDN from HTTP to HTTPS. Certificate retrieval via DNS is possible too.

## Volumes
* **/certbot/etc** - Directory of config.yaml and dns.ini
* **/certbot/var** - Directory of all certs

## Run
```shell
docker run --name certbot \
  -v ../etc:/certbot/etc \
  -v ../var:/certbot/var \
  -d 11notes/certbot:[tag]
```

## Tools
Issue an interactive DNS challenge certificate (no account will be created, no email needed).
```shell
docker run --name certbot \
  -v ../var:/certbot/var \
  -d 11notes/certbot:[tag] \
    renew-man-dns "mycertificate" "-d *.domain.com -d www.domain.com"
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /certbot | home directory of user docker |

## Environment
| Parameter | Value | Default |
| --- | --- | --- |
| `DNS_RFC2136_PROPAGATION_SECONDS` | time in seconds to wait for DNS propagation | 60 |
| `KEY_TYPE` | set key type for renew-man-dns (rsa or ecdsa) | ecdsa |

## /certbot/etc/config.yaml
```shell
certificates:
  - name: "com.domain"
    email: "info@domain.com"
    fqdn:
      - domain.com
      - www.domain.com
  - name: "com.contoso"
    email: "info@contoso.com"
    dns: true
    fqdn:
      - contoso.com
  - name: "com.microsoft"
    email: "info@microsoft.com"
    key: rsa
    fqdn:
      - microsoft.com
      - www.microsoft.com
```

## create or update certificates
```shell
docker exec certbot renew
```

This will create all kinds of certificates (key, crt, fullchain, pfx, pk8) in the directory "/certbot/var". The generated *.pfx has no password! You can then mount the same docker volume (/certbot/var) in another container to use the generated certificates (i.e. nginx webserver). If dns is set to true, certbot will use /certbot/etc/dns.ini to connect to your RFC2136 enabled DNS server and retrieve certificates via DNS. Default is HTTP method.

## Parent Image
* [11notes/nginx:stable](https://github.com/11notes/docker-nginx)

## Built with and thanks to
* [certbot](https://certbot.eff.org)
* [nginx](https://nginx.org)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Only use rootless container runtime (podman, rootless docker)
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy (haproxy, traefik, nginx)