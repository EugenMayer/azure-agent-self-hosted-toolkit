#!/bin/bash

set -e

START_FROM=${1:-0}
AMOUNT=$2
AZP_TOKEN=$3
POOL=${4:-Default}

if [ -z "$AMOUNT" ]; then
  echo "Please provide the number of agents to setup as the first param"
  exit 1
fi

if [ -z "$AZP_TOKEN" ]; then
  echo "Please provide the azp token as the second param"
  exit 1
fi

if [ -z "$POOL" ]; then
  echo "Please provide the pool token as the 3rd param"
  exit 1
fi

echo "Uninstalling $AMOUNT agents starting with $START_FROM"
for ((i = $START_FROM ; i < ($AMOUNT+$START_FROM) ; i++)); do
  ./agent-uninstall.sh agent$i $AZP_TOKEN $POOL
done
