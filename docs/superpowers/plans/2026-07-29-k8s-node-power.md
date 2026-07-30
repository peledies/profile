# k8s Node Power (cordon/drain/shutdown + wake companion) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `k8s_node_down` and `k8s_node_up` bash functions to `bash/bash_functions` for safely powering down and later restoring the `megadoughnuts` worker node in the `Trowbridge-k0s1` k0s cluster.

**Architecture:** Two standalone shell functions appended to the existing `bash/bash_functions` file, following the file's established `unset -f`/`function`/`export -f` pattern and reusing the color vars already sourced from `assets/pretty_tasks.sh`. No new files, no config, no automated test suite — this file has no test harness; verification is manual, matching how every other function in it (e.g. `basicauth`, `wol`-adjacent helpers) was added and validated.

**Tech Stack:** bash, kubectl, ssh.

## Global Constraints

- Node name (kubectl): `megadoughnuts`
- SSH host: `megadoughnuts.local`
- kubectl context: `Trowbridge-k0s1`
- Drain flags: `--ignore-daemonsets --delete-emptydir-data --force` (per spec — aggressive, this is a disposable worker)
- Follow existing file style exactly: `unset -f <name>` then `function <name>(){ ... }` then `export -f <name>`, using `${cyan}`/`${green}`/`${red}`/`${default}` color vars (already in scope, sourced at top of `bash/bash_functions`)
- No emojis in output text (per user's global CLAUDE.md preference)

---

### Task 1: Add `k8s_node_down`

**Files:**
- Modify: `bash/bash_functions` (append after the `basicauth` function, ~line 505, before the trailing `fzg`/`fgb`/`fgd` block)

**Interfaces:**
- Produces: shell function `k8s_node_down` (no args), exported via `export -f k8s_node_down`

- [ ] **Step 1: Write the function**

Append this block to `bash/bash_functions` immediately after the existing `basicauth` function's `export -f basicauth` line:

```bash
unset -f k8s_node_down
function k8s_node_down(){
  local ctx="Trowbridge-k0s1"
  local node="megadoughnuts"
  local host="megadoughnuts.local"

  echo "${cyan}Cordoning ${node} (context: ${ctx})...${default}"
  if ! kubectl --context "$ctx" cordon "$node"; then
    echo "${red}Cordon failed, aborting.${default}" >&2
    return 1
  fi

  echo "${cyan}Draining ${node}...${default}"
  if ! kubectl --context "$ctx" drain "$node" \
      --ignore-daemonsets --delete-emptydir-data --force; then
    echo "${red}Drain failed, aborting. Node remains cordoned.${default}" >&2
    return 1
  fi

  echo "${green}Drain complete.${default}"

  local action=""
  read -r -p "${cyan}Shutdown or suspend? [shutdown/suspend]: ${default}" action </dev/tty

  case "$action" in
    shutdown)
      echo "${cyan}Shutting down ${host} via SSH...${default}"
      ssh "${USER}@${host}" "sudo shutdown -h now"
      ;;
    suspend)
      echo "${cyan}Suspending ${host} via SSH...${default}"
      ssh "${USER}@${host}" "sudo systemctl suspend"
      ;;
    *)
      echo "${red}Unrecognized option '${action}'. Node is drained but machine left running.${default}" >&2
      return 1
      ;;
  esac
}
export -f k8s_node_down
```

- [ ] **Step 2: Verify shell syntax**

Run: `bash -n bash/bash_functions`
Expected: no output, exit code 0

- [ ] **Step 3: Load and sanity-check the function**

Run: `bash -c 'source bash/bash_functions >/dev/null 2>&1; type k8s_node_down'`
Expected: output shows `k8s_node_down is a function` (confirms it parses and defines correctly without needing to actually invoke kubectl/ssh)

- [ ] **Step 4: Manual functional test (run by the user, not automated)**

From an interactive shell with `bash_functions` sourced:
1. Run `k8s_node_down`
2. Confirm `kubectl --context Trowbridge-k0s1 get nodes` shows `megadoughnuts` as `Ready,SchedulingDisabled`
3. Choose `shutdown` or `suspend` at the prompt and confirm the machine actually powers off/suspends

- [ ] **Step 5: Commit**

```bash
git add bash/bash_functions
git commit -m "feat(bash_functions): add k8s_node_down to cordon/drain/shutdown megadoughnuts"
```

---

### Task 2: Add `k8s_node_up`

**Files:**
- Modify: `bash/bash_functions` (append immediately after `k8s_node_down`'s `export -f k8s_node_down` line)

**Interfaces:**
- Consumes: none (independent of Task 1's function body, just placed after it in the file)
- Produces: shell function `k8s_node_up` (no args), exported via `export -f k8s_node_up`

- [ ] **Step 1: Write the function**

Append this block to `bash/bash_functions` directly after `export -f k8s_node_down`:

```bash
unset -f k8s_node_up
function k8s_node_up(){
  local ctx="Trowbridge-k0s1"
  local node="megadoughnuts"

  echo "${cyan}Waiting for ${node} to report Ready (context: ${ctx})...${default}"
  if ! kubectl --context "$ctx" wait --for=condition=Ready "node/${node}" --timeout=60s; then
    echo "${red}${node} did not report Ready within timeout. Not uncordoning.${default}" >&2
    return 1
  fi

  echo "${cyan}Uncordoning ${node}...${default}"
  if ! kubectl --context "$ctx" uncordon "$node"; then
    echo "${red}Uncordon failed.${default}" >&2
    return 1
  fi

  echo "${green}${node} is back in rotation.${default}"
}
export -f k8s_node_up
```

- [ ] **Step 2: Verify shell syntax**

Run: `bash -n bash/bash_functions`
Expected: no output, exit code 0

- [ ] **Step 3: Load and sanity-check the function**

Run: `bash -c 'source bash/bash_functions >/dev/null 2>&1; type k8s_node_up'`
Expected: output shows `k8s_node_up is a function`

- [ ] **Step 4: Manual functional test (run by the user, not automated)**

After waking `megadoughnuts` (e.g. via the existing `wol` utility):
1. Run `k8s_node_up`
2. Confirm `kubectl --context Trowbridge-k0s1 get nodes` shows `megadoughnuts` as `Ready` (no `SchedulingDisabled`)

- [ ] **Step 5: Commit**

```bash
git add bash/bash_functions
git commit -m "feat(bash_functions): add k8s_node_up to uncordon megadoughnuts after wake"
```
