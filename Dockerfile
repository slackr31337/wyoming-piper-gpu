FROM nvidia/cuda:11.7.1-base-ubuntu22.04

# Install Piper
WORKDIR /usr/src

ARG TARGETARCH=amd64
ARG TARGETVARIANT=
ARG PIPER_LIB_VERSION=1.4.0
ARG PIPER_RELEASE=v1.2.0

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        python3 \
        python3-pip \
    \
    && pip3 install --no-cache-dir -U \
        setuptools \
        wheel \
    \
    && pip3 install --no-cache-dir torch \
    \
    && pip3 install --no-cache-dir \
        "wyoming-piper==${PIPER_LIB_VERSION}" \
    \
    && curl -L -s \
        "https://github.com/rhasspy/piper/releases/download/${PIPER_RELEASE}/piper_${TARGETARCH}${TARGETVARIANT}.tar.gz"|tar -zxvf - -C /usr/share \
    \
    && pip3 install --no-cache-dir \
        onnxruntime-gpu \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Patch process.py to pass --cuda argument to piper
COPY patch/process.py /usr/local/lib/python3.10/dist-packages/wyoming_piper/

WORKDIR /
COPY run.sh ./

EXPOSE 10200

ENTRYPOINT ["bash", "/run.sh"]
