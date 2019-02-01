#!/bin/sh
for ARGUMENT in "$@"
do
        KEY=$(echo $ARGUMENT | cut -f1 -d=)
        VALUE=$(echo $ARGUMENT | cut -f2 -d=)
        eval "$KEY"='"$VALUE"'
done

CB_NAME=/nginx/ssl/"$DIR"/"$NAME"
mkdir -p $CB_NAME
echo "creating certificate for $NAME (directory: $CB_NAME)"
certbot certonly --cert-name "$NAME" --non-interactive --agree-tos --email "$EMAIL" --keep --webroot -w /nginx/www $DOMAIN
cp /etc/letsencrypt/live/"$NAME" -RL /nginx/ssl/"$DIR"
openssl pkcs12 -export -out "$CB_NAME/cert.pfx" -inkey "$CB_NAME/privkey.pem" -in "$CB_NAME/cert.pem" -certfile "$CB_NAME/fullchain.pem" -passout pass:1234
cat "$CB_NAME/cert.pem" >  "$CB_NAME/certkey.pem"
cat "$CB_NAME/privkey.pem" >> "$CB_NAME/certkey.pem"
cat "$CB_NAME/fullchain.pem" >  "$CB_NAME/fullchainkey.pem"
cat "$CB_NAME/privkey.pem" >> "$CB_NAME/fullchainkey.pem"