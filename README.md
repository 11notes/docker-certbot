![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - Certbot
![size](https://img.shields.io/docker/image-size/11notes/certbot/2.11.0?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/certbot/2.11.0?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/certbot?color=2b75d6)

# SYNOPSIS
With this image you can create certificates from Let’s Encrypt via different modules. This image will start a Nginx webserver listening for the HTTP challenge. It will produce all different kind of certificates that can then be used in other systems. It will also call an optional webhook on each certificate renewal (success or fail). As a bonus, it will redirect all HTTP calls (not from Certbot) permanent to HTTPS.

Simply configure your desired certificates via yaml (`/certbot/etc/config.yaml`). Configure each module with the information it needs. After that you can periodically run `docker exec certbot renew`. Certbot will then automatically renew or create all certificates defined in `config.yaml`, it will clean up expired certificates and create additional certificate types (`*.pfx, *.pk8`) as well as a tar with all files. You can call a webhook or script on each certificate renewal.

Why use this image at all and not simply use Certbot with Traefik? Simple answer: All though most systems can be proxies via Traefik or other reverse proxies that can auto update their certificates themselves, a lot of systems that can’t be proxied still need valid SSL certificates (like database authentication, MQTT, SMTP, RDP and so on). Since this image will create valid SSL certificates and call a possible webhook on each success or fail, that webhook can be used to update the certificates on these non-proxy systems.

# 3RD PARTY SYSTEMS SUPPORTED
* **Horizon View Unified Access Gateway**
* **Traefik Dynamic Configuration**

# VOLUMES
* **/certbot/etc** - Directory of config.yaml and dns.ini
* **/certbot/var** - Directory of all certs
* **/certbot/scripts** - Directory of all your and default scripts

# CONFIG (EXAMPLE)
/certbot/etc/config.yaml
```yaml
certificates:
  # name must be unique and is used for the file names
  # up to 100 FQDN or wildcard allowed

  - name: "com.domain"
    email: "info@domain.com"
    fqdn:
      - "*.domain.com"
      - "*.www.domain.com"

  # define module to use
  - name: "com.domain.dns"
    email: "info@domain.com"
    module:
      rfc2136:
        server: 10.255.255.53
        port: 53
        name: "certbot."
        secret: "*****************************************************"
        algorithm: "HMAC-SHA512"
        propagation_seconds: 30
    fqdn:
      - "*.domain.com"

  - name: "com.domain.dns.credentials"
    email: "info@domain.com"
    module:
      rfc2136:
        credentials: "/certbot/etc/com.domain.ini"
    fqdn:
      - "*.domain.com"

  # use RSA instead of ECDSA
  - name: "com.domain.rsa"
    email: "info@domain.com"
    key: rsa
    fqdn:
      - "*.domain.com"

  # call webhook
  - name: "com.domain.webhook"
    email: "info@domain.com"
    webhook: https://domain.com/certbot
    fqdn:
      - "*.domain.com"

  # call script
  - name: "com.domain.script"
    email: "info@domain.com"
    script: /certbot/scripts/vmware.horizon.uag.sh
    key: rsa
    fqdn:
      - "*.domain.com"
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
| `home` | /certbot | home directory of user docker |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |
| `CERTBOT_CONFIG` | environment variable containing the entire config as yaml |  |
| `CERTBOT_KEY_TYPE` | set key type (RSA or ECDSA) | ECDSA |
| `CERTBOT_TRAEFIK_DIRECTORY` | directory to create certificate structure for Traefik (ie /certbot/traefik) |  |
| `CERTBOT_TRAEFIK_RELATIVE_PATH` | realtive path to use in certbot.yaml (ie /traefik/var/ssl) |  |

# AVAILABLE MODULES
| Module | Parameter | Description | Default |
| --- | --- | --- | --- |
| `http` | HTTP_PORT | port used for HTTP challenge | 80 |
| `rfc2136` | CERTBOT_RFC2136_PROPAGATION_SECONDS | time in seconds to wait for DNS propagation | 60 |
| `rfc2136` | CERTBOT_RFC2136_CREDENTIALS | path to dns.ini | /certbot/etc/rfc2136.ini |

# SOURCE
* [11notes/certbot:2.11.0](https://github.com/11notes/docker-certbot/tree/2.11.0)

# PARENT IMAGE
* [11notes/nginx:stable](https://hub.docker.com/r/11notes/nginx)

# BUILT WITH
* [certbot](https:/certbot.eff.org)
* [nginx](https://nginx.org)
* [alpine](https://alpinelinux.org)

# TIPS
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes. You can find all my repositories on [github](https://github.com/11notes).
    