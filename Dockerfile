# -----------------------------------
# Jormungandr Test Network Node Image
# https://github.com/input-output-hk/jormungandr
# -----------------------------------

# baseline stage
ARG cardano_network="jormungandr"
FROM ubuntu:disco AS baseline
USER root

RUN apt-get update \
    && apt-get install -y curl git jq snapd wget \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' cardano \
    && adduser cardano sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /home/cardano/{daedalus,scripts,protoc,rust}
COPY scripts /home/cardano/scripts
RUN chmod -R u+rwx /home/cardano \
    && chown -R cardano:cardano /home/cardano

# protoc stage - build protocol buffers from source
FROM baseline AS protoc
WORKDIR /home/cardano/protoc
RUN apt-get update \
    && apt-get install -y autoconf automake libtool make g++ unzip \
    && /home/cardano/scripts/build_protoc.sh

# rust stage - build rust from source
FROM baseline AS rust
WORKDIR /home/cardano/rust
RUN /home/cardano/scripts/build_rust.sh

# daedalus stage - build cardano node from source
FROM baseline AS daedalus
WORKDIR /home/cardano/daedalus
RUN /home/cardano/scripts/build_${cardano_network}.sh

USER cardano
ENTRYPOINT [ "echo 'testing that it gets this far.'" ]

