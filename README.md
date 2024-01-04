# Alpine :: Certbot
![size](https://img.shields.io/docker/image-size/11notes/certbot/2.7.4?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/certbot?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/certbot?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-certbot?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-certbot?color=c91cb8)

Run Certbot based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Description
With this image you can create certificates from Let’s Encrypt either via HTTP challenge (TCP:80) or via DNS (RFC2136). This image will start a Nginx webserver listening for the HTTP challenge. It will produce all different kind of certificates that can then be used in other systems. It will also call an optional webhook on each certificate renewal (success or fail). As a bonus, it will redirect all HTTP calls (not from Certbot) permanent to HTTPS.

## Volumes
* **/certbot/etc** - Directory of config.yaml and dns.ini
* **/certbot/var** - Directory of all certs

## Run
```shell
docker run --name certbot \
  -p 8080:8080/tcp \
  -v .../etc:/certbot/etc \
  -v .../var:/certbot/var \
  -d 11notes/certbot:[tag]
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /certbot | home directory of user docker |
| `api` | http://${IP}:8080 | Certbot endpoint |

## Environment
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | null |
| `DNS_RFC2136_PROPAGATION_SECONDS` | time in seconds to wait for DNS propagation | 60 |
| `KEY_TYPE` | set key type (rsa or ecdsa) | ecdsa |
| `WEBHOOK` | Will call ${URL}/${NAME}/[fail|success] with PUT and payload json `domains` |  |

## Parent image
* [11notes/nginx:stable](https://github.com/11notes/docker-nginx)

## Built with (thanks to)
* [certbot](https://certbot.eff.org)
* [nginx](https://nginx.org)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Only use rootless container runtime (podman, rootless docker)
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy (haproxy, traefik, nginx)