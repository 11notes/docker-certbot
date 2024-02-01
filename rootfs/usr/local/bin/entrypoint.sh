#!/bin/ash
  if [ -z "${1}" ]; then
    elevenLogJSON info "starting nginx"
    set -- "nginx" \
      -g \
      'daemon off;'
  fi

  exec "$@"