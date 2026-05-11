select_candidate() {
  local candidates_file="$1"
  local selector="$2"
  local labels_file selected index path
  require_selector_command
  labels_file="$(mktemp -t tmux-open-md.labels.XXXXXX)"
  trap 'rm -f "${labels_file}" >/dev/null 2>&1 || true' RETURN

  cut -f 5- "${candidates_file}" > "${labels_file}"
  selected="$(${selector} --prompt 'Markdown> ' < "${labels_file}" || true)"
  [ -n "${selected}" ] || return 0
  index="${selected%%.*}"

  path="$(awk -F '\t' -v selected_index="${index}" 'BEGIN { target = selected_index ". " } index($5, target) == 1 { print $4; exit }' "${candidates_file}")"
  printf '%s\n' "${path}"
}
