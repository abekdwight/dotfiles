load_config() {
  TMUX_OPEN_MD_APP="${TMUX_OPEN_MD_APP:-Arto}"
  TMUX_OPEN_MD_SELECTOR="${TMUX_OPEN_MD_SELECTOR:-peco}"
  TMUX_OPEN_MD_HISTORY_LINES="${TMUX_OPEN_MD_HISTORY_LINES:-2000}"
  TMUX_OPEN_MD_DEBUG="${TMUX_OPEN_MD_DEBUG:-0}"
  TMUX_OPEN_MD_DEBUG_LOG="${TMUX_OPEN_MD_DEBUG_LOG:-${HOME}/.tmux-open-md.debug.log}"
}

require_command() {
  local command_name="$1"
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'tmux-open-md: %s が見つかりません\n' "${command_name}" >&2
    exit 1
  fi
}

require_core_commands() {
  require_command awk
  require_command sort
  require_command cut
  require_command git
}

require_selector_command() {
  require_command "${TMUX_OPEN_MD_SELECTOR}"
}

require_open_command() {
  require_command open
}
