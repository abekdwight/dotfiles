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

sh_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\''/g")"
}

key="$(get_tmux_option '@open-md-key' 'b')"
app="$(get_tmux_option '@open-md-app' 'Arto')"
selector="$(get_tmux_option '@open-md-selector' 'peco')"
history_lines="$(get_tmux_option '@open-md-history-lines' '2000')"
debug="$(get_tmux_option '@open-md-debug' '0')"
debug_log="$(get_tmux_option '@open-md-debug-log' '~/.tmux-open-md.debug.log')"
popup_width="$(get_tmux_option '@open-md-popup-width' '90%')"
popup_height="$(get_tmux_option '@open-md-popup-height' '70%')"
popup_title="$(get_tmux_option '@open-md-popup-title' 'Open Markdown')"
quoted_current_dir="$(sh_quote "${CURRENT_DIR}")"
quoted_app="$(sh_quote "${app}")"
quoted_selector="$(sh_quote "${selector}")"
quoted_history_lines="$(sh_quote "${history_lines}")"
quoted_debug="$(sh_quote "${debug}")"
quoted_debug_log="$(sh_quote "${debug_log}")"
quoted_popup_title="$(sh_quote "${popup_title}")"
quoted_popup_width="$(sh_quote "${popup_width}")"
quoted_popup_height="$(sh_quote "${popup_height}")"

tmux bind-key "${key}" run-shell "tmux display-popup -EE \
  -T ${quoted_popup_title} \
  -w ${quoted_popup_width} \
  -h ${quoted_popup_height} \
  -d #{q:pane_current_path} \
  -e TMUX_OPEN_MD_PLUGIN_DIR=${quoted_current_dir} \
  -e TMUX_OPEN_MD_PANE_ID=#{pane_id} \
  -e TMUX_OPEN_MD_BASE_PATH=#{q:pane_current_path} \
  -e TMUX_OPEN_MD_APP=${quoted_app} \
  -e TMUX_OPEN_MD_SELECTOR=${quoted_selector} \
  -e TMUX_OPEN_MD_HISTORY_LINES=${quoted_history_lines} \
  -e TMUX_OPEN_MD_DEBUG=${quoted_debug} \
  -e TMUX_OPEN_MD_DEBUG_LOG=${quoted_debug_log} \
  'bash \"\$TMUX_OPEN_MD_PLUGIN_DIR/scripts/open-md\"'"
