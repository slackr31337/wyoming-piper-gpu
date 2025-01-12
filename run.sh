#!/usr/bin/env bash

export LD_LIBRARY_PATH=/app/lib/:/usr/local/cuda-11.8/targets/x86_64-linux/lib:$LD_LIBRARY_PATH

# Run wyoming-piper server
source /app/bin/activate
/app/bin/python3 -m wyoming_piper \
    --piper '/app/piper/piper' \
    --uri 'tcp://0.0.0.0:10200' \
    --length-scale "${PIPER_LENGTH:-1.0}" \
    --noise-scale "${PIPER_NOISE:-0.667}" \
    --noise-w "${PIPER_NOISEW:-0.333}" \
    --speaker "${PIPER_SPEAKER:-0}" \
    --sentence-silence "${PIPER_SILENCE:-1.2}" \
    --voice "${PIPER_VOICE:-en_US-amy-medium}" \
    --max-piper-procs "${PIPER_PROCS:-1}" \
    --data-dir /data \
    --download-dir /data \
    --use-cuda "$@"
