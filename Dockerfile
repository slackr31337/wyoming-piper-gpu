##########################################
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 AS build

ARG TARGETARCH=linux_x86_64
ARG WYOMING_PIPER_VERSION="1.5.2"
ARG PIPER_VERSION="1.2.0"
ARG PIPER_PHONEMIZE_VERSION="1.1.0"

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

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
        python3-pip \
        ca-certificates \
        pkg-config

WORKDIR /app

COPY run.sh .

RUN \
    mkdir -p /app/lib &&\
    python3 -m venv /app &&\
    . /app/bin/activate && \
    \
    /app/bin/python3 -m pip install --no-cache-dir --force-reinstall --no-deps \
        "piper-tts==${PIPER_VERSION}" &&\
    \
    wget -q https://github.com/rhasspy/piper-phonemize/releases/download/v${PIPER_PHONEMIZE_VERSION}/piper_phonemize-${PIPER_PHONEMIZE_VERSION}-cp310-cp310-manylinux_2_28_x86_64.whl \
        -O /tmp/piper_phonemize-${PIPER_PHONEMIZE_VERSION}-py3-none-any.whl &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir --force-reinstall --no-deps \
        /tmp/piper_phonemize-${PIPER_PHONEMIZE_VERSION}-py3-none-any.whl &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir \
        "wyoming-piper @ https://github.com/rhasspy/wyoming-piper/archive/refs/tags/v${WYOMING_PIPER_VERSION}.tar.gz"

RUN \
    cd /app/lib/python3.10/site-packages/wyoming_piper/; \
    for file in /tmp/wyoming_piper*.diff;do patch -p0 --forward < $file;done;
    # cp /build/install/lib*.so* /app/lib/

##########################################
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 AS dist

ENV PYTHONUNBUFFERED=1

RUN \
    mkdir -p /data /app &&\
    apt-get update && apt-get upgrade -y &&\
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        vim \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
        ca-certificates

RUN rm -rf /root/.cache/pip /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app .
# RUN ln -s /app/piper/espeak-ng-data /usr/share/espeak-ng-data

EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]