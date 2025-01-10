##########################################
FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04 AS build

ARG PIPER_BRANCH="2023.11.14-2"

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        vim \
        git \
        build-essential \
        cmake \
        ca-certificates \
        curl \
        pkg-config

WORKDIR /build

RUN \
    git clone -b "${PIPER_BRANCH}" https://github.com/rhasspy/piper.git /build

RUN cmake -Bbuild -DCMAKE_INSTALL_PREFIX=install
RUN cmake --build build --config Release
RUN cmake --install build

WORKDIR /dist
RUN mkdir -p piper && \
    cp -dR /build/install/* ./piper/

RUN /dist/piper/piper --help

##########################################
FROM nvidia/cuda:12.3.2-cudnn9-runtime-ubuntu22.04 AS dist

ARG TARGETARCH=linux_x86_64
ARG WYOMING_PIPER_VERSION="1.5.0"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

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
        python3-pip 

RUN \
    mkdir -p /data /app/piper &&\
    ln -s /app/piper /usr/share/espeak-ng-data &&\
    python3 -m venv /app

COPY --from=build /dist/piper/* /app/piper/
COPY requirements.txt /app/
RUN \
    . /app/bin/activate && \
    /app/bin/python3 -m pip install --no-cache-dir --no-deps \
        -r /app/requirements.txt \
        &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir \
        "wyoming-piper @ https://github.com/rhasspy/wyoming-piper/archive/refs/tags/v${WYOMING_PIPER_VERSION}.tar.gz" \
        &&\
    \
    PIPER_VERSION=$(wget "https://api.github.com/repos/rhasspy/piper/releases/latest" -O -|awk '/tag_name/{print $4;exit}' FS='[""]') && \
    \
    wget "https://github.com/rhasspy/piper/releases/download/${PIPER_VERSION}/piper_${TARGETARCH}.tar.gz" -O -|tar -zxvf - -C /usr/share
    
# Patch to enable CUDA arguments for piper
COPY patches/* /tmp/
RUN \
    cd /app/lib/python3.10/site-packages/wyoming_piper/; \
    for file in /tmp/wyoming_piper*.diff;do patch -p0 --forward < $file;done; \
    cp /app/lib/python3.10/site-packages/onnxruntime/capi/libonnxruntime* /app/lib/ &&\
    mv /app/piper/lib*.so* /app/lib/ 

# Clean up
RUN rm -rf /root/.cache/pip /var/lib/apt/lists/* /tmp/*

WORKDIR /app
COPY run.sh /app/

EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]