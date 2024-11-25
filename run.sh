#!/usr/bin/env bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cudnn/lib/
python3 -m wyoming_piper \
    --piper 'piper' \
    --cuda \
    --uri 'tcp://0.0.0.0:10200' \
    --data-dir /data \
    --download-dir /data "$@"
