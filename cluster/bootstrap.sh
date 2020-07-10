#!/usr/bin/env bash
set -e
USAGE="Usage: bootstrap.sh {SSL_DOMAIN} {ADMIN_EMAIL} [ION_VERSION] [WEB_VERSION]"
test -z "$1" && (echo $USAGE && exit 1) || export WWW_URL="$1"
test -z "$2" && (echo $USAGE && exit 1) || export ADMIN_EMAIL="$2"

export ION_VERSION=$(test -z "$1" && echo 'master' || echo "$3")
export WEB_VERSION=$(test -z "$2" && echo 'master' || echo "$4")


apt update -yq
apt install -yq docker docker-compose git

docker network create ionnet &>/dev/null || true

echo
echo "================"
echo "ION_VERSION: $ION_VERSION"
echo "WEB_VERSION: $WEB_VERSION"
echo "================"
echo


# do ion-app-web first so letsencrypt can start processing the certs request
test -d "ion-app-web" || git clone https://github.com/pion/ion-app-web
pushd ion-app-web
git reset --hard HEAD
git fetch origin $WEB_VERSION
git checkout $WEB_VERSION
# Use production cad
cp configs/caddy/Caddyfile configs/caddy/local.Caddyfile

sed -i 's/# \(.*:80\)/\1/' docker-compose.yml
sed -i 's/# \(.*:443\)/\1/' docker-compose.yml

docker-compose build
echo "Starting ion-app-web WWW_URL=$WWW_URL ADMIN_EMAIL=$ADMIN_EMAIL"
docker-compose up -d
popd


test -d "ion" || git clone https://github.com/pion/ion

pushd ion
git reset --hard HEAD
git fetch origin $ION_VERSION
git checkout $ION_VERSION
docker-compose build
docker-compose up -d
popd
