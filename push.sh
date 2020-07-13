#!/usr/bin/env bash

set -e

if [[ -z "$1" ]] ; then 
  echo "Usage: build.sh [version]" 
  exit 1
else
  export VERSION=$1
fi

source .envrc

bash build.sh $VERSION

docker push $IMAGE:${VERSION}
