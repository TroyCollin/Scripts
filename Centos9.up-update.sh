#!/bin/bash

sleep 2
chvt 2

# Next Dimension ASCII art.
echo "Next Dimension Inc"	

echo "  _____         _      ____  _                   _            _____"
echo " |   | |___ _ _| |_   |    \|_|_____ ___ ___ ___|_|___ ___   |     |___ ___"
echo " | | | | -_|_'_|  _|  |  |  | |     | -_|   |_ -| | . |   |  |-   -|   |  _|"
echo " |_|___|___|_,_|_|    |____/|_|_|_|_|___|_|_|___|_|___|_|_|  |_____|_|_|___|"
echo                                                                             
echo " by Troy Collin"
echo
echo


while :
do
echo "Main Menu:"
echo -e "\t(a) Change IP and Hostname"
echo -e "\t(b) Disable this Startup Script"
echo -e "\t(c) Reboot system"
echo -e "\t(d) Exit"
echo -n "Please enter your choice:"
read choice
case $choice in
"a"|"A")
# Ask for input on network configuration
read -p "Enter the static IP of the server in CIDR notation: " staticip
read -p "Enter the IP of your gateway: " gatewayip
read -p "Enter the IP of preferred nameserver: " nameserversip1
read -p "Enter the IP of secondary nameserver: " nameserversip2

# Variables
NEW_IP="$staticip"
NEW_GATEWAY="$gatewayip"
NEW_DNS1="$nameserversip1"
NEW_DNS2="$nameserversip2"

# Detect the active network interface
INTERFACE=$(nmcli -t -f DEVICE,STATE d | grep ':connected' | cut -d: -f1)

if [ -z "$INTERFACE" ]; then
    echo "No active network interface found. Exiting."
    exit 1
fi

# Find the connection UUID
CONNECTION_UUID=$(nmcli -t -f UUID,DEVICE connection show | grep ${INTERFACE} | cut -d: -f1)

if [ -z "$CONNECTION_UUID" ]; then
    echo "No connection found for interface ${INTERFACE}. Exiting."
    exit 1
fi

# Get the connection name
CONNECTION_NAME=$(nmcli -t -f NAME,UUID connection show | grep ${CONNECTION_UUID} | cut -d: -f1)

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

# Restart the network connection;;


"b"|"B")
read -p "Disable IP change for next boot? (y or n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then

        systemctl disable auvik.build.service

fi


read -r -p "Are you sure you want to Reboot now? [Y/n]" response
response=${response,,} # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
   /sbin/reboot
fi
;;
"c"|"C")
clear
echo Put actions here...
echo
seconds=10
(
for i in $(seq $seconds -1 1); do
    echo "$i seconds to shutdown...";
    sleep 1;
done;
echo "Shutdown now!") &
/sbin/reboot
;;
"d"|"D")
exit
;;

echo "Restarting the network connection..."
sudo nmcli connection down ${CONNECTION_UUID}
sudo nmcli connection up ${CONNECTION_UUID}

echo "IP address changed successfully."


echo "==========================="
echo
read -p "Enter the new hostname of this server: " hostname1
echo $hostname1 | sudo tee /etc/hostname
sudo hostnamectl set-hostname $hostname1

