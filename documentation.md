## Prerequisites

Before using this container, ensure that your Raspberry Pi meets the following prerequisites:

   * Raspberry Pi running Raspberry Pi OS (either 32-bit or 64-bit)
   * Docker installed on your Raspberry Pi. You can install Docker by following the official Docker installation guide for Raspberry Pi.
   * Bluetooth devices configured and working on your Raspberry Pi.

## Running the Docker Container

There are two ways to run the container:

#### Option 1: Using docker run

Use the following command to run the container with the required environment variables and devices:

    docker run --env-file .env --device /dev/rfkill --device /dev/bluetooth --privileged --network host jayabs/pi-bt-radio play

Explanation of the flags:

*  --env-file .env: Loads environment variables from the .env file. (See the Environment Variables section for more details.)
*   --device /dev/rfkill: Allows access to the RFKill device for managing Bluetooth.
*   --device /dev/bluetooth: Provides Bluetooth access to the container.
*   --privileged: Grants additional privileges for accessing Bluetooth devices.
*   --network host: Uses the host's network to ensure the container has network access for VLC to stream audio.

#### Option 2: Using docker compose

Alternatively, you can use Docker Compose to manage the container. First, create a docker-compose.yml file in your project directory.

    ```yaml

    services:
    radio-player:
        image: jayabs/pi-bt-radio
        env_file:
        - .env
        devices:
        - "/dev/rfkill:/dev/rfkill"
        - "/dev/bluetooth:/dev/bluetooth"
        privileged: true
        network_mode: host
        command: "play"

## Environment Variables

You need to define your environment variables in a .env file to configure Bluetooth devices and other settings. Below is an example .env file:


    JABRA: The Bluetooth MAC address of Jabra speaker.
    BOSE: The Bluetooth MAC address of Bose speaker.
    DISCORD_URL: Optional. If you want the script to send notifications when playing or stopping the radio, provide a Discord webhook URL.

Ensure the .env file is in the same directory as your docker-compose.yml file or specify its path when running docker run.

## Commands

You can use the following commands to interact with the container:
### play

Starts playing the radio stream. This command will attempt to connect to a Bluetooth speaker and start playing the playlist from playlist.m3u.

    docker run --env-file .env jayabs/pi-bt-radio play

### next

Skips to the next radio station in the playlist.

    docker run --env-file .env jayabs/pi-bt-radio next

### stop

Stops the radio stream and disconnects from the Bluetooth speaker.

    docker run --env-file .env jayabs/pi-bt-radio stop


## Troubleshooting

If you encounter issues with Bluetooth connectivity, ensure the following:

* Your Raspberry Pi has Bluetooth enabled and is capable of connecting to external Bluetooth devices.
* The .env file contains correct Bluetooth MAC addresses.
* The script is able to access the Bluetooth devices. If needed, try running the container with elevated privileges (--privileged).
* If VLC does not start or there's an issue with streaming, ensure the network access and VLC's remote control interface are working correctly on your Raspberry Pi.

