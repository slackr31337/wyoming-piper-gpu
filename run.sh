#!/usr/bin/env bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cudnn/lib/:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib:/usr/local/lib/python3.10/dist-packages/nvidia/curand/lib/:/usr/local/lib/python3.10/dist-packages/nvidia/cufft/lib/:/usr/local/lib/python3.10/dist-packages/nvidia/cuda_runtime/lib/:/usr/local/lib/python3.10/dist-packages/nvidia/cuda_nvrtc/lib/

PIPER_CPU="/usr/share/piper/piper"
PIPER_GPU="/usr/local/bin/piper"

source /app/bin/activate
/app/bin/python3 -m wyoming_piper \
    --piper '/usr/local/bin/piper' \
    --cuda \
    --uri 'tcp://0.0.0.0:10200' \
    --data-dir /data \
    --download-dir /data --debug "$@"
