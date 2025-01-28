#!/bin/bash

# Author : JB

# Read Bluetooth MAC addresses from environment variables
JABRA="$BT_MAC1"
BOSE="$BT_MAC2"

VLC_HOST=localhost
VLC_RC_PORT=9999

MAX_ATTEMPTS=25
DELAY=10

# Check if .env variables are set (error out if not)
if [ -z "$BT_MAC1" ] || [ -z "$BT_MAC2" ]; then
    echo "Error: Bluetooth MAC addresses are not set. Please provide them in the .env file."
    exit 1
fi

# Bluetooth and PulseAudio setup for RPi

# Ensure Bluetooth is up and running
check_and_unblock_bluetooth() {
    # Check if Bluetooth is soft blocked
    if rfkill list bluetooth | grep -q "Soft blocked: yes"; then
        echo "Bluetooth is currently soft blocked. Attempting to unblock..."
        if ! rfkill unblock bluetooth; then
            echo "Failed to unblock Bluetooth."
            exit 1
        fi
        echo "Bluetooth successfully unblocked."
    fi
    echo "Bluetooth is active."
}

# Function to connect to Bluetooth speaker
connect_bt() {
    local BT_MAC=$1
    # Check if already connected
    if bluetoothctl info $BT_MAC | grep -q "Connected: yes"; then
        echo "$BT_MAC is already connected."
        return 0
    fi

    echo "Attempting to connect to Bluetooth speaker at $BT_MAC..."
    bluetoothctl << EOF
power on
agent on
default-agent
connect $BT_MAC
EOF
}

# Function to play the radio
play_radio() {
    # Set the Bluetooth speaker as the default audio sink
    SINK_NAME=$(echo $1 | sed 's/:/_/g')
    pactl set-default-sink bluez_sink.$SINK_NAME.a2dp_sink

    if ! pgrep -x vlc > /dev/null; then
        echo "Starting VLC to play the stream..."
        vlc --intf rc --rc-host ${VLC_HOST}:${VLC_RC_PORT} /app/playlist.m3u &
        sleep 5
    else
        echo "VLC is already running."
    fi
}

# Main script execution starts here

# Check if script is passed 'play', 'next', or 'stop'
INPUT=$1
if [ "$INPUT" != "play" ] && [ "$INPUT" != "next" ] && [ "$INPUT" != "stop" ]; then
    echo "Invalid input. Usage: $0 {play|next|stop}"
    exit 1
fi

case $INPUT in
    play)
        check_and_unblock_bluetooth
        connect_bt "$JABRA" || connect_bt "$BOSE"
        play_radio "$JABRA" || play_radio "$BOSE"
        ;;
    next)
        # Logic for next track
        ;;
    stop)
        pkill -f vlc
        echo "Stopped radio."
        ;;
    *)
        echo "Invalid command."
        ;;
esac
