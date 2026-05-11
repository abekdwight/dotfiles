open_markdown() {
  local path="$1"
  local app_name="$2"

  if ! open -Ra "${app_name}" >/dev/null 2>&1; then
    printf 'tmux-open-md: %s が見つかりません\n' "${app_name}" >&2
    exit 1
  fi

  if ! open -a "${app_name}" "${path}"; then
    printf 'tmux-open-md: %s で開けませんでした: %s\n' "${app_name}" "${path}" >&2
    exit 1
  fi
}
