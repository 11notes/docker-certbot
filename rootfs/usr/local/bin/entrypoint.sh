#!/bin/ash

  if [ -z "${DNS_RFC2136_PROPAGATION_SECONDS}" ]; then DNS_RFC2136_PROPAGATION_SECONDS=60; fi

  if [ -z "$1" ]; then
    set -- "nginx" \
      -g \
      'daemon off;'
  fi

  exec "$@"