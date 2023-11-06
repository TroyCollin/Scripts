#!/bin/bash

sleep 2

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

#touch todyl.install.sh && chmod +x todyl.install.sh

## A.1.0 CA directory
##
#
DIR="/root/ca"
if [ -d "$DIR" ]; then
  echo -e "\e[1;32mDirectory already there done.. skipping\e[0m"
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo -e "\e[1;32mError: ${DIR} not found. Creating it now...\e[0m"
  mkdir /root/ca
fi


## A.1.1 download certs
##
#
FILE1="/root/ca/fleet.cer"
if [ -f "$FILE1" ]; then
  echo -e "\e[1;32mCerts already downloaded.. skipping\e[0m"
else
  echo -e "\e[1;32mError: ${FILE1} not found. Downloading it now...\e[0m"
  curl https://cacerts.digicert.com/DigiCertTLSRSASHA2562020CA1-1.crt.pem > /root/ca/fleet.cer
  curl https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem >> /root/ca/fleet.cer
fi


## B.1.0 downloading elastic-agent
##
#
FILE2="/opt/elastic-agent-8.4.3-linux-x86_64.tar.gz"
if [ -f "$FILE2" ]; then
  echo -e "\e[1;32mFile already downloaded.. skipping\e[0m"
else
  echo -e "\e[1;32mError: ${FILE2} not found. Downloading it now...\e[0m"
  curl -L -o /opt/elastic-agent-8.4.3-linux-x86_64.tar.gz https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.4.3-linux-x86_64.tar.gz
fi


## B.1.1 extracting elastic-agent
##
#
DIR1="/opt/elastic-agent-8.4.3-linux-x86_64"
if [ -d "$DIR1" ]; then
  echo -e "\e[1;32mElastic agent already extracted to /opt/elastic-agent-8.4.3-linux-x86_64/.. skipping\e[0m"
else
  echo -e "\e[1;32mError: ${DIR1} not found. extracting TAR/ZIP now...\e[0m"
tar xzvf /opt/elastic-agent-8.4.3-linux-x86_64.tar.gz -C /opt/
fi


## C.1.0 installing elastic-agent
##
#
if ! which elastic-agent > /dev/null; then
  echo -e "\e[1;32mElastic Agent not installed...\e[0m"
read -p "Do you want to proceed? (yes/no) " yn

case $yn in
	yes ) echo ok, we will proceed;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac

echo -e "\e[1;32mElastic is being installed...\e[0m"
/opt/elastic-agent-8.4.3-linux-x86_64/elastic-agent install --url=https://fleet-wr.todyl.com:8220 --enrollment-token=ZUJsYUhvVUIzR195Sk1XV3Y4T3k6blJqa2pOMVhTSC13RlgwRUEyMU53Zw== -v -f --certificate-authorities="/root/ca/fleet.cer" --fleet-server-es-ca="/root/ca/fleet.cer"
else
 echo -e "\e[1;32mElastic Agent is already installed.. skipping\e[0m"
 exit
fi

exit
