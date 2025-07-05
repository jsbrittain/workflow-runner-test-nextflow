FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    curl wget bzip2 bash git ca-certificates xz-utils \
    openjdk-17-jre-headless \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    ln -s /opt/conda/bin/conda /usr/local/bin/conda
RUN conda config --remove channels defaults && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash && \
    mv nextflow /usr/local/bin/

WORKDIR /workspace
