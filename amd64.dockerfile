# :: Header
  FROM 11notes/nginx:stable

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk update; \
      apk --update --no-cache add \
        yq \
        openssl \
        certbot; \
      apk upgrade;

  # :: prepare image
    RUN set -ex; \
      mkdir -p /certbot; \
      mkdir -p /certbot/etc; \
      mkdir -p /certbot/var; \
      mkdir -p /certbot/lib; \
      mkdir -p /certbot/log;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d /certbot docker; \
      chown -R 1000:1000 \
        /certbot;

# :: Volumes
  VOLUME ["/certbot/etc", "/certbot/var"]

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]