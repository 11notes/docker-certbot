#!/bin/ash
  # this is a sample script how to use certbot certificates to update a Horizon View Unified Access Gateway
  #
  # environment variables
  # HORIZON_VIEW_UAG_NODES    - list of IP's or FQDN's for the UAG
  # HORIZON_VIEW_UAG_USER     - user with permission on the UAG to update certificates
  # HORIZON_VIEW_UAG_PASSWORD - password for user
  #
  trap "rm -f ${ROOT}/${1}.json &> /dev/null" EXIT  
  ROOT=${APP_ROOT}/var/${1}
  SCRIPT=${PWD}/$(basename "$0")

  echo '{}' | jq \
    --arg privateKeyPem "$(cat ${ROOT}/${1}.key)" \
    --arg certChainPem "$(cat ${ROOT}/${1}.crt)" \
  '{"privateKeyPem": $privateKeyPem, "certChainPem": $certChainPem}' > ${ROOT}/${1}.json

  for IP in ${HORIZON_VIEW_UAG_NODES}; do
    curl -i -s -o /dev/null -w "%{http_code}" -X PUT --insecure --max-time 5 --user ${HORIZON_VIEW_UAG_USER}:${HORIZON_VIEW_UAG_PASSWORD} -H 'Content-Type: application/json' https://${IP}:9443/rest/v1/config/certs/ssl -d @${ROOT}/${1}.json | grep -q '200'
    if [ ! $? == 0 ]; then
      elevenLogJSON error "script \"${SCRIPT}\" filed to update Unified Access Gateway [${IP}]"
    fi
  done