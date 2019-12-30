# -----------------------------------
# Jormungandr Test Network Node Image
# https://github.com/input-output-hk/jormungandr
# -----------------------------------

# baseline stage
# setup min. requirements
ARG cardano_network="jormungandr"
FROM ubuntu:disco AS baseline
USER root

RUN apt-get update \
    && apt-get install -y curl git jq snapd wget \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' cardano \
    && adduser cardano sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /home/cardano/{daedalus/bin,scripts,protoc}
COPY scripts /home/cardano/scripts
RUN chmod -R u+rwx /home/cardano \
    && chown -R cardano:cardano /home/cardano

# build stage
# build protoc, rust + cardano node from source
FROM baseline AS builds
WORKDIR /home/cardano/protoc
RUN apt-get update \
    && apt-get install -y autoconf automake libtool make g++ unzip \
    && /home/cardano/scripts/build_protoc.sh \
    && cd /home/cardano/daedalus \
    && /home/cardano/scripts/build_rust.sh \
    && /home/cardano/scripts/build_${cardano_network}.sh

# node stage - copy compiled applications to baseline.
FROM baseline AS node
COPY --from=builds:latest --chown=cardano:cardano /home/cardano/daedalus/bin /usr/local/bin
USER cardano
ENTRYPOINT [ "echo", 'testing that it gets this far.' ]

