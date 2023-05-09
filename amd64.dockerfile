# :: Header
  FROM 11notes/nginx:stable

# :: Run
  USER root

  # :: prepare
  RUN set -ex; \
    mkdir -p /certbot; \
    mkdir -p /certbot/etc; \
    mkdir -p /certbot/var; \
    mkdir -p /certbot/lib; \
    mkdir -p /certbot/log;

  RUN set -ex; \
    apk --update --no-cache add \
      yq \
      openssl \
      certbot;

  # :: copy root filesystem changes
  COPY ./rootfs /
  RUN set -ex; \
    chmod +x -R /usr/local/bin;

  # :: docker -u 1000:1000 (no root initiative)
  RUN set -ex; \
    chown -R nginx:nginx \
      /certbot;

# :: Volumes
  VOLUME ["/certbot/etc", "/certbot/var"]

# :: Start
  USER nginx
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]