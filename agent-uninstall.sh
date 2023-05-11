#!/bin/bash

set -e

AGENT_USER=$1
PAT=$2
POOL=$3
if [ -z "$AGENT_USER" ]; then
  echo "Please provide the agent name the first parameter param"
  exit 1
fi

if [ -z "$PAT" ]; then
  echo "Please provide the PAT as the 2nd parameter param (so the agent can uninstall itself)"
  exit 1
fi

if [ -z "$POOL" ]; then
  echo "Please provide the POOL as the 3rd parameter"
  exit 1
fi


# Uninstall systemd service needs to run under root and from the agent folder
cd /home/$AGENT_USER/agent
echo "Stopping the agent $AGENT_USER"
systemctl stop vsts.agent.kontextwork.$POOL.$AGENT_USER
./svc.sh uninstall
# FIXME we could also run but we would need to provide the pat ..
su -c "cd /home/$AGENT_USER/agent && ./config.sh remove --auth pat --token $PAT" $AGENT_USER
cd /tmp
rm -fr /home/$AGENT_USER

wait_for=10
echo "waiting for $wait_for seconds before removing the user - ensures all processes have been stopped"
sleep $wait_for
# according to https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/linux-agent?view=azure-devops#remove-and-reconfigure-an-agent we could also use
userdel $AGENT_USER
