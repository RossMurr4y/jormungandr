#!/bin/sh

# Author: Ross Murray (github.com/rossmurr4y)
# Git Repo: rossmurr4y/jormungandr
# Docker Hub: rossmurr4y/jormungandr

# Initialize the jormungandr container

# -- Variables -- #
config_dir="/home/cardano/jormungandr/configuration"
node_config="${config_dir}/node_config.yaml"
trusted_peers_file="/usr/local/bin/trusted_peers.json"

# -- Option Defaults -- #
LISTEN_ADDRESS_DEFAULT="/ip4/0.0.0.0/tcp/3000"
PUBLIC_ADDRESS_DEFAULT="/ip4/127.0.0.1/tcp/3000"
GENESIS_HASH_DEFAULT="8e4d2a343f3dcf9330ad9035b3e8d168e6728904262f2c434a4f8f934ec7b676" #itn_rewards
TRUSTED_PEERS_FILE_DEFAULT="${trusted_peers_file}"
NO_PEERS_DEFAULT=false

# -- Env Var Defaults -- #
LOG_FORMAT_DEFAULT="plain"
LOG_LEVEL_DEFAULT="info"
LOG_OUTPUT_DEFAULT="stderr"
P2P_BLOCK_INTEREST_DEFAULT="high"
P2P_MESSAGE_INTEREST_DEFAULT="high"
STORAGE_PATH_DEFAULT=""
NODE_SECRET_DEFAULT=false
MAX_CONNECTIONS_DEFAULT=500

function usage(){
  cat <<EOF

Initialization script for the container.

This script is intended to be the default entry point to the container.
Rather than requiring the operator to write/configure a node config file,
this script will generate the file and pass in default values, 
environment variables and arguments passed to the script itself.

Usage: $(basename $0)

where

(o) -g        is the [g]enesis block hash of the blockchain.
(o) -h        Shows this text.
(o) -l        is the [l]isten_address property of the config yaml.
(o) -n        NO_PEERS=true - provide [n]o trusted peers to the yaml.
(o) -p        is the [p]ublic_address property of the config yaml.
(o) -s        is the [s]torage property of the config yaml.
(o) -t        is the path to the [t]rusted peers file.
(o) -x        NODE_SECRET=true

(m) mandatory, (o) optional, (d) deprecated

OPTION DEFAULTS:

LISTEN_ADDRESS     = "${LISTEN_ADDRESS_DEFAULT}"
PUBLIC_ADDRESS     = "${PUBLIC_ADDRESS_DEFAULT}"
GENESIS_HASH       = "${GENESIS_HASH_DEFAULT}"
STORAGE_PATH *
TRUSTED_PEERS_FILE = "${TRUSTED_PEERS_FILE_DEFAULT}"
NO_PEERS           = "${NO_PEERS_DEFAULT}"

* Can be set via script option or environment path. There is only a default
for the environment variable.

ENVIRONMENT VARIABLE DEFAULTS:

LOG_FORMAT            = "${LOG_FORMAT_DEFAULT}"
LOG_LEVEL             = "${LOG_LEVEL_DEFAULT}"
LOG_OUTPUT            = "${LOG_OUTPUT_DEFAULT}"
P2P_BLOCK_INTEREST    = "${P2P_BLOCK_INTEREST_DEFAULT}"
P2P_MESSAGE_INTEREST  = "${P2P_MESSAGE_INTEREST_DEFAULT}"
STORAGE_PATH          = "${STORAGE_PATH_DEFAULT}"
NODE_SECRET           = "${NODE_SECRET_DEFAULT}"
MAX_CONNECTIONS       = "${MAX_CONNECTIONS_DEFAULT}"

NOTES:
  1.  If a setting is not covered by the script options, then it must be set
      through environment variables (list above).
  2.  Options passed to the script, overrule both env. variables and defaults.
  3.  If setting NODE_SECRET to true (-x) a file must be mounted at 
      /home/cardano/jormungandr/configuration/node_secret.yaml.
  4.  You can include your own trusted peers file by either setting the path
      to a new file, or just use a volume mount over the default.
      
      i.e: -v <peers-file>:"${TRUSTED_PEERS_FILE_DEFAULT}"

EOF
}

