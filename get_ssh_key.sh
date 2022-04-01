#!/bin/bash
data=$(curl GET -s "Content-Type: application/json" -H "Authorization: Bearer $1" "https://api.digitalocean.com/v2/account/keys" | jq -c '.ssh_keys[] | select(.name == "REBRAIN.SSH.PUB.KEY") | .id|tostring')
echo '{"id":'$data"}"