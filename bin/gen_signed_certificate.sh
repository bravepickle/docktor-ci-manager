#!/usr/bin/env bash
# Generate self-signed Open SSL certificate

set -e

# set vars
if [ "$#" -gt "0" ]; then
    OUTPUT_DIR=$1
    echo why here?
else
    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    OUTPUT_DIR="${CURRENT_DIR}/../data/certs"
fi

SSL_COUNTRY=UA
SSL_STATE="Region, Kiev"
SSL_LOCATION=Kiev
SSL_ORGANIZATION=Home
SSL_ORG_UNIT=N/A
SSL_CN=docktor-ci-manager # https://ssl.example.com

# gen keys
echo -n "Certificates are saved to $OUTPUT_DIR" && \
    mkdir -p $OUTPUT_DIR && \
    openssl req \
      -newkey rsa:4096 -nodes -sha256 -keyout $OUTPUT_DIR/domain.key \
      -x509 -days 365 -out $OUTPUT_DIR/domain.crt \
      -subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCATION/O=$SSL_ORGANIZATION/OU=$SSL_ORG_UNIT/CN=$SSL_CN"

