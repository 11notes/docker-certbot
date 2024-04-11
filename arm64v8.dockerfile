# :: QEMU
  FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Header
  FROM 11notes/nginx:arm64v8-stable
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  ENV APP_VERSION=2.7.4-r0
  ENV APP_NAME="certbot"
  ENV APP_ROOT=/certbot

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      mkdir -p ${APP_ROOT}/lib; \
      mkdir -p ${APP_ROOT}/scripts; \
      mkdir -p ${APP_ROOT}/log;

  # :: install application
    RUN set -ex; \
      apk --no-cache --virtual .build add \
        gcc \
        build-base \
        linux-headers \
        libffi-dev \
        python3-dev; \
      apk --no-cache add \
        gcc \
        curl \
        jq \
        yq \
        rsync \
        openssl \
        certbot=${APP_VERSION} \
        py3-pip \
        python3=3.11.8-r0; \
      pip3 install -t /usr/lib/python3.11/site-packages --upgrade certbot-dns-rfc2136; \
      apk --no-cache upgrade; \
      apk del .build;

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
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var", "${APP_ROOT}/scripts"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]