#!/usr/bin/env bash

set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value
  option_value="$(tmux show-option -gqv "${option}")"
  if [ -z "${option_value}" ]; then
    echo "${default_value}"
  else
    echo "${option_value}"
  fi
}

key="$(get_tmux_option '@layout-toggle-key' 'T')"

tmux bind-key "${key}" run-shell "${CURRENT_DIR}/scripts/toggle-layout"
