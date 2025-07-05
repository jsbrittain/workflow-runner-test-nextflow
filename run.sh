#!/bin/bash

# We build docker container with nextflow, conda, and docker.io tools
docker build \
    --platform linux/amd64 \
    -t nextflow-conda \
    .

# Note:
#  - nextflow uses /tmp for the scratch folder when it is enabled, and this needs
#    to be shared across containers
#  - the cwd is mounted at the same path so that siblings are volume mounted relative
#    to the host path(s)
#  - performance could be improved with conda by mounting the host cache, or extending
#    the image to include pre-build environments
docker run --rm -it \
  --platform linux/amd64 \
  -v "/tmp":"/tmp" \
  -v "$(pwd)":"$(pwd)" \
  -w "$(pwd)" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  nextflow-conda nextflow run main.nf
