#!/bin/bash

# Author : JB

# Read Bluetooth MAC addresses from environment variables
SPEAKER1="$BT_MAC1"
SPEAKER2="$BT_MAC2"

VLC_HOST=localhost
VLC_RC_PORT=9999

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
    local bt_mac=$1
    # Check if already connected
    if bluetoothctl info "$bt_mac" | grep -q "Connected: yes"; then
        echo "$bt_mac is already connected."
        return 0
    fi

    echo "Attempting to connect to Bluetooth speaker at $bt_mac..."
    bluetoothctl << EOF
power on
agent on
default-agent
connect $bt_mac
EOF
}

# Function to play the radio
play_radio() {
    local bt_mac=$1
    # Set the Bluetooth speaker as the default audio sink
    local sink_name
    sink_name=${bt_mac//:/_}
    pactl set-default-sink "bluez_sink.$sink_name.a2dp_sink"

    if ! pgrep -x vlc > /dev/null; then
        echo "Starting VLC to play the stream..."
        vlc --intf rc --rc-host "${VLC_HOST}:${VLC_RC_PORT}" /app/playlist.m3u &
        sleep 5
    else
        echo "VLC is already running."
    fi
}

# Function to stop the radio
stop_radio() {
    pkill -f vlc
    echo "Stopped radio."
}

# Main script execution starts here

# Check if script is passed 'play', 'next', or 'stop'
input=$1
if [ "$input" != "play" ] && [ "$input" != "next" ] && [ "$input" != "stop" ]; then
    echo "Invalid input. Usage: $0 {play|next|stop}"
    exit 1
fi

case $input in
    play)
        check_and_unblock_bluetooth
        connect_bt "$SPEAKER1" || connect_bt "$SPEAKER2"
        play_radio "$SPEAKER1" || play_radio "$SPEAKER2"
        ;;
    next)
        # Logic for next track
        ;;
    stop)
        stop_radio
        ;;
    *)
        echo "Invalid command."
        exit 1
        ;;
esac
