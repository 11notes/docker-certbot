#!/bin/ash
  if [ -z "${1}" ]; then
    if [ ! -z ${CERTBOT_CONFIG} ]; then
      elevenLogJSON debug "set config from environment"
      echo "${CERTBOT_CONFIG}" > ${APP_ROOT}/etc/config.yaml
    fi

    elevenLogJSON info "starting certbot"
    set -- "nginx" \
      -g \
      'daemon off;'
  fi

  exec "$@"