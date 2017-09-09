#!/bin/bash
BASE_DIR=$(dirname "${BASH_SOURCE[0]}")
ansible-galaxy install -f -i -p $BASE_DIR/roles -r $BASE_DIR/requirements.yml
