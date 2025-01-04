FROM nvidia/cuda:12.2.2-base-ubuntu22.04

WORKDIR /usr/src

ARG TARGETARCH=amd64
ARG TARGETVARIANT=
ARG WYOMING_PIPER_VERSION='1.4.0'
ARG PIPER_RELEASE='1.2.0'

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
    mkdir -p /app /data &&\
    python3 -m venv /app &&\
    . /app/bin/activate &&\
    pip3 install --no-cache-dir \
        torch

RUN \
    . /app/bin/activate && \
    pip3 install --no-cache-dir --force-reinstall --no-deps\
        "piper-tts==${PIPER_RELEASE}" \
        piper_phonemize==1.1.0 \
        &&\
    \
    pip3 install --no-cache-dir\
        onnxruntime-gpu \
        &&\
    \
    pip3 install --no-cache-dir\
        "wyoming-piper==${WYOMING_PIPER_VERSION}"\
        &&\
    \
    wget \
        "https://github.com/rhasspy/piper/releases/download/v${PIPER_RELEASE}/piper_${TARGETARCH}${TARGETVARIANT}.tar.gz" -O -|tar -zxvf - -C /usr/share

    # pip3 install --no-cache-dir --force-reinstall --no-deps\
    #    piper_phonemize-1.1.0-py3-none-any.whl &&\
    #    \
    #    "wyoming-piper @ https://github.com/rhasspy/wyoming-piper/archive/refs/tags/v${WYOMING_PIPER_VERSION}.tar.gz" 
    # wget https://github.com/rhasspy/piper-phonemize/releases/download/v1.1.0/piper_phonemize-1.1.0-cp310-cp310-manylinux_2_28_x86_64.whl &&\
    # mv piper_phonemize-1.1.0-cp310-cp310-manylinux_2_28_x86_64.whl piper_phonemize-1.1.0-py3-none-any.whl &&\
    # rm -r piper_phonemize-1.1.0-py3-none-any.whl &&\

# Patch to enable CUDA arguments for piper
COPY patch/wyoming-piper_cuda.patch /tmp/
RUN \
    ls -l /app/lib; ls -l /app/lib/* &&\
    cd /app/lib/python3.10/site-packages/wyoming_piper/ &&\
    patch -p0 < /tmp/wyoming-piper_cuda.patch

# Clean up
RUN \
    rm -rf /var/lib/apt/lists/* /*.deb /tmp/*

WORKDIR /app
COPY run.sh /app/
RUN chmod +x /app/run.sh

EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]