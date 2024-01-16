#!/usr/bin/env nix
#! nix shell nixpkgs#curl nixpkgs#jq

set -o pipefail

URL=$1
PROJECT=$2
JOBSET=$3

curl --request PUT $URL/api/push?jobsets=$PROJECT:$JOBSET | jq