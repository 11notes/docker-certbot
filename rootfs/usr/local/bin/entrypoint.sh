#!/bin/ash

  if [ -z "${DNS-RFC2136-PROPAGATION-SECONDS}" ]; then DNS-RFC2136-PROPAGATION-SECONDS=60; fi

  if [ -z "$1" ]; then
    set -- "nginx" \
      -g \
      'daemon off;'
  fi

  exec "$@"