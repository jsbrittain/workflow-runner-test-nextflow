#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.input = "${baseDir}/data/dummy.txt"

process docker_step {
    container 'debian:bullseye-slim'

    input:
    path file

    output:
    path "docker_output.txt"

    script:
    """
    echo "Docker saw file: $file" > docker_output.txt
    cat $file >> docker_output.txt
    """
}

process conda_step {
    conda 'envs/echo-env.yml'

    input:
    path file

    output:
    path "conda_output.txt"

    script:
    """
    echo "Conda saw file: $file" > conda_output.txt
    head $file >> conda_output.txt
    """
}

workflow {
    ch = Channel.fromPath(params.input, checkIfExists: true)

    docker_step(ch)
    conda_step(ch)
}
