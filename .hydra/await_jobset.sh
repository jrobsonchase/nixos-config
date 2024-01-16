#!/usr/bin/env nix
#! nix shell nixpkgs#curl nixpkgs#jq

set -o pipefail

URL=$1
PROJECT=$2
JOBSET=$3
REV=$4

function find_eval() {
	curl -s -H "Accept: application/json" $URL/jobset/$PROJECT/$JOBSET/evals | \
		jq -er "[.evals[] | select(.flake | test(\"$REV\"))] | sort_by(-.timestamp) | .[0]"
}

echo Looking for eval...

while ! EVAL=$(find_eval); do
	sleep 5
done

echo Waiting on builds...

BUILDS=$(echo $EVAL | jq -r .builds[])

for b in $BUILDS; do
	DATA=$(curl -s -H "Accept: application/json" $URL/build/$b)
	if [ $(echo "${DATA}" | jq .finished) -ne 1 ]; then
		sleep 5
		continue
	fi
	if [ $(echo "${DATA}" | jq .buildstatus) -ne 0 ]; then
		echo Nonzero build status: $URL/build/$b
		exit 1
	fi
done

echo Done!
