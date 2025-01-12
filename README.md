# wyoming-piper-gpu
Wyoming Piper docker container with Nvidia GPU support for Home-Assistant

https://github.com/rhasspy/wyoming-piper


[![Publish Docker image](https://github.com/slackr31337/wyoming-piper-gpu/actions/workflows/docker-image.yml/badge.svg)](https://github.com/slackr31337/wyoming-piper-gpu/actions/workflows/docker-image.yml)


docker pull ghcr.io/slackr31337/wyoming-piper-gpu:latest


# Use environment variable to set piper voice

PIPER_VOICE="en_US-lessac-medium"

PIPER_LENGTH="1.0"

PIPER_NOISE="0.667"

PIPER_NOISEW="0.333"

PIPER_SPEAKER="0"

PIPER_SILENCE="1.2"
