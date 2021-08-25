# Start with the livekit-server image
FROM livekit/livekit-server:latest

# Add bind-tools so we have dig available
RUN apk add --no-cache bind-tools

# Copy in entrypoint and config
COPY entrypoint.sh livekit-config.yaml /

# Start the server
ENTRYPOINT ["/entrypoint.sh"]