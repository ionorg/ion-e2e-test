#!/usr/bin/env bash
test -z "$LINODE_KEY" && (echo 'You must set LINODE_KEY' && exit 1)
test -z "$LINODE_DOMAIN_ID" && (echo 'You must set LINODE_DOMAIN_ID' && exit 1)

export TF_VAR_LINODE_KEY=$LINODE_KEY
export TF_VAR_LINODE_DOMAIN_ID=$LINODE_DOMAIN_ID

if [[ ! -e "$HOME/.config/linode-cli" ]] ; then
    mkdir -p ~/.config/ &>/dev/null || true
    # Setup linode-cli
    cat <<EOF > ~/.config/linode-cli
[DEFAULT]
default-user = pion_ion_dev

[pion_ion_dev]
token = ${LINODE_KEY}
region = us-west
type = g6-standard-4
image = linode/ubuntu20.04
EOF

fi;