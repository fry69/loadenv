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
    COMPREPLY=( $(compgen -W "${files[*]} list clear" -- "$cur") )
  fi
}

complete -F _loadenv_complete loadenv

loadenv () {
  local env_file="$HOME/.loadenv/${1}.env"
  
  # Use an array to store loaded variable names
  if [[ -z ${LOADENV_VARS[*]} ]]; then
    declare -ga LOADENV_VARS=()
  fi

  case "$1" in
    list)
      if [[ ${#LOADENV_VARS[@]} -gt 0 ]]; then
        echo "Loaded environment variables:"
        printf '%s\n' "${LOADENV_VARS[@]}"
      else
        echo "No environment variables have been loaded through loadenv in this session."
      fi
      return 0
      ;;
    clear)
      if [[ ${#LOADENV_VARS[@]} -gt 0 ]]; then
        for var in "${LOADENV_VARS[@]}"; do
          unset "$var"
        done
        LOADENV_VARS=()
        echo "All loadenv variables have been unset for this session."
      else
        echo "No environment variables to clear for this session."
      fi
      return 0
      ;;
  esac

  if [[ -f $env_file ]]; then
    local temp_file=$(mktemp)
    # Export variables and capture their names
    set -o allexport
    source "$env_file"
    set +o allexport

    # Store the names of the newly loaded variables
    grep -v '^#' "$env_file" | cut -d '=' -f1 > "$temp_file"
    
    while IFS= read -r var; do
      if [[ ! " ${LOADENV_VARS[*]} " =~ " ${var} " ]]; then
        LOADENV_VARS+=("$var")
      fi
    done < "$temp_file"
    
    rm "$temp_file"
    
    echo "Environment variables loaded from $env_file"
  else
    echo "Error: .env file not found: $env_file" >&2
    return 1
  fi
}

