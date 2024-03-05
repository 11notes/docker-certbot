#!/bin/ash
  if [ -z "${1}" ]; then
    elevenLogJSON info "starting certbot"
    set -- "nginx" \
      -g \
      'daemon off;'
  fi

  exec "$@"