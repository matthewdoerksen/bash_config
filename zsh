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
