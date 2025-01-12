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
        git \
        build-essential \
        cmake \
        pkg-config

WORKDIR /app

COPY run.sh .
COPY patches/* /tmp/

RUN \
    mkdir -p /app/lib /app/share/espeak-ng-data /app/include/piper-phonemize &&\
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
    wget -q https://github.com/rhasspy/piper-phonemize/releases/download/v${PIPER_PHONEMIZE_VERSION}/libpiper_phonemize-amd64.tar.gz -O -| \
    tar -zxvf - -C /app &&\
    \
    mv /app/etc/* /app/share/ &&\
    mv /app/include/*.hpp /app/include/piper-phonemize/ &&\
    mv /app/include/cpu_provider_factory.h /app/include/piper-phonemize/ &&\
    mv /app/include/provider_options.h /app/include/piper-phonemize/ &&\
    \
    LATEST_PIPER_VERSION=$(wget -q "https://api.github.com/repos/rhasspy/piper/releases/latest" -O -|awk '/tag_name/{print $4;exit}' FS='[""]') && \
    \
    wget "https://github.com/rhasspy/piper/releases/download/${LATEST_PIPER_VERSION}/piper_${TARGETARCH}.tar.gz" -O -|tar -zxvf - -C /usr/share &&\
    \
    /app/bin/python3 -m pip install --no-cache-dir \
        "wyoming-piper @ https://github.com/rhasspy/wyoming-piper/archive/refs/tags/v${WYOMING_PIPER_VERSION}.tar.gz"


WORKDIR /work

RUN git clone https://github.com/rhasspy/piper.git .

RUN cmake -Bbuild -DCMAKE_INSTALL_PREFIX=install -DPIPER_PHONEMIZE_DIR=/app
RUN cmake --build build --config Release
RUN cmake --install build

RUN mkdir -p /app/piper && \
    mv /work/install/lib*.so* /app/lib/ &&\
    cp -rf /work/install/* /app/piper/

RUN ./app/piper/piper --help

RUN \
    cd /app/lib/python3.10/site-packages/wyoming_piper/; \
    for file in /tmp/wyoming_piper*.diff;do patch -p0 --forward < $file;done;

##########################################
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 AS dist

ENV PYTHONUNBUFFERED=1
ENV PATH="/bin:$PATH"

RUN \
    mkdir -p /data /app &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends \
        wget \
        curl \
        vim \
        python3 \
        python3-pip \
        ca-certificates

RUN rm -rf /root/.cache/pip /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app .

EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]