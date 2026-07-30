# k8s Node Power (cordon/drain/shutdown + wake companion) Design

**Date:** 2026-07-29
**Status:** Approved

## Summary

Two bash functions added to `bash/bash_functions` for safely powering down and
later restoring `megadoughnuts`, a worker node in the `Trowbridge-k0s1` k0s
cluster, so it can be shut down or suspended when not in use without leaving
the cluster in a bad state. Companion to the existing `wol` utility, which
handles waking the machine back up over the network.

## Scope

Hardcoded to the one machine described:

- Node name (kubectl): `megadoughnuts`
- SSH host: `megadoughnuts.local`
- kubectl context: `Trowbridge-k0s1`

No config file, no multi-machine picker (unlike `wol.sh`) — this is
single-purpose for this box. Follows the existing `bash_functions` style:
`unset -f`/`function`/`export -f`, color vars from `pretty_tasks.sh`
(already sourced at the top of the file).

## `k8s_node_down`

1. `kubectl --context Trowbridge-k0s1 cordon megadoughnuts`
2. `kubectl --context Trowbridge-k0s1 drain megadoughnuts --ignore-daemonsets --delete-emptydir-data --force`
   - Aggressive flags so drain doesn't hang on daemonset pods or emptyDir
     volumes — acceptable for this worker node.
   - If drain fails (non-zero exit), stop and print the error. Do not touch
     the machine.
3. On successful drain, prompt: `Shutdown or suspend? [shutdown/suspend]`
4. SSH to `megadoughnuts.local` as `$USER` and run:
   - `shutdown` → `sudo shutdown -h now`
   - `suspend` → `sudo systemctl suspend`

## `k8s_node_up`

Run after the node has been woken back up (e.g. via `wol`):

1. `kubectl --context Trowbridge-k0s1 wait --for=condition=Ready node/megadoughnuts --timeout=60s`
   — avoids uncordoning a node that isn't actually back yet.
2. `kubectl --context Trowbridge-k0s1 uncordon megadoughnuts`

## Error Handling

- `k8s_node_down`: drain failure aborts before any SSH/shutdown step.
- `k8s_node_up`: `kubectl wait` timeout aborts before uncordon, with an error
  message telling the user the node never reported Ready.
- Both rely on `kubectl`'s own exit codes; no additional retry logic.

## Testing

- Manually run `k8s_node_down`, confirm node shows `SchedulingDisabled` via
  `kubectl --context Trowbridge-k0s1 get nodes`, confirm pods evicted,
  confirm machine actually shuts down/suspends.
- Wake the machine via `wol`, run `k8s_node_up`, confirm node returns to
  `Ready`/schedulable.
