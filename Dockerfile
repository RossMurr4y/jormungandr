# -----------------------------------
# Jormungandr Test Network Node Image
# https://github.com/input-output-hk/jormungandr
# -----------------------------------

# build dependencies + node from source, then output to /tmp/bin
FROM rust:latest AS builder
USER root
COPY scripts /tmp/scripts
WORKDIR /tmp/scripts
RUN apt-get update && apt-get -y install jq libsystemd-dev \
    && chmod -R u+rwx /tmp/scripts \
    && /tmp/scripts/build_jormungandr.sh

# copy compiled binaries into fresh alpine image.
FROM alpine:3.11.2 AS node
RUN addgroup -S cardano \
    && adduser --disabled-password --gecos '' -S cardano -G cardano \
    && echo '%cardano ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY --from=builder --chown=cardano:cardano /tmp/bin/ /usr/local/bin
USER cardano
# testing that the binaries work
ENTRYPOINT ["jormungandr"]
CMD ["--help"] 