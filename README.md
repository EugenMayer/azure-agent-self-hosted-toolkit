# WAT

Helps running azure (multiple) azure self-hosted agents on one machine (scoped).

Features

- One-line command to set up X agent (including user per agent, systemd service). Downloads, setups and keeps them running.
- supports running docker based jobs
- Uses `--once` mode to run the agents with automatic `workdir` cleanup and `restart` after job-end
- offers batch-uninstalling agents
- Helps setting up MTU vars

This is not
- an orchestrator for k8s
- this does not use docker-in-docker (though it uses docker)

# Details

### run-once mode

The run-once mode is based on Microsoft's `./run.sh --once` which ensures that an agents only runs 1 job and then stops.
This is used to

 - cleanup the workdir in a safe manner after each job
 - ensures each job on an agent runs in a clean workdir
 - starts the agent right after cleanup up (few seconds) to be available for the next job
 - Use the original microsoft tools, binaries and all the bits. Be agent-upgrade ready.
 
This fixes issues like
 - https://github.com/Microsoft/azure-pipelines-agent/issues/1895, https://github.com/microsoft/azure-pipelines-agent/issues/708 an https://github.com/microsoft/azure-pipelines-yaml/issues/453
 - Security: A non-related following up job has access to data of a prior job (leak)
 - Jobs artifact downloads getting multiplied due to left-overs of prior jobs (pollution)

## Setup

Requirements

 - curl

### One agents
One agent called `agent0` for the pool `Default` enabling the `run-once` mode

```
./agent-setup agent0 <PAT> Default 1
```

You can also add an additional agent, with an MTU (for the docker network) of `1400`

```
./agent-setup agent1 <PAT> Default 1 1400
```

### Many agents

X agents, creates agent0....agent14 in the pool Default with an MTU of `1400`

```
./batch-setup.sh 0 15 <PAT> Default 1 1400
```

## Uninstall

The below commands does uninstall 
- uninstall the systemd service
- de-register the agent from the pool
- remove the agent install dir
- remove the agent user home folder
- remove the agent user

So there should be nothing left after running this for one agent.

### One agents

```
./agent-uninstall agent0 <PAT>
```

### Many agents

Uninstalls agent 0..14 from the Default pool

```
./batch-uninstall.sh 0 15 <PAT> Default 
```

### Troubleshooting

#### 100s delay before starting a job

Bug in the agent, see https://github.com/microsoft/azure-pipelines-agent/issues/4215 workaround by blocking the network request

```bash
sudo ip route add blackhole 169.254.169.254
```

This sends the stalling requests into a direct-drop gw and speeds up the start by 100s.



## Contributions

Anytime, just open PRs. Happy to extend whatever we have here.
