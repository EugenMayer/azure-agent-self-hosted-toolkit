#!/bin/bash

# users ./run.sh --once but ensures after each job, we cleanup the workdir and start the agent again
# so it fact the agent runs 'forever'

AGENT_USER=$1
CLEAN_WORKDIR=${2:-1} # use 0 to disable workdir deletion
AGENT_INSTALL_DIR=${3:-"/home/$AGENT_USER/agent"}
AGENT_WORK_DIR=${4:-"$AGENT_INSTALL_DIR/_work"}

echo "-------- CONFIG -------"
echo "AGENT USER: $AGENT_USER"
echo "INSTALL DIR: $AGENT_INSTALL_DIR"
echo "WORKDIR: $AGENT_WORK_DIR"
echo "CLEAN WORKDIR: $CLEAN_WORKDIR"
echo "-----------------------"
if [ -z "$AGENT_USER" ]; then
  echo "Please provide the agent user name the first parameter param"
  exit 1
fi

AGENT_EXIT_CODE=0
run_agent_for_one_job () {
  local RUN_AS_AGENT_USER=$1
  local INSTALL_DIR=$2
  gosu $RUN_AS_AGENT_USER bash -c "cd $INSTALL_DIR && ./run.sh --once"
  AGENT_EXIT_CODE=$?
}

stop_agent() {
    echo "Stopping agent for good"
    su -c "pkill -u $(id -u $AGENT_USER) Agent.Listener" $AGENT_USER
    exit 0
}

trap "stop_agent" HUP SIGINT INT TERM SIGKILL

while [ true ]
do
  echo "Starting agent $(date)"
  run_agent_for_one_job $AGENT_USER $AGENT_INSTALL_DIR
  if [ $AGENT_EXIT_CODE -gt 0 ]; then
    # 143 would be TERM, 137 would be SIGKILL
    exit $AGENT_EXIT_CODE
  fi
  if [ $CLEAN_WORKDIR -gt 0 ]; then
    echo "Cleaning workdir: $AGENT_WORK_DIR"
    rm -fr $AGENT_WORK_DIR
  fi
  # just continue to restart the agent again, exit code 0 means '--once was ending because a job finished'
  # the exit code will be 0 no matter if the job was successful or not - this is what we want.
done
