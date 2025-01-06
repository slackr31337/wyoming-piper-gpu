FROM nvidia/cuda:12.2.2-base-ubuntu22.04

WORKDIR /usr/src

ARG TARGETARCH=linux_x86_64
ARG WYOMING_PIPER_VERSION="1.5.0"
ARG PIPER_RELEASE="1.2.0"

ENV DEBIAN_FRONTEND=noninteractive

COPY patches/* /tmp/

RUN \
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        vim \
        patch \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip

RUN \
    mkdir -p /data /app &&\
    \
    python3 -m venv /app

RUN \
    . /app/bin/activate && \
    /app/bin/python3 -m pip install --no-cache-dir --no-deps \
        "piper-tts==${PIPER_RELEASE}" \
        &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir \
        "wyoming-piper @ https://github.com/rhasspy/wyoming-piper/archive/refs/tags/v${WYOMING_PIPER_VERSION}.tar.gz" \
        &&\
    \
    PIPER_VERSION=$(wget "https://api.github.com/repos/rhasspy/piper/releases/latest" -O -|awk '/tag_name/{print $4;exit}' FS='[""]') && \
    \
    wget "https://github.com/rhasspy/piper/releases/download/${PIPER_VERSION}/piper_${TARGETARCH}.tar.gz" -O -|tar -zxvf - -C /app
    
# Patch to enable CUDA arguments for piper
RUN \
    cd /app/lib/python3.10/site-packages/wyoming_piper/; \
    for file in /tmp/wyoming_piper*.diff;do patch -p0 --forward < $file;done; \
    cd /app/lib/python3.10/site-packages/piper/; \
    for file in /tmp/piper*.diff;do patch -p0 --forward < $file;done; \
    true

# Clean up
RUN rm -rf /root/.cache/pip /var/lib/apt/lists/* /tmp/*

WORKDIR /app
COPY run.sh /app/

EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]