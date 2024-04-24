#!/bin/bash

clear
# Next Dimension ASCII art.
echo "Next Dimension Inc"

echo "    _   _   _   _     _   _   _   _   _   _   _   _   _     _   _   _  "
echo "   / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ / \ / \ / \   / \ / \ / \ "
echo "  ( N | e | x | t ) ( D | i | m | e | n | s | i | o | n ) ( I | n | c )"
echo "   \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ "
echo
echo " script by Troy Collin"
echo
echo " This script will renew Let's Encrypt and restart Nginx"
echo ""
echo ""
echo "v.1.0"

#### start variables ###
log_file="./certexpiry.txt"

### variables end   ###


helpFunction()
{
   echo ""
   echo "Usage: $0 -U url "
   echo -e "\t-u Enter url like https://www.example.com"
   exit 1 # Exit script after printing help
}

while getopts "U:" opt
do
   case "$opt" in
      U ) url="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$url" ]
then
   echo "opps you forgot the url";
   helpFunction
fi

# Begin script if the paramters are correct

X=$url

tmp=${X#*//};host=${tmp%%/*};[[ ${X#*://} == *":"* ]] && host=${host%:*}

echo "$host"

ip=`dig +short $host`

if [ -n "$ip" ]; then
DAYS=30;
echo "checking if $url expires in less than $DAYS days";
expirationdate=$(date -d "$(: | openssl s_client -connect $url:443 -servername $host 2>/dev/null \
                              | openssl x509 -text \
                              | grep 'Not After' \
                              |awk '{print $4,$5,$7}')" '+%s');
in30days=$(($(date +%s) + (86400*$DAYS)));
if [ $in30days -gt $expirationdate ]; then
    echo "Alert - Certificate for $host expires in less than $DAYS days, on $(date -d @$expirationdate '+%Y-%m-%d')"
    echo $host","$(date -d @$expirationdate '+%Y-%m-%d') >> $log_file
else
    echo "OK - Certificate expires on $(date -d @$expirationdate '+%Y-%m-%d')"
    echo $host","$(date -d @$expirationdate '+%Y-%m-%d') >> $log_file
fi;

else
    echo Sorry Could not resolve domain name.
fi


