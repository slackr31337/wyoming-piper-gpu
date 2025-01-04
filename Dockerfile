FROM nvidia/cuda:12.2.2-base-ubuntu22.04

WORKDIR /usr/src

ARG TARGETARCH=amd64
ARG TARGETVARIANT=
ARG WYOMING_PIPER_VERSION="1.4.0"
ARG PIPER_RELEASE="1.2.0"
ARG PIPER_URL="https://github.com/rhasspy/piper/releases/download/v${PIPER_RELEASE}/piper_${TARGETARCH}${TARGETVARIANT}.tar.gz"

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        patch \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip

RUN \
    mkdir -p /data /app/tests &&\
    python3 -m venv /app &&\
    . /app/bin/activate &&\
    /app/bin/python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel &&\
    /app/bin/python3 -m pip install --no-cache-dir \
        torch \
        py-cpuinfo \
        psutil 
        # tensorflow[and-cuda] \

RUN \
    . /app/bin/activate && \
    /app/bin/python3 -m pip install --no-cache-dir --no-deps\
        "piper-tts==${PIPER_RELEASE}" \
        &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir\
        piper_phonemize==1.1.0 \
        &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir\
        onnxruntime-gpu \
        &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir\
        "wyoming-piper==${WYOMING_PIPER_VERSION}"\
        &&\
    \
    wget "${PIPER_URL}" -O -|tar -zxvf - -C /app


# Patch to enable CUDA arguments for piper
COPY patch/* /tmp/
RUN \
    cd /app/lib/python3.10/site-packages/wyoming_piper/;\
    for file in /tmp/*.diff;do patch -p0 --forward < $file;done;\
    true

# Clean up
RUN \
    rm -rf /root/.cache/pip /var/lib/apt/lists/* /tmp/*

WORKDIR /app
COPY run.sh /app/
RUN chmod +x /app/run.sh

EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]