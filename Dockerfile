FROM nvidia/cuda:11.7.1-base-ubuntu22.04

# Install Piper
WORKDIR /usr/src

ARG TARGETARCH=amd64
ARG TARGETVARIANT=
ARG PIPER_LIB_VERSION=1.4.0
ARG WYOMING_PIPER_VERSION='1.5.0'
ARG PIPER_RELEASE='1.2.0'

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        curl \
        python3 \
        python3-pip \
    \
    && rm -rf /var/lib/apt/lists/*

RUN \
    pip3 install --no-cache-dir -U \
        setuptools \
        wheel \
    \
    && pip3 install --no-cache-dir torch \
    \
    && wget https://github.com/rhasspy/piper-phonemize/releases/download/v1.1.0/piper_phonemize-1.1.0-cp39-cp39-manylinux_2_28_x86_64.whl \
    \
    && mv piper_phonemize-1.1.0-cp310-cp310-manylinux_2_28_x86_64.whl piper_phonemize-1.1.0-py3-none-any.whl \
    \
    && pip3 install --no-cache-dir --force-reinstall --no-deps \
        "piper-tts==${PIPER_RELEASE}" \
    \
    && pip3 install --no-cache-dir --force-reinstall --no-deps \
        piper_phonemize-1.1.0-py3-none-any.whl \
    \
    && pip3 install --no-cache-dir \
        onnxruntime-gpu \
        "wyoming-piper @ https://github.com/rhasspy/wyoming-piper/archive/refs/tags/v${WYOMING_PIPER_VERSION}.tar.gz" \
    \
    && rm -r piper_phonemize-1.1.0-py3-none-any.whl \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        python3-dev \
    \
    && rm -rf /var/lib/apt/lists/*

# Patch to enable CUDA in piper
COPY patch/process.py /usr/local/lib/python3.10/dist-packages/wyoming_piper/
COPY patch/__main__.py /usr/local/lib/python3.10/dist-packages/wyoming_piper/

WORKDIR /
COPY run.sh ./

EXPOSE 10200

ENTRYPOINT ["bash", "-c", "exec run.sh \"${@}\"", "--"]