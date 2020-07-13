#!/usr/bin/env bash

set -e

if [[ -z "$1" ]] ; then 
  echo "Usage: build.sh [version]" 
  exit 1
else
  export VERSION=$1
fi

source .envrc

docker build -t ${IMAGE} .
docker tag ${IMAGE} ${IMAGE}:${VERSION}
