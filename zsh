#!/usr/bin/env zsh
# macOS / zsh compatible helper functions
# Save as ~/.zsh_functions and source from ~/.zshrc:
#   if [[ -f ~/.zsh_functions ]]; then source ~/.zsh_functions; fi



# Checkout a remote branch and track it locally
gcr() {
  if [[ -z "$1" ]]; then
    echo "Usage: gcr <remote/branch|branch>"
    return 1
  fi
  git checkout --track "$1"
}

# Checkout a branch; if missing create it and set upstream; if already on it, fetch/pull
gc() {
  if [[ -z "$1" ]]; then
    echo "Usage: gc <branch>"
    return 1
  fi

  # capture both stdout and stderr
  output=$(git checkout "$1" 2>&1)
  rc=$?

  # Branch doesn't exist locally -> create and set upstream to origin/<branch>
  if [[ $rc -ne 0 && "$output" == *"did not match any file(s) known to git"* ]]; then
    echo "Branch '$1' not found locally — creating and tracking origin/$1"
    git checkout -b "$1"
    git branch --set-upstream-to=origin/"$1" "$1" 2>/dev/null || true
    return 0
  fi

  # If already on branch, refresh
  if [[ "$output" == *"Already on"* || "$output" == *"already on"* ]]; then
    git fetch && git pull
    return 0
  fi

  return $rc
}

# Git status
gs() { git status; }

# Change to a repo folder under a configurable root.
# Set `DEV_REPO_ROOT` env var to your repos root (default: $HOME/dev/nu)
# - `gh` with no args: cd to the repo root
# - `gh <name>`: cd to "$DEV_REPO_ROOT/<name>"
gh() {
  base="${DEV_REPO_ROOT:-$HOME/dev/nu}"
  if [[ -z "$1" ]]; then
    if [[ -d "$base" ]]; then
      cd "$base" || return 1
    else
      echo "Directory not found: $base"
      return 1
    fi
  else
    target="$base/$1"
    if [[ -d "$target" ]]; then
      cd "$target" || return 1
    else
      echo "Directory not found: $target"
      return 1
    fi
  fi
}

# Git diff
gd() { git diff; }

# Create and checkout branch (create local branch then checkout)
gbn() {
  if [[ -z "$1" ]]; then
    echo "Usage: gbn <branch-name>"
    return 1
  fi
  git branch "$1"
  git checkout "$1"
}

# List branches
gb() { git branch; }

# Docker ps (optional args)
dps() {
  if [[ $# -eq 0 ]]; then
    docker ps
  else
    docker ps "$@"
  fi
}

# Docker images
di() { docker images; }

# Docker logs
dl() {
  if [[ -z "$1" ]]; then
    echo "Usage: dl <container-id|name>"
    return 1
  fi
  docker logs "$1"
}

# Docker container <subcommand> ...
dc() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: dc <container-subcommand> ...  (example: dc ls)"
    return 1
  fi
  docker container "$@"
}

# Docker attach
da() {
  if [[ -z "$1" ]]; then
    echo "Usage: da <container-id|name>"
    return 1
  fi
  docker attach "$1"
}

# Push to current branch (confirm with -y)
gpo() {
  if [[ "$1" == "-y" ]]; then
    branchName=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -z "$branchName" || "$branchName" == "HEAD" ]]; then
      echo "Not in a git repository or unable to determine branch."
      return 1
    fi
    echo "Pushing changes to origin/$branchName"
    git push origin "$branchName"
  else
    echo "Add -y to confirm push (example: gpo -y)"
    return 1
  fi
}

# Run `make refresh-envs` once per shell session when entering a repo folder.
# Behavior:
# - Scans the current directory and parent directories for a Makefile (Makefile, makefile, GNUmakefile)
#   that contains a `refresh-envs:` target.
# - If found, runs `make refresh-envs` in that Makefile's directory.
# - Only runs once per shell session (flag: `REFRESH_ENVS_DONE`).
# - Hook is triggered on directory changes (chpwd) and invoked once at sourcing time
#   to handle shells that start already in a repo.
_refresh_envs_once() {
  # Debug: show whether refresh was already performed this session
  echo "[_refresh_envs_once] REFRESH_ENVS_DONE=${REFRESH_ENVS_DONE:-unset}"

  if [[ -n "${REFRESH_ENVS_DONE-}" ]]; then
    echo "[_refresh_envs_once] already performed; skipping refresh"
    return 0
  fi

  local dir="$PWD"
  for mf in "$dir/Makefile" "$dir/makefile" "$dir/GNUmakefile"; do
    if [[ -f "$mf" ]] && grep -q '^[[:space:]]*refresh-envs:' "$mf" 2>/dev/null; then
      echo "Refreshing environment by running 'make refresh-envs' in: $dir"
      # set the done flag before running make to avoid re-entry if make triggers hooks
      REFRESH_ENVS_DONE=1
      # run make in the target directory without changing the shell's cwd (avoids chpwd)
      make -C "$dir" refresh-envs || true
      return 0
    fi
  done

  # Optional debug output when no target is found (enable by setting DEBUG_REFRESH=1)
  if [[ -n "${DEBUG_REFRESH-}" ]]; then
    echo "[_refresh_envs_once] no 'refresh-envs' target found in: $dir"
  fi
  return 0
}

# Register chpwd hook (autoload if necessary)
if ! typeset -f add-zsh-hook >/dev/null 2>&1; then
  autoload -Uz add-zsh-hook >/dev/null 2>&1 || true
fi
# Register chpwd hook if not already present (avoid duplicate registrations on re-source)
found=0
if (( ${+chpwd_functions} )); then
  for f in "${chpwd_functions[@]}"; do
    if [[ "$f" == "_refresh_envs_once" ]]; then
      found=1
      break
    fi
  done
fi
if [[ $found -eq 0 ]]; then
  add-zsh-hook chpwd _refresh_envs_once
fi

# Run the check once immediately for interactive shells only (avoids non-interactive
# subshells (e.g. spawned by `make`) recursively triggering the hook)
if [[ -o interactive ]]; then
  _refresh_envs_once
fi
