# docker-certbot

Container that redirects all HTTP traffic to HTTPS and will create lets encrypt certificates to be exported and read from other containers or systems.

## Volumes

/nginx/ssl

Purpose: SSL certificate directory

## Run
```shell
docker run --name certbot \
    -v volume-ssl:/nginx/ssl \
    -d 11notes/certbot:latest
```

## Exec
```shell
docker exec -ti CONTAINERID certbot-run DIR=".com" NAME="domain.com" EMAIL="cert@domain.com" \
    DOMAIN="-d domain.com -d www.domain.com"

Will request an SSL certificate for "domain.com" and "www.domain.com" and place all files (crt, key, pem) in the directory "/nginx/ssl/.com/domain.com"
```

This will create all kinds of certificates (key, crt, fullchain, pfx) in the directory "/nginx/ssl/$CertParentDir/$CertRequestName". The generated *.pfx has the password "1234". You can then mount the same docker volume (/nginx/ssl) in another container to use the generated certificates (i.e. nginx webserver).

## Docker -u 1000:1000 (no root initiative)

As part to make containers more secure, this container will not run as root, but as uid:gid 1000:1000. Therefore the default TCP port 80 was changed to 8080 (/source/certbot.conf).

## Build with
* [11notes/nginx:stable](https://github.com/11notes/docker-nginx) - Parent container
* [Alpine Linux](https://alpinelinux.org/) - Alpine Linux
* [Certbot](https://certbot.eff.org/) - Certbot Let's Encrypt

## Tips

* Don't bind to ports < 1024 (requires root), use NAT
* [Permanent Storge with NFS/CIFS/...](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS/...