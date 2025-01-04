#!/usr/bin/env bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/lib/python3.10/site-packages/nvidia/cudnn/lib/:/app/lib/python3.10/site-packages/nvidia/cublas/lib:/app/lib/python3.10/site-packages/nvidia/curand/lib/:/app/lib/python3.10/site-packages/nvidia/cufft/lib/:/app/lib/python3.10/site-packages/nvidia/cuda_runtime/lib/:/app/lib/python3.10/site-packages/nvidia/cuda_nvrtc/lib/

# Run wyoming-piper server
source /app/bin/activate

/app/bin/python3 -m wyoming_piper \
    --piper '/app/bin/piper' \
    --uri 'tcp://0.0.0.0:10200' \
    --data-dir /data \
    --download-dir /data \
    --cuda "$@"
