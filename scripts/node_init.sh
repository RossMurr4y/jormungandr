#!/bin/bash

# Author: Ross Murray (github.com/rossmurr4y)

# Initialize the jormungandr container

# -- Config Defaults -- #

PUBLIC_ADDRESS_DEFAULT="/ip4/127.0.0.1/tcp/3000"
GENESIS_HASH_DEFAULT="8e4d2a343f3dcf9330ad9035b3e8d168e6728904262f2c434a4f8f934ec7b676" #itn_rewards

function usage(){
  cat <<EOF

Initialization script for the container.

This script is intended to be the default entry point to the container.
Rather than requiring the operator to write/configure a node config file,
this script will generate the file and pass in default values, 
environment variables or arguments passed to the script itself.

Usage: $(basename $0)

where

(o) -g                  is the genesis block hash of the blockchain.
(o) -h                  Shows this text.
(o) -p                  is the public_address property of the config yaml.

(m) mandatory, (o) optional, (d) deprecated

DEFAULTS:

PUBLIC_ADDRESS = "${PUBLIC_ADDRESS_DEFAULT}"
GENESIS_HASH   = "${GENESIS_HASH_DEFAULT}"

NOTES:
  1. Order of precedence for the configuration values are:
    Script Options > Environment Variables > Default Values

EOF
}

function options(){

  while getopts "g:h:p:" option; do
    case "${option}" in
      g) GENESIS_HASH="${OPTARG}" ;;
      h) usage; return 1 ;;
      p) PUBLIC_ADDRESS="${OPTARG}" ;;
      \?) fatalOption; return 1 ;;
      :) fatalOptionArgument; return 1 ;;
    esac
  done

  # Use Option if exists, else try the ENV Variable (if present), else the default.
  GENESIS_HASH="${GENESIS_HASH:-${GENESIS_HASH_ENV:-${GENESIS_HASH_DEFAULT}}}"
  PUBLIC_ADDRESS="${PUBLIC_ADDRESS:-${PUBLIC_ADDRESS_ENV:-${PUBLIC_ADDRESS_DEFAULT}}}"

  return 0
}

function generate_node_config(){
  mkdir -p "/home/cardano/jormungandr/configuration/"
  cat << EOF > /home/cardano/jormungandr/configuration/node_config.yaml
{
  "log": [
    {
      "format": "plain",
      "level": "info",
      "output": "stderr"
    }
  ],
  "storage": "/opt/cardano/jormungandr/blockchain/",
  "p2p": {
    "topics_of_interest": {
      "blocks": "high",
      "messages": "high"
    },
    "trusted_peers": [
      {
        "address": "/ip4/13.56.0.226/tcp/3000",
        "id": "7ddf203c86a012e8863ef19d96aabba23d2445c492d86267"
      },
      {
        "address": "/ip4/54.183.149.167/tcp/3000",
        "id": "df02383863ae5e14fea5d51a092585da34e689a73f704613"
      },
      {
        "address": "/ip4/52.9.77.197/tcp/3000",
        "id": "fcdf302895236d012635052725a0cdfc2e8ee394a1935b63"
      },
      {
        "address": "/ip4/18.177.78.96/tcp/3000",
        "id": "fc89bff08ec4e054b4f03106f5312834abdf2fcb444610e9"
      },
      {
        "address": "/ip4/3.115.154.161/tcp/3000",
        "id": "35bead7d45b3b8bda5e74aa12126d871069e7617b7f4fe62"
      },
      {
        "address": "/ip4/18.182.115.51/tcp/3000",
        "id": "8529e334a39a5b6033b698be2040b1089d8f67e0102e2575"
      },
      {
        "address": "/ip4/18.184.35.137/tcp/3000",
        "id": "06aa98b0ab6589f464d08911717115ef354161f0dc727858"
      },
      {
        "address": "/ip4/3.125.31.84/tcp/3000",
        "id": "8f9ff09765684199b351d520defac463b1282a63d3cc99ca"
      },
      {
        "address": "/ip4/3.125.183.71/tcp/3000",
        "id": "9d15a9e2f1336c7acda8ced34e929f697dc24ea0910c3e67"
      }
    ],
    "public_address": "${PUBLIC_ADDRESS}",
    "listen_address": "/ip4/0.0.0.0/tcp/3000"
  }
}
EOF
}

function start_jormungandr(){
  jormungandr --genesis-block-hash "${GENESIS_HASH}" \
              --config '/home/cardano/jormungandr/configuration/node_config.yaml'
             #--secret '/home/cardano/jormungandr/configuration/node_secret.yaml' TODO: node_secret integration with keyvault vars.
}

function main(){
  options "$@" || return $?
  generate_node_config
  start_jormungandr || return $?
}

main "$@"