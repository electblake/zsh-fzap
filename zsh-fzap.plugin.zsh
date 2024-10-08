#!/usr/bin/env zsh

if ! typeset -f _command_exists > /dev/null; then
  function _command_exists () {
      command -v "$1" >/dev/null 2>&1
  }
fi

function fzap () {
    if _command_exists "aws"; then
      if _command_exists "fzf"; then
          # Check if the current AWS session is valid
          if ! aws sts get-caller-identity >/dev/null 2>&1; then
              echo "AWS session is not valid or has expired. Please log in."
              return 1
          fi

          # Get the current AWS profile
          CURR_AWS_PROFILE=$(aws configure list | grep -m 1 profile | awk '{print $2}')
          NEW_AWS_PROFILE=$(aws configure list-profiles | fzf --header="Current Profile: $CURR_AWS_PROFILE")
          
          if [ -n "$NEW_AWS_PROFILE" ]; then
              export AWS_PROFILE="$NEW_AWS_PROFILE"
              echo "Switched to profile \"$AWS_PROFILE\"."
          else
              echo "No profile selected. Keeping current profile \"$CURR_AWS_PROFILE\"."
          fi
      else
          echo "fzf is not available"
      fi
  else
      echo "aws is not available"
  fi
}

alias fuzzy-aws-profile=fzap
