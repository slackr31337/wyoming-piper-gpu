#!/usr/bin/env bash

export LD_LIBRARY_PATH=/app/lib/:$LD_LIBRARY_PATH

# Run wyoming-piper server
source /app/bin/activate

/app/bin/python3 -m wyoming_piper \
    --piper '/app/piper/piper' \
    --uri 'tcp://0.0.0.0:10200' \
    --length-scale "${PIPER_LENGTH:-1.0}" \
    --noise-scale "${PIPER_NOISE:-0.667}" \
    --noise-w "${PIPER_NOISEW:-0.333}" \
    --speaker "${PIPER_SPEAKER:-0}" \
    --voice "${PIPER_VOICE:-en_US-amy-medium}" \
    --max-piper-procs "${PIPER_PROCS:-1}" \
    --data-dir /data \
    --download-dir /data \
    --use-cuda "$@"
