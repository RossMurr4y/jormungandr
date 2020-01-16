# -----------------------------------
# Jormungandr Test Network Node Image
# https://github.com/input-output-hk/jormungandr
# -----------------------------------

# build static binaries from source + output to /tmp/bin
# rust-musl-builder allows for static binaries that have no dependencies
FROM ekidd/rust-musl-builder:latest AS builder
USER rust
COPY scripts /tmp/scripts
WORKDIR /tmp/scripts
RUN sudo apt-get update \
    && sudo apt-get -y install jq libsystemd-dev \
    && sudo chmod -R u+rwx /tmp/scripts \
    && sudo chown -R rust:rust /tmp/scripts \
    && /tmp/scripts/build_jormungandr.sh \
    && /tmp/scripts/stage_jormungandr_scripts.sh

# copy compiled binaries into fresh alpine image.
FROM alpine:3.11.2 AS node
RUN addgroup -S cardano \
    && adduser -u 1000 --disabled-password --gecos '' -S cardano -G cardano \
    && echo '%cardano ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY --from=builder --chown=cardano:cardano /tmp/bin/ /usr/local/bin
USER cardano
# testing that the binaries work
ENTRYPOINT ["/usr/local/bin/node_init.sh"]