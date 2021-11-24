#!/bin/bash
readonly DOTNET_SERVICE="dotnet-api"
readonly NGINX_SERVICE="dotnet-nginx"
readonly CERTBOT_SERVICE="dotnet-certbot"
readonly DOMAIN=(<domain>)
readonly CERTBOT_PATH="./certbot"
readonly EMAIL="<email>"
readonly IS_STAGING=0

# Check docker exists
if [ ! -x "$(command -v docker)" ] && [ ! -x "$(command -v docker-compose)" ]; then
  exit
fi

# Check the existence of $CERTBOT_PATH
if [ ! -d "$CERTBOT_PATH" ]; then
    echo -e "Creating directory ...\n"
    sudo mkdir -p "$CERTBOT_PATH/conf/live/$DOMAIN"
    echo -e "Directory has been created.\n"
else
    echo -e "Directory found.\n"
fi

# Download Nginx SSL config and DH Param
if [ ! -e "certbot/conf/options-ssl-nginx.conf" ] || [ ! -e "certbot/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  sudo mkdir -p "$CERTBOT_PATH/conf"
  sudo curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$CERTBOT_PATH/conf/options-ssl-nginx.conf"
  sudo curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$CERTBOT_PATH/conf/ssl-dhparams.pem"
  echo
fi

# Generate self-signed certificate
echo -e "Generating self-signed certificate ...\n"
SSL_PATH="/etc/letsencrypt/live/$DOMAIN"
sudo mkdir -p "$CERTBOT_PATH/conf/live/$DOMAIN"
docker-compose run --rm --entrypoint "\
    openssl req -x509 -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout '$SSL_PATH/privkey.pem' \
    -out '$SSL_PATH/fullchain.pem' \
    -subj '/CN=localhost'" $CERTBOT_SERVICE
echo -e "Generate self-signed certificate successfully.\n"

# Start Nginx service
echo -e "Starting Nginx and Web API ..."
docker-compose up --force-recreate -d $NGINX_SERVICE
docker-compose up --force-recreate -d $DOTNET_SERVICE

# echo "### Deleting dummy certificate for $DOMAIN ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$DOMAIN && \
  rm -Rf /etc/letsencrypt/archive/$DOMAIN && \
  rm -Rf /etc/letsencrypt/renewal/$DOMAIN.conf" $CERTBOT_SERVICE
echo

# Replace self-signed certificate with Let's Encrypt SSL
# Request certificate from Let's Encrypt
echo -e "Requesting Let's Encrypt certificate for $DOMAIN ..."

# Concatenate $DOMAIN to -d argument
domain_args=""
for d in "${DOMAIN[@]}"; do
  domain_args="$domain_args -d $d"
done

# Select appropriate email arg
case "$EMAIL" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $EMAIL" ;;
esac

# Enable staging mode if needed
if [ $IS_STAGING != "0" ]; then 
    staging_arg="--staging"; 
fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size 4096 \
    --agree-tos \
    --no-eff-email \
    --force-renewal" $CERTBOT_SERVICE

echo -e "Reload Nginx ..."
docker-compose exec $NGINX_SERVICE nginx -s reload

echo -e "Docker Compose Up"
docker-compose up --remove-orphans --build