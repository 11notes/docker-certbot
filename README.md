# docker-certbot
Container that redirects all HTTP traffic to HTTPS and will create lets encrypt certificates to be exported and read from other containers or systems.

## Volumes
* /certbot/etc - config.yaml location
* /certbot/var - output directory of certbot

## Run
```shell
docker run --name certbot \
-v volume-etc:/certbot/etc \
-v volume-ssl:/certbot/var \
-d 11notes/certbot:[tag]
```

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
docker exec certbot crt
```

This will create all kinds of certificates (key, crt, fullchain, pfx, pk8) in the directory "/certbot/var". The generated *.pfx has no password! You can then mount the same docker volume (/certbot/var) in another container to use the generated certificates (i.e. nginx webserver).

## Docker -u 1000:1000 (no root initiative)
As part to make containers more secure, this container will not run as root, but as uid:gid 1000:1000. Therefore the default TCP port 80 was changed to 8080 (/source/certbot.conf).

## Build with
* [11notes/nginx:stable](https://github.com/11notes/docker-nginx) - Parent container
* [Alpine Linux](https://alpinelinux.org/) - Alpine Linux
* [Certbot](https://certbot.eff.org/) - Certbot Let's Encrypt

## Tips
* Don't bind to ports < 1024 (requires root), use NAT
* [Permanent Storge with NFS/CIFS/...](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS/...