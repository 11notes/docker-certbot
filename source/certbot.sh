#!/bin/sh
CB_NAME=/var/ssl/"$1"
mkdir -p $CB_NAME
echo "creating certificate for $3"
certbot certonly --cert-name "$1" --non-interactive --agree-tos --email "$2" --keep --webroot -w /var/www $3
cp /etc/letsencrypt/live/"$1" -RL /var/ssl
openssl pkcs12 -export -out "$CB_NAME/cert.pfx" -inkey "$CB_NAME/privkey.pem" -in "$CB_NAME/cert.pem" -certfile "$CB_NAME/fullchain.pem" -passout pass:1234
cat "$CB_NAME/cert.pem" >  "$CB_NAME/certkey.pem"
cat "$CB_NAME/privkey.pem" >> "$CB_NAME/certkey.pem"
cat "$CB_NAME/fullchain.pem" >  "$CB_NAME/fullchainkey.pem"
cat "$CB_NAME/privkey.pem" >> "$CB_NAME/fullchainkey.pem"