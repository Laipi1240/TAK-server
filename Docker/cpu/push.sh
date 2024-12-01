#!/usr/bin/env bash

REPOSITORY="laipi1240/tak-server"
TAG="cpu"

IMG="${REPOSITORY}:${TAG}"

docker image push "${IMG}"
