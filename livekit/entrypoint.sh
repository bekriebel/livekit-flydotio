#!/bin/sh
set -e

# Set the node's IP based on the current app name
export NODE_IP=$(dig +short $FLY_APP_NAME.fly.dev)

# Start the livekit-server
./livekit-server --config ./livekit-config.yaml