#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <IP_ADDRESS> <USERNAME>"
    echo "Example: $0 192.168.1.236 dalai"
    exit 1
fi

TARGET_IP="$1"
TARGET_USER="$2"

sudo tpm2_load -C primaryecc.ctx -u ecc.pub -r ecc.priv -c ecc.ctx
sudo tpm2_sign -c ecc.ctx -g sha256 -s ecdsa -f plain -o signature.sig msg
ls
sudo tpm2_readpublic -c ecc.ctx -f pem -o public.pem
sudo scp msg signature.sig public.pem "${TARGET_USER}@${TARGET_IP}:~/Desktop/Task4"