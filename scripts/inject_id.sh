#!/bin/bash

# IMDSv2 Token-basierter Abruf
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/instance-id)

# Injektion der ID
sed -i "s/\[INSTANCE_ID_PLACEHOLDER\]/$INSTANCE_ID/g" /var/www/html/index.html
