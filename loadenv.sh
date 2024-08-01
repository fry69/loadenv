#!/usr/bin/env bash

_loadenv_complete() {
  local cur prev files
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ $prev == loadenv ]]; then
    files=("$HOME/.loadenv/"*.env)
    files=(${files[@]##*/})  # remove directory path
    files=(${files[@]%.env})  # remove .env suffix
    COMPREPLY=( $(compgen -W "${files[*]}" -- "$cur") )
  fi
}

complete -F _loadenv_complete loadenv

loadenv () {
  local env_file="$HOME/.loadenv/${1}.env"

  if [[ -f $env_file ]]; then
    set -o allexport
    source "$env_file"
    set +o allexport
  else
    echo "Error: .env file not found: $env_file" >&2
    return 1
  fi
}

