#!/bin/bash

# install official IOHK jormungandr scripts
git clone "https://github.com/input-output-hk/jormungandr-qa.git"
cp jormungandr-qa/scripts/* /tmp/bin

# Grant execution rights on scripts
chmod +x /tmp/bin/*.sh