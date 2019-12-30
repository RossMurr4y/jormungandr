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

RUN mkdir -p /home/cardano/{daedalus,scripts,protoc}
COPY scripts /home/cardano/scripts
RUN chmod -R u+rwx /home/cardano && \
    chown -R cardano:cardano /home/cardano

# Build & Install Protocol Buffers compiler, a prereq for building from source.
# https://github.com/protocolbuffers/protobuf/releases
WORKDIR "/home/cardano/protoc"
RUN /home/cardano/scripts/build_protoc.sh

# Set up a working directory
RUN mkdir "/home/cardano/daedalus" && cd "/home/cardano/daedalus"

# Install Rust, so we can compile jormungandr from source
# https://www.rust-lang.org/tools/install
ENV PATH ${HOME}/.cargo/bin:$PATH
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    rustup install stable && \
    rustup default stable

# Clone cardano network from source
RUN git clone --recurse-submodules "https://github.com/input-output-hk/${cardano_network}.git" && \
    cd jormungandr

# Retrieve the latest tag from the source repo & checkout
# (cant just use latest tag, as some tags may be staged but not latest release.)
RUN latest_version=$(curl --silent "https://api.github.com/repos/input-output-hk/${cardano_network}/releases/latest" | jq -r .tag_name) && \
    git checkout "tags/${latest_version}"

# Build cardano network & jcli from source
RUN cargo install --path "${cardano_network}" --features systemd && \
    cargo install --path jcli

# Create a Wallet address to be paid into from the faucet
#RUN wget https://raw.githubusercontent.com/input-output-hk/jormungandr-qa/master/scripts/createAddress.sh

USER cardano

ENTRYPOINT [ "echo 'testing that it gets this far.'" ]

