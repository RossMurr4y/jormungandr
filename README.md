# daedalus

This repository contains the necessary parts to build and deploy a Cardano staking node on the jormungandr test network.
#
## Image Build

### Description
The image build process occurs in two stages. The first is the "builder" stage, that makes use of the ekidd/rust-musl-builder docker image to compile the jormungandr binaries using static linking. This will ensure the binaries are self-contained.

The second stage is the "node" stage which uses a clean Alpine container image. A user account is setup on the base image ("cardano") and the self-contained binaries are copied over from the builder stage.

### Prerequisites
- [docker](https://docs.docker.com/install/)

### Commands
```
cd <Dockerfile dir>
docker build .
```
#
## Run Container Image

### Description
The following commands can be used to trigger any of the commands above through docker. By doing so you should be able to perform all actions necessary to configgure and run a node on the cardano network.

[Jormungandr User Guide](https://input-output-hk.github.io/jormungandr/introduction.html)

### List of Commands
- [jormungandr](https://input-output-hk.github.io/jormungandr/introduction.html)
- [jcli](https://input-output-hk.github.io/jormungandr/jcli/introduction.html)

See their corresponding documentation for sub-commands, or use the ```--help``` argument on the container (see below).

### Usage

#### Retrieve image name
```
docker image list
```

#### Run "jormungandr" (default usage)
```
docker run <image-name>

# Example - run the default image.
docker run rossmurr4y/daedalus

# Using version tags
docker run rossmurr4y/daedalus:latest
```

#### Run "jcli"
```
# docker run --entrypoint jcli <image-name> [<jcli-arguments>]

# Example: run "jcli utils --help"
docker run --entrypoint jcli rossmurr4y/daedalus utils --help
```