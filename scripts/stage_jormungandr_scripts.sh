#!/bin/bash

# install official IOHK jormungandr scripts
git clone "https://github.com/input-output-hk/jormungandr-qa.git"
cp jormungandr-qa/scripts/* /tmp/bin

# install rossmurr4y node_init script
curl https://raw.githubusercontent.com/RossMurr4y/daedalus/master/scripts/node_init.sh -o /tmp/bin/node_init.sh

# Grant execution rights on scripts
chmod +x /tmp/bin/*.sh