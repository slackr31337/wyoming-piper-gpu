#!/usr/bin/env bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cudnn/lib/
python3 -m wyoming_piper \
    --piper '/usr/share/piper/piper' \
    --uri 'tcp://0.0.0.0:10200' \
    --data-dir /data \
    --data-dir /share/piper \
    --download-dir /data "$@"
