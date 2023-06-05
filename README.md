# Alpine :: Certbot
Run LetsEncrypt Certbot based on Alpine Linux. Small, lightweight, secure and fast.

## Volumes
* **/certbot/etc** - Directory of config.yaml
* **/certbot/var** - Directory of all certs

## Run
```shell
docker run --name certbot \
  -v ../etc:/certbot/etc \
  -v ../var:/certbot/var \
  -d 11notes/certbot:[tag]
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |

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
    fqdn:
    - contoso.com
```

## create or update certificates
```shell
docker exec certbot update
```

This will create all kinds of certificates (key, crt, fullchain, pfx, pk8) in the directory "/certbot/var". The generated *.pfx has no password! You can then mount the same docker volume (/certbot/var) in another container to use the generated certificates (i.e. nginx webserver).

## Parent
* [11notes/nginx:stable](https://github.com/11notes/docker-nginx)

## Built with
* [certbot](https://certbot.eff.org/)
* [nginx](https://nginx.org/)
* [Alpine Linux](https://alpinelinux.org/)

## Tips
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy
* [Permanent Stroage](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS and more