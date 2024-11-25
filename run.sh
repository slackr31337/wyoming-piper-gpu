#!/usr/bin/env bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cudnn/lib/:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib:/usr/local/lib/python3.10/dist-packages/nvidia/curand/lib/:/usr/local/lib/python3.10/dist-packages/nvidia/cufft/lib/:/usr/local/lib/python3.10/dist-packages/nvidia/cuda_runtime/lib/:/usr/local/lib/python3.10/dist-packages/nvidia/cuda_nvrtc/lib/
python3 -m wyoming_piper \
    --piper '/usr/share/piper/piper' \
    --cuda \
    --uri 'tcp://0.0.0.0:10200' \
    --data-dir /data \
    --data-dir /share/piper \
    --download-dir /data --debug "$@"
