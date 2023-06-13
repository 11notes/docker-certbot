# :: Header
  FROM 11notes/nginx:stable
  ENV APP_VERSION=2.6.0-r0
  ENV APP_ROOT=/certbot

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk update; \
      apk upgrade;

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      mkdir -p ${APP_ROOT}/lib; \
      mkdir -p ${APP_ROOT}/log;

  # :: install application
    RUN set -ex; \
      apk --update --no-cache add \
        yq \
        openssl \
        certbot=${APP_VERSION};

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]