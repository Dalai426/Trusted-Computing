#!/bin/bash
EXPECTED_PCR_VALUE=1111111111111111111111111111111111111111111111111111111111111111
UNEXPECTED_PCR_VALUE=2211111111111111111111111111111111111111111111111111111111111122

MATCH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --match)
            if [[ "$2" == "true" || "$2" == "false" ]]; then
                MATCH="$2"
                shift 2
            else
                echo "Error: --match requires 'true' or 'false'"
                echo "Usage: $0 [--match true|false]"
                exit 1
            fi
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--match true|false]"
            exit 1
            ;;
    esac
done

if [[ -z "$MATCH" ]]; then
    echo "Error: The --match option is required."
    echo "Usage: $0 --match true|false"
    exit 1
fi


ls /sys/class/tpm/
sudo tpm2_createprimary -C o -c primaryecc.ctx >/dev/null
sudo tpm2_pcrreset 16
sudo tpm2_pcrextend 16:sha256=$EXPECTED_PCR_VALUE >/dev/null
sudo tpm2_pcrread -o pcr.expected sha256:16 >/dev/null
sudo tpm2_createpolicy --policy-pcr -l sha256:16 --pcr pcr.expected -L pcr.policy >/dev/null

sudo tpm2_pcrreset 16 >/dev/null
sudo tpm2_create -G ecc -u ecc.pub -r ecc.priv -L pcr.policy -C primaryecc.ctx >/dev/null
sudo tpm2_load -C primaryecc.ctx -u ecc.pub -r ecc.priv -c ecc.ctx >/dev/null

printf "TPM exercise" > msg


if [[ "$MATCH" == "true" ]]; then
    # PCR value matches with authorization policy
    sudo tpm2_pcrextend 16:sha256=$EXPECTED_PCR_VALUE
    sudo tpm2_pcrread -o pcr.expected sha256:16
    sudo tpm2_startauthsession --policy -S session.ctx
    sudo tpm2_policypcr -S session.ctx -l sha256:16 -f pcr.expected
    sudo tpm2_sign -c ecc.ctx -g sha256 -s ecdsa -f plain -p session:session.ctx -o signature.sig msg
else
    # PCR value does not match with authorization policy
    sudo tpm2_pcrextend 16:sha256=$UNEXPECTED_PCR_VALUE
    sudo tpm2_pcrread -o pcr.unexpected sha256:16
    sudo tpm2_startauthsession --policy -S session.ctx
    sudo tpm2_policypcr -S session.ctx -l sha256:16 -f pcr.unexpected
    sudo tpm2_sign -c ecc.ctx -g sha256 -s ecdsa -f plain -p session:session.ctx -o signature.sig msg
fi

sudo tpm2_flushcontext session.ctx
sudo tpm2_pcrreset 16

