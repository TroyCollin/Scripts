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
log_file="/var/log/certexpiry.txt"

### variables end   ###


# Function to check if a certificate is due for renewal
check_renewal() {
    # Change to your actual certificate path
    cert_path="/etc/letsencrypt/live/systech.nattech.net/fullchain.pem"

    # Check if certificate exists
    if [ -f "$cert_path" ]; then
        # Get certificate expiration date
        expire_date=$(date -d "$(openssl x509 -enddate -noout -in "$cert_path" | cut -d= -f 2)" +%s)
        current_date=$(date +%s)

        # Calculate the number of seconds in 2 weeks
        two_weeks=$(( 14 * 24 * 60 * 60 ))

        # Calculate the date 2 weeks before expiration
        renewal_date=$(( expire_date - two_weeks ))

        # Compare the current date with the renewal date
        if [ "$current_date" -ge "$renewal_date" ]; then
            return 0  # Renewal is needed
        else
            return 1  # Renewal is not needed yet
        fi
    else
        echo "Certificate not found at $cert_path"
        exit 1
    fi
}

# Function to renew the certificate
renew_certificate() {
   echo "Renewing Let's Encrypt certificate..."
    
    certbot renew
    STATUS="$(systemctl is-active nginx.service)"
if [ "${STATUS}" = "active" ]; then
    echo "restarting Nginx"
    systemctl restart nginx 
else 
    echo " Service not running.... so exiting "  
    exit 1  
fi
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "Certificate renewed successfully." 
         echo $host",Cert renewed successfully "$(date -d '+%Y-%m-%d') >> $log_file
    else
        echo "Failed to renew certificate. Exit code: $exit_code"
        echo $host",Failed to renew Cert "$(date -d '+%Y-%m-%d') >> $log_file
        exit $exit_code
    fi
}

# Main script
if check_renewal; then
    renew_certificate
else
    echo "Certificate renewal is not yet needed."
    echo $(date -u) $host" Cert renewal not needed" >> $log_file
    
    
fi

