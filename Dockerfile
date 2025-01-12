##########################################
FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04 AS build

ARG TARGETARCH=linux_x86_64
ARG WYOMING_PIPER_VERSION="1.5.2"
ARG PIPER_PHONEMIZE_VERSION='1.0.0'
ARG ONNXRUNTIME_VERSION="1.20.1"

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && apt-get upgrade -y &&\
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        vim \
        git \
        patch \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
        build-essential \
        cmake \
        ca-certificates \
        pkg-config

RUN \
    mkdir -p /app/lib &&\
    cd /tmp && wget -q https://github.com/microsoft/onnxruntime/releases/download/v${ONNXRUNTIME_VERSION}/onnxruntime-linux-x64-gpu-${ONNXRUNTIME_VERSION}.tgz &&\
    tar xzvf onnxruntime-linux-x64-gpu-${ONNXRUNTIME_VERSION}.tgz &&\
    cp -rfv /tmp/onnxruntime-linux-x64-gpu-${ONNXRUNTIME_VERSION}/lib/* /app/lib

WORKDIR /build

RUN \
    git clone https://github.com/rhasspy/piper.git /build

RUN ONNXRUNTIME_DIR=/app/lib cmake -Bbuild -DCMAKE_INSTALL_PREFIX=install
RUN ONNXRUNTIME_DIR=/app/lib cmake --build build --config Release
RUN ONNXRUNTIME_DIR=/app/lib cmake --install build

WORKDIR /app

RUN \
    python3 -m venv /app &&\
    cp -rfv /build/install/* /app/piper/ &&\
    chmod 755 /app/piper/piper /app/piper/espeak-ng

RUN /app/piper/piper --help

COPY requirements.txt /app/
COPY run.sh /app/
COPY patches/* /tmp/

RUN \
    . /app/bin/activate && \
    /app/bin/python3 -m pip install --no-cache-dir \
        -r /app/requirements.txt \
        &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir \
        "wyoming-piper @ https://github.com/rhasspy/wyoming-piper/archive/refs/tags/v${WYOMING_PIPER_VERSION}.tar.gz"

RUN \
    cd /app/lib/python3.10/site-packages/wyoming_piper/; \
    for file in /tmp/wyoming_piper*.diff;do patch -p0 --forward < $file;done; \
    cp /build/install/lib*.so* /app/lib/

##########################################
FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04 AS dist

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

RUN ln -s /app/piper/espeak-ng-data /usr/share/espeak-ng-data

EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]