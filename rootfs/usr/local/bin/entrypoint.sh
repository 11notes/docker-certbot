#!/bin/ash
  if [ -z "${1}" ]; then
    log-json info "starting nginx"
    set -- "nginx" \
      -g \
      'daemon off;'
  fi

  exec "$@"