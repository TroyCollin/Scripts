#!/bin/bash

# Function to check if a certificate is due for renewal
check_renewal() {
    # Change to your actual certificate path
    cert_path="/etc/letsencrypt/live/example.com/fullchain.pem"

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
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "Certificate renewed successfully."
    else
        echo "Failed to renew certificate. Exit code: $exit_code"
        exit $exit_code
    fi
}

# Main script
if check_renewal; then
    renew_certificate
else
    echo "Certificate renewal is not yet needed."
fi
