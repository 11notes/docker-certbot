# :: QEMU
  FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
FROM alpine as util

RUN set -ex; \
  apk add --no-cache \
    git; \
  git clone https://github.com/11notes/util.git;

# :: Build
FROM --platform=linux/arm64 11notes/alpine-build:stable as build
COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
ENV BUILD_VERSION=2.11.0
ENV BUILD_DIR=/certbot/certbot

USER root

RUN set -ex; \
  apk add --update --no-cache \
    python3 \
    py3-acme \
    py3-configargparse \
    py3-configobj \
    py3-cryptography \
    py3-distro \
    py3-distutils-extra \
    py3-josepy \
    py3-parsedatetime \
    py3-pyrfc3339 \
    py3-setuptools \
    py3-tz \
    py3-gpep517 \
    py3-wheel \
    py3-pip; \
  git clone https://github.com/certbot/certbot.git -b v${BUILD_VERSION};

  RUN set -ex; \
    cd ${BUILD_DIR}; \
    gpep517 build-wheel \
      --wheel-dir .dist \
      --output-fd 3 3>&1 >&2; \
    python3 -m installer -d "/opt/certbot" \
      .dist/*.whl;

# :: Header
FROM --platform=linux/arm64  11notes/nginx:stable
COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
COPY --from=build /opt/certbot /
ENV APP_VERSION=2.11.0
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
  mkdir -p ${APP_ROOT}/log; \
  mkdir -p ${APP_ROOT}/tmp;

# :: install application
RUN set -ex; \
  apk add --update --no-cache \
    jq \
    yq \
    rsync \
    openssl \
    python3 \
    py3-pip \
    py3-acme \
    py3-configargparse \
    py3-configobj \
    py3-cryptography \
    py3-distro \
    py3-distutils-extra \
    py3-josepy \
    py3-parsedatetime \
    py3-pyrfc3339 \
    py3-setuptools \
    py3-tz; \
  pip3 install --upgrade certbot-dns-rfc2136 --break-system-packages; \
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