#!/bin/bash

# Variables (Edit these variables with your details)
INTERFACE="eth0"
NEW_IP="192.168.1.100/24"
NEW_GATEWAY="192.168.1.1"
NEW_DNS1="8.8.8.8"
NEW_DNS2="8.8.4.4"
CONNECTION_NAME="your-connection-name"

# Find the connection UUID
CONNECTION_UUID=$(nmcli -t -f UUID,DEVICE connection show | grep ${INTERFACE} | cut -d: -f1)

if [ -z "$CONNECTION_UUID" ]; then
    echo "No connection found for interface ${INTERFACE}. Exiting."
    exit 1
fi

# Backup the existing connection configuration
CONFIG_FILE="/etc/NetworkManager/system-connections/${CONNECTION_NAME}.nmconnection"
BACKUP_FILE="/etc/NetworkManager/system-connections/${CONNECTION_NAME}.nmconnection.bak"

if [ -f "$CONFIG_FILE" ]; then
    echo "Backing up the existing network configuration..."
    sudo cp "$CONFIG_FILE" "$BACKUP_FILE"
else
    echo "Network configuration file for ${CONNECTION_NAME} does not exist. Exiting."
    exit 1
fi

# Update the IP address, gateway, and DNS
echo "Updating the network configuration..."
sudo nmcli connection modify ${CONNECTION_UUID} ipv4.addresses ${NEW_IP}
sudo nmcli connection modify ${CONNECTION_UUID} ipv4.gateway ${NEW_GATEWAY}
sudo nmcli connection modify ${CONNECTION_UUID} ipv4.dns "${NEW_DNS1} ${NEW_DNS2}"
sudo nmcli connection modify ${CONNECTION_UUID} ipv4.method manual

# Restart the network connection
echo "Restarting the network connection..."
sudo nmcli connection down ${CONNECTION_UUID}
sudo nmcli connection up ${CONNECTION_UUID}

echo "IP address changed successfully."
