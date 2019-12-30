# -----------------------------------
# Jormungandr Test Network Node Image
# https://github.com/input-output-hk/jormungandr
# -----------------------------------

# build dependencies + node from source, then output to ~/bin
FROM alpine:3.11.2 AS builder
USER root

RUN apk update \
    && apk add curl git jq wget autoconf automake libtool make g++ unzip \
    && mkdir -p /tmp/{bin,scripts}
COPY scripts /tmp/scripts
WORKDIR /tmp/scripts
RUN chmod -R u+rwx /tmp/scripts \
    && /tmp/scripts/build_protoc.sh \
    && /tmp/scripts/build_rust.sh \
    && /tmp/scripts/build_jormungandr.sh

# copy compiled binaries into fresh image.
FROM alpine:3.11.2 AS node
RUN addgroup -S cardano \
    && adduser --disabled-password --gecos '' -S cardano -G cardano \
    && echo '%cardano ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY --from=builder:latest --chown=cardano:cardano /tmp/bin/* /usr/local/bin
USER cardano
ENTRYPOINT [ "echo", "Files In Bin: $(ls /usr/local/bin)" ]