function options(){

  while getopts "g:hl:np:s:t:x" option; do
    case "${option}" in
      g) GENESIS_HASH="${OPTARG}" ;;
      h) usage; return 1 ;;
      l) LISTEN_ADDRESS="${OPTARG}" ;;
      n) NO_PEERS=true ;;
      p) PUBLIC_ADDRESS="${OPTARG}" ;;
      s) STORAGE_PATH="${OPTARG}" ;;
      t) TRUSTED_PEERS_FILE="${OPTARG}" ;;
      x) NODE_SECRET=true ;;
      \?) fatalOption; return 1 ;;
      :) fatalOptionArgument; return 1 ;;
    esac
  done

  # Apply defaults to unspecified options
  GENESIS_HASH="${GENESIS_HASH:-${GENESIS_HASH_DEFAULT}}"
  LISTEN_ADDRESS="${LISTEN_ADDRESS:-${LISTEN_ADDRESS_DEFAULT}}"
  PUBLIC_ADDRESS="${PUBLIC_ADDRESS:-${PUBLIC_ADDRESS_DEFAULT}}"
  STORAGE_PATH="${STORAGE_PATH:-${STORAGE_PATH_DEFAULT}}"
  TRUSTED_PEERS_FILE="${TRUSTED_PEERS_FILE:-${TRUSTED_PEERS_FILE_DEFAULT}}"
  NO_PEERS="${NO_PEERS:-${NO_PEERS_DEFAULT}}"

  # Apply defaults to unspecified environment vars
  LOG_FORMAT="${LOG_FORMAT:-${LOG_FORMAT_DEFAULT}}"
  LOG_LEVEL="${LOG_LEVEL:-${LOG_LEVEL_DEFAULT}}"
  LOG_OUTPUT="${LOG_OUTPUT:-${LOG_OUTPUT_DEFAULT}}"
  P2P_BLOCK_INTEREST="${P2P_BLOCK_INTEREST:-${P2P_BLOCK_INTEREST_DEFAULT}}"
  P2P_MESSAGE_INTEREST="${P2P_MESSAGE_INTEREST:-${P2P_MESSAGE_INTEREST_DEFAULT}}"
  NODE_SECRET="${NODE_SECRET:-${NODE_SECRET_DEFAULT}}"
  MAX_CONNECTIONS="${MAX_CONNECTIONS:-${MAX_CONNECTIONS_DEFAULT}}"

  return 0
}

function generate_node_config(){
  mkdir -p "${config_dir}"

  # Create node config file, apply log and topics
  cat << EOF > "${node_config}"
{
  "log": [
    {
      "format": "${LOG_FORMAT}",
      "level": "${LOG_LEVEL}",
      "output": "${LOG_OUTPUT}"
    }
  ],
  "p2p": {
    "topics_of_interest": {
      "blocks": "${P2P_BLOCK_INTEREST}",
      "messages": "${P2P_MESSAGE_INTEREST}"
    },
    "trusted_peers": 
EOF

  # Include trusted peers if applicable
  if ! ${NO_PEERS} ; then
    cat ${TRUSTED_PEERS_FILE} >> "${node_config}"
  else
    cat "[]" >> "${node_config}"
  fi

  # Add in public and listen addresses
  cat << EOF >> "${node_config}"
    ,
    "public_address": "${PUBLIC_ADDRESS}",
    "listen_address": "${LISTEN_ADDRESS}",
    "max_connections": ${MAX_CONNECTIONS}
  }
EOF

  # Add storage if its been specified 
  if [ -n "${STORAGE_PATH}" ]; then
    sed '$s/$/,/'
    echo "\"storage\": \"$(cat ${STORAGE_PATH})\"" >> "${node_config}"
  fi

  # Complete the json object
  echo "}" >> "${node_config}"

  # cat out the file to stdout for debuging/logging
  config=`cat "${config}"`
  >&2 echo "Node Configuration File:\n ${config}"
}

function start_jormungandr(){

  args="--genesis-block-hash ${GENESIS_HASH} --config /home/cardano/jormungandr/configuration/node_config.yaml"
  
  if ${NODE_SECRET}; then
    args="${args} --secret /home/cardano/jormungandr/configuration/node_secret.yaml"
  fi

  jormungandr ${args}
}

function main(){
  options "$@" || return $?
  generate_node_config
  start_jormungandr || return $?
}

main "$@"