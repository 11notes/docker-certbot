#!/bin/ash
  # will create a dynamic configuration yaml and copy all certificates to the destination directory and remove expired ones
  #
  # environment variables
  # TRAEFIK_DYNAMIC_ROOT  - destination directory for all certificate files, should only contain certificates!
  # TRAEFIK_DYNAMIC_NAME  - name of .yaml file containing certificate configuration (default: ${TRAEFIK_DYNAMIC_ROOT}/certbot.yaml) 
  #
  ROOT=${APP_ROOT}/var/${1}
  YAML=$(echo -e "tls:\n  certificates:")
  TRAEFIK_DYNAMIC_NAME=${TRAEFIK_DYNAMIC_NAME:-certbot.yaml}
  mkdir -p ${TRAEFIK_DYNAMIC_ROOT}

  # copy certificates
  /usr/bin/rsync -rvzcq --mkpath \
    --include="${1}.crt" \
    --include="${1}.key" \
    --exclude='*' ${ROOT}/ ${TRAEFIK_DYNAMIC_ROOT}/

  # remove expired certificates and add valid ones
  I_ADD=0
  for CRT in ${TRAEFIK_DYNAMIC_ROOT}/*.crt; do
    NAME=$(echo ${CRT} | sed "s#${TRAEFIK_DYNAMIC_ROOT}/##")
    if [ -f "${CRT}" ]; then
      END=$(openssl x509 -enddate -noout -in "${CRT}" -checkend 0)
      if echo ${END} | grep -q 'will expire'; then
        rm -rf "${TRAEFIK_DYNAMIC_ROOT}/${NAME}.crt"
        rm -rf "${TRAEFIK_DYNAMIC_ROOT}/${NAME}.key"
      else
        YAML=$(echo -e "${YAML}\n    - certFile: \"${TRAEFIK_DYNAMIC_ROOT}/${NAME}.crt\"\n      keyFile: \"${TRAEFIK_DYNAMIC_ROOT}/${NAME}.key\"")
        I_ADD=$((${I_ADD}+1)) 
      fi
    fi
  done

  # write dynamic configuration file
  echo "${YAML}" > ${TRAEFIK_DYNAMIC_ROOT}/${TRAEFIK_DYNAMIC_NAME}
  echo "added ${I_ADD} certificate(s) to ${TRAEFIK_DYNAMIC_ROOT}/${TRAEFIK_DYNAMIC_NAME}"