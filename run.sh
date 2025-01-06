#!/usr/bin/env bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/app/lib/python3.10/site-packages/nvidia/cudnn/lib/:/app/lib/python3.10/site-packages/nvidia/cublas/lib:/app/lib/python3.10/site-packages/nvidia/curand/lib/:/app/lib/python3.10/site-packages/nvidia/cufft/lib/:/app/lib/python3.10/site-packages/nvidia/cuda_runtime/lib/:/app/lib/python3.10/site-packages/nvidia/cuda_nvrtc/lib/

# Run wyoming-piper server
source /app/bin/activate

/app/bin/python3 -m wyoming_piper \
    --piper '/usr/share/piper/piper' \
    --uri 'tcp://0.0.0.0:10200' \
    --length-scale "${PIPER_LENGTH:-1.0}" \
    --noise-scale "${PIPER_NOISE:-0.667}" \
    --noise-w "${PIPER_NOISEW:-0.333}" \
    --speaker "${PIPER_SPEAKER:-0}" \
    --voice "${PIPER_VOICE:-en_US-amy-medium}" \
    --max-piper-procs "${PIPER_PROCS:-1}" \
    --data-dir /data \
    --download-dir /data \
    --cuda "$@"
