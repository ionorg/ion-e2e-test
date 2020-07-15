#!/usr/bin/env bash

export DIR=$(dirname $0)

test -z "$TRAVIS_BUILD_ID" || export JOB_ID="$TRAVIS_BUILD_ID"
test -z "$LINODE_KEY" && (echo 'You must set LINODE_KEY' && exit 1)
test -z "$LINODE_DOMAIN_ID" && (echo 'You must set LINODE_DOMAIN_ID' && exit 1)

export TF_VAR_JOB_ID="__all__"
export TF_VAR_LINODE_KEY=$LINODE_KEY
export TF_VAR_LINODE_DOMAIN_ID=$LINODE_DOMAIN_ID
export TF_VAR_SSH_PUBLIC_KEY=""
bash $DIR/01-create-linode-credentials.sh

pushd $DIR
cp /data/terraform.tfstate . || true
terraform init || true
terraform destroy -auto-approve
popd

IDS=$(linode-cli --json domains records-list $LINODE_DOMAIN_ID | jq -c '[ .[] | select( .name | contains("job-'$JOB_ID'.ion-test") ) ] | .[].id')
if [[ -z "$IDS" ]] ; then
    echo "No domain records found to delete!"
else
    for ID in $IDS; do
        echo "Deleting domain record: $ID..."
        linode-cli domains records-delete $LINODE_DOMAIN_ID $ID
    done

fi