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

inventory_file="ansible/inventories/$datacenter/inventory.ini"
first_retry_join=$(awk -F '[][]' '/nomad_server_retry_join/{print $2}' $inventory_file | awk -F ', ' '{print $1}' | sed 's/"//g')
echo "[INFO] get first retry join is $first_retry_join"

# nomad acl bootstrap -address=https://$first_retry_join:4646 -region=$region -tls-skip-verify -json > bootstap.json
# cat bootstap.json | jq

# ansible-vault encrypt "bootstap.json"
echo "[INFO] move bootstap.json"
mv bootstap.json secrets/nomad/${region}/${datacenter}/bootstap.json

# -----------------------
# END
# -----------------------

echo ""