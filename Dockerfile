# -----------------------------------
# Jormungandr Test Network Node Image
# https://github.com/input-output-hk/jormungandr
# -----------------------------------
ARG cardano_network="jormungandr"

FROM ubuntu:disco

USER root

# Install OS Packages
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    curl \
    g++ \
    git \
    jq \
    libtool \
    make \
    snapd \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Create an account for the node.
RUN adduser --disabled-password --gecos '' cardano && \
    adduser cardano sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /home/cardano/{daedalus,scripts,protoc,rust}
COPY scripts /home/cardano/scripts
RUN chmod -R u+rwx /home/cardano && \
    chown -R cardano:cardano /home/cardano

# Build & Install Protocol Buffers compiler, a prereq for building from source.
# https://github.com/protocolbuffers/protobuf/releases
WORKDIR /home/cardano/protoc
RUN /home/cardano/scripts/build_protoc.sh

# Install Rust, so we can compile jormungandr from source
ENV PATH ${HOME}/.cargo/bin:$PATH
WORKDIR /home/cardano/rust
RUN /home/cardano/scripts/build_rust.sh

WORKDIR /home/cardano/daedalus
RUN /home/cardano/scripts/build_jormungandr.sh

USER cardano

ENTRYPOINT [ "echo 'testing that it gets this far.'" ]

