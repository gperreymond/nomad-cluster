#!/bin/bash

rm *.pem

set -e

# -----------------------
# PREPARE
# -----------------------

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -region) region="$2"; shift ;;
        -datacenter) datacenter="$2"; shift ;;
        *) echo "[ERROR] param is not authorized"; exit 1;;
    esac
    shift
done

if [[ -z "$region" ]]; then
    echo "[ERROR] region is mandatory"
    exit 1
fi

if [[ -z "$datacenter" ]]; then
    echo "[ERROR] datacenter is mandatory"
    exit 1
fi

# -----------------------
# RESUME
# -----------------------

echo ""
echo "================================================================="
echo "[INFO] region............................... '${region}'"
echo "[INFO] datacenter........................... '${datacenter}'"
echo "================================================================="
echo ""

# -----------------------
# EXECUTE COMMAND
# -----------------------

nomad tls ca create
nomad tls cert create -server -region $region
nomad tls cert create -client -region $region
nomad tls cert create -cli -region $region

# -----------------------
# CREATE ANSIBLE SECRET
# -----------------------

dirpath_certs="secrets/nomad/${region}/${datacenter}/certs"

rm -rf $dirpath_certs
mkdir -p $dirpath_certs

echo ""

for file in *.pem; do
    echo "[INFO] encryp file: $file"
    ansible-vault encrypt "$file"
    mv $file $dirpath_certs
done

# -----------------------
# END
# -----------------------

echo ""

