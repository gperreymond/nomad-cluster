#!/bin/bash

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

gossip_encription_key=$(nomad operator gossip keyring generate)

# -----------------------
# CREATE ANSIBLE SECRET
# -----------------------

dirpath_gossip="secrets/nomad/${region}/${datacenter}"

echo "[INFO] encryp file: gossip.yaml"
ansible-vault encrypt_string "$gossip_encription_key" --name "nomad_gossip_encription_key" > $dirpath_gossip/gossip.yaml

# -----------------------
# END
# -----------------------

echo ""

