# Alpine :: Certbot
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
```

## create or update certificates
```shell
docker exec certbot renew
```

This will create all kinds of certificates (key, crt, fullchain, pfx, pk8) in the directory "/certbot/var". The generated *.pfx has no password! You can then mount the same docker volume (/certbot/var) in another container to use the generated certificates (i.e. nginx webserver). If dns is set to true, certbot will use /certbot/etc/dns.ini to connect to your RFC2136 enabled DNS server and retrieve certificates via DNS. Default is HTTP method.

## Parent
* [11notes/nginx:stable](https://github.com/11notes/docker-nginx)

## Built with
* [certbot](https://certbot.eff.org)
* [nginx](https://nginx.org)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy
* [Permanent Storage](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS and more