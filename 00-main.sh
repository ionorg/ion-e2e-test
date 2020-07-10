#!/usr/bin/env bash
set -e
test -z "$TRAVIS_BUILD_ID" || export JOB_ID="$TRAVIS_BUILD_ID"
test -z "$JOB_ID" && export JOB_ID="$1"
test -z "$JOB_ID" && (echo 'Either set JOB_ID or pass it as the first argument' && exit 1)

source ./01-create-linode-credentials.sh

export DOMAIN="job-$JOB_ID.ion-build.pion.ly"
export EMAIL="sean@pion.ly"
export ION_HOST="$DOMAIN"
export WWW_URL="$DOMAIN"
export START_BOOTSTRAP="$(date)"

echo "Start Bootstrap: $START_BOOTSTRAP"
bash ./05-launch-ion-cluster.sh

echo "Check the status at https://$WWW_URL"

export START_TESTS="$(date)"
echo "Beginning Tests: $START_TESTS"

bash ./10-web-test-main.sh

echo "Start Bootstrap: $START_BOOTSTRAP"
echo "Beginning Tests: $START_TESTS"
echo "Completed  at  : $(date)"