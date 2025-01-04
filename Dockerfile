FROM nvidia/cuda:12.2.2-base-ubuntu22.04

WORKDIR /usr/src

ARG TARGETARCH=amd64
ARG TARGETVARIANT=
ARG WYOMING_PIPER_VERSION='1.4.0'
ARG PIPER_RELEASE='1.2.0'

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
    /app/bin/python3 -m pip install --no-cache-dir --force-reinstall --no-deps\
        "piper-tts==${PIPER_RELEASE}" \
        &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir \
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
    cd /app/lib/python3.10/site-packages/wyoming_piper/;\
    patch -p0 --forward < /tmp/wyoming-piper_cuda.patch || true

# Clean up
RUN \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY tests/* /app/tests/

WORKDIR /app
COPY run.sh /app/
RUN chmod +x /app/run.sh

EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]