# Use a base image with ARM compatibility. This allows the build to run on both ARMv7 (32-bit) and ARMv8 (64-bit).
# The buildx will handle switching between architectures when building.

# Set the base image to Ubuntu 20.04 for both ARM32v7 (32-bit) and ARM64 (64-bit) platforms
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (VLC, Bluetooth tools, PulseAudio, curl, etc.)
RUN apt-get update && \
    apt-get install -y \
    vlc \
    pulseaudio-utils \
    bluez \
    bluetooth \
    netcat \
    curl \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the script and playlist into the container
COPY radio_script.sh /app/radio_script.sh
COPY playlist.m3u /app/playlist.m3u

# Ensure the script has executable permissions
RUN chmod +x /app/radio_script.sh

# Set environment variables for Bluetooth MAC addresses (they will be passed via .env)
ENV BT_MAC1=""
ENV BT_MAC2=""

# Set the VLC remote control host
ENV VLC_HOST=localhost

# Expose VLC's RC port
EXPOSE 9999

# Set default entrypoint to run the script
ENTRYPOINT ["/bin/bash", "/app/radio_script.sh"]
