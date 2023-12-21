# :: Header
  FROM 11notes/nginx:stable
  ENV APP_VERSION=2.7.4-r0
  ENV APP_ROOT=/certbot

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      mkdir -p ${APP_ROOT}/lib; \
      mkdir -p ${APP_ROOT}/log;

  # :: install application
    RUN set -ex; \
      apk --no-cache add \
        yq \
        rsync \
        openssl \
        certbot=${APP_VERSION} \
        python3; \
      python3 -m ensurepip; \
      pip3 install certbot-dns-rfc2136; \
      apk --no-cache upgrade;

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

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]