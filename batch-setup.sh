#!/bin/bash

set -e

START_FROM=${1:-0}
AMOUNT=$2
AZP_TOKEN=$3
POOL=$4
RUN_ONCE_MODE=$5
DOCKER_NETWORK_MTU=$6
AGENT_VERSION=$7
ARCH=$8
AZURE_PROJECT=$9

if [ -z "$AMOUNT" ]; then
  echo "Please provide the number of agents to setup as the first param"
  exit 1
fi

if [ -z "$AZP_TOKEN" ]; then
  echo "Please provide the azp token as the second param"
  exit 1
fi

echo "Setting up $AMOUNT agents starting with $START_FROM"
for ((i = $START_FROM ; i < ($AMOUNT+$START_FROM) ; i++)); do
  ./agent-setup.sh agent$i $AZP_TOKEN $POOL $RUN_ONCE_MODE $DOCKER_NETWORK_MTU $AGENT_VERSION $ARCH $AZURE_PROJECT
done
