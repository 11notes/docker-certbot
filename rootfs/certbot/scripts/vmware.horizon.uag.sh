#!/bin/ash
  # this is a sample script how to use certbot certificates to update a Horizon View Unified Access Gateway
  # it will check if the certificate is of key type RSA and only update certificates which will expire within 3 days
  #
  # environment variables
  # HORIZON_VIEW_UAG_NODES    - list of IP's or FQDN's for the UAG
  # HORIZON_VIEW_UAG_USER     - user with permission on the UAG to update certificates
  # HORIZON_VIEW_UAG_PASSWORD - password for user
  # HORIZON_VIEW_FQDN         - FQDN to check for certificate expiry
  #
  trap "rm -f ${ROOT}/${1}.json &> /dev/null" EXIT  
  ROOT=${APP_ROOT}/var/${1}
  SCRIPT=${PWD}/$(basename "${0}")

  openssl x509 -noout -text -in ${ROOT}/${1}.crt | grep -q "ecPublicKey"
  if [ $? == 1 ]; then
    END=$(echo -n Q | openssl s_client -connect ${HORIZON_VIEW_FQDN}:443 2>/dev/null | openssl x509 -enddate -noout -checkend 3)
    if echo ${END} | grep -q 'will expire'; then
      elevenLogJSON info "[${SCRIPT}] certificate will expire in the next three days, replacing ..."
      echo '{}' | jq \
        --arg privateKeyPem "$(cat ${ROOT}/${1}.key)" \
        --arg certChainPem "$(cat ${ROOT}/${1}.crt)" \
      '{"privateKeyPem": $privateKeyPem, "certChainPem": $certChainPem}' > ${ROOT}/${1}.json

      for IP in ${HORIZON_VIEW_UAG_NODES}; do
        curl -i -s -o /dev/null -w "%{http_code}" -X PUT --insecure --max-time 5 --user ${HORIZON_VIEW_UAG_USER}:${HORIZON_VIEW_UAG_PASSWORD} -H 'Content-Type: application/json' https://${IP}:9443/rest/v1/config/certs/ssl -d @${ROOT}/${1}.json | grep -q '200'
        if [ ! $? == 0 ]; then
          elevenLogJSON error "[${SCRIPT}] failed to update Unified Access Gateway [${IP}]!"
        else
          elevenLogJSON info "[${SCRIPT}] certificate upadted on Unified Access Gateway [${IP}]"
        fi
      done
    else
      elevenLogJSON info "[${SCRIPT}] no updated of certificate needed, does not expire in the next three days"
    fi
  else
    elevenLogJSON error "[${SCRIPT}] can't be used on ecdsa certificates, make sure you have selected key:rsa for Horizon View Unified Access Gateway!"
  fi