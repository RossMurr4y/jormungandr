#!/bin/bash

# install official IOHK jormungandr scripts
git clone "https://github.com/input-output-hk/jormungandr-qa.git"
cp jormungandr-qa/scripts/* /tmp/bin

# retrieve the latest peers list and store in its own json file.
curl -L https://hydra.iohk.io/job/Cardano/iohk-nix/jormungandr-deployment/latest-finished/download/1/itn_rewards_v1-config.yaml \
    | jq '.p2p.trusted_peers[]' > /tmp/bin/trusted_peers.json

# install rossmurr4y node_init script
curl https://raw.githubusercontent.com/RossMurr4y/daedalus/master/scripts/node_init.sh -o /tmp/bin/node_init.sh

# Grant execution rights on scripts
chmod +x /tmp/bin/*.sh