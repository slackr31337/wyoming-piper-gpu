#!/usr/bin/env bash

LOGGING=""
if [[ "${LOG_LEVEL}" == "debug" ]]; then
    LOGGING="--debug "
fi

# Run wyoming-piper server
/app/bin/python3 -m wyoming_piper \
    --piper '/app/piper/piper' \
    --uri "${PIPER_URI:-tcp://0.0.0.0:10200}" \
    --length-scale "${PIPER_LENGTH:-1.0}" \
    --noise-scale "${PIPER_NOISE:-0.667}" \
    --noise-w "${PIPER_NOISEW:-0.333}" \
    --speaker "${PIPER_SPEAKER:-0}" \
    --sentence-silence "${PIPER_SILENCE:-1.2}" \
    --voice "${PIPER_VOICE:-en_US-amy-medium}" \
    --max-piper-procs "${PIPER_PROCS:-1}" \
    --data-dir "${DATA_DIR:-/data}" \
    --download-dir "${DOWNLOAD_DIR:-/data}"  \
    --use-cuda ${LOGGING}"$@"
