#!/usr/bin/env
VERSION='latest'
test -z "$1" && (echo "Specify a job id" && exit 1)

docker run -ti -e JOB_ID=$1 \
  -e LINODE_KEY=${LINODE_PION_ION_DEV} \
  -e LINODE_DOMAIN_ID=${LINODE_PION_ION_DOMAIN_ID} \
  -e BROWSERSTACK_URL=${PION_BROWSERSTACK_URL} \
  -e ION_VERSION=${TRAVIS_COMMIT} \
  -e MULTI=windows/chrome,windows/firefox,mac/chrome \
  -v ${PWD}:/data \
  -v /tmp:/tmp \
  --privileged \
  ${IMAGE}:${VERSION} bash
