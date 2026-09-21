FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bwa \
        samtools \
        bcftools \
        tabix \
        fastqc \
        mafft \
        iqtree \
        seqkit \
        unzip \
        gzip \
        curl \
        wget \
        python3 \
        python3-pip \
        python3-venv \
        less \
        nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ClipKIT
RUN python3 -m venv /opt/clipkit && \
    /opt/clipkit/bin/pip install --upgrade pip && \
    /opt/clipkit/bin/pip install clipkit && \
    ln -s /opt/clipkit/bin/clipkit /usr/local/bin/clipkit

# Ubuntu may call IQ-TREE "iqtree" rather than "iqtree2"
RUN if command -v iqtree >/dev/null 2>&1 && \
       ! command -v iqtree2 >/dev/null 2>&1; then \
       ln -s "$(command -v iqtree)" /usr/local/bin/iqtree2; \
    fi

USER vscode
