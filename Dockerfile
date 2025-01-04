FROM nvidia/cuda:12.2.2-base-ubuntu22.04

WORKDIR /usr/src

ARG TARGETARCH=amd64
ARG TARGETVARIANT=
ARG WYOMING_PIPER_VERSION='1.5.0'
ARG PIPER_RELEASE='1.2.0'

RUN \
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        python3 \
        python3-pip

RUN \
    pip3 install --no-cache-dir \
        torch

RUN \
    pip3 install --no-cache-dir --force-reinstall --no-deps\
        "piper-tts==${PIPER_RELEASE}" \
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

# Clean up
RUN \
    rm -rf /var/lib/apt/lists/* &&\
    rm /*.deb &&\
    mkdir -p /share/piper

# Patch to enable CUDA arguments for piper
COPY patch/process.py /usr/local/lib/python3.10/dist-packages/wyoming_piper/
COPY patch/__main__.py /usr/local/lib/python3.10/dist-packages/wyoming_piper/

WORKDIR /
COPY run.sh ./
RUN chmod +x /run.sh

EXPOSE 10200

ENTRYPOINT ["bash", "/run.sh"]