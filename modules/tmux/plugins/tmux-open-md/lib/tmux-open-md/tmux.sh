tmux_value() {
  local pane_id="$1"
  local expression="$2"
  tmux display-message -p -t "${pane_id}" "${expression}" 2>/dev/null || true
}

capture_source() {
  local pane_id="$1"
  local source_name="$2"
  local source_order="$3"
  local output_path="$4"
  shift 4

  if tmux capture-pane -p -t "${pane_id}" "$@" > "${output_path}" 2>/dev/null && [ -s "${output_path}" ]; then
    printf '%s\t%s\t%s\n' "${source_order}" "${source_name}" "${output_path}"
  fi
}

add_root() {
  local root="$1"
  local roots_file="$2"
  [ -n "${root}" ] || return 0
  [ -d "${root}" ] || return 0
  root="$(cd "${root}" && pwd -P)"
  if ! grep -Fqx "${root}" "${roots_file}" 2>/dev/null; then
    printf '%s\n' "${root}" >> "${roots_file}"
  fi
}

add_git_root() {
  local directory="$1"
  local roots_file="$2"
  local root
  root="$(git -C "${directory}" rev-parse --show-toplevel 2>/dev/null || true)"
  add_root "${root}" "${roots_file}"
}

build_fixture_observation() {
  local capture_file="$1"
  local cwd="$2"
  local work_dir="$3"
  local sources_file="$4"
  local roots_file="$5"

  : > "${sources_file}"
  : > "${roots_file}"
  cp "${capture_file}" "${work_dir}/fixture.capture"
  printf '0\tfixture\t%s\n' "${work_dir}/fixture.capture" > "${sources_file}"
  add_root "${cwd}" "${roots_file}"
  add_git_root "${cwd}" "${roots_file}"
}

build_tmux_observation() {
  local pane_id="$1"
  local base_path="$2"
  local history_lines="$3"
  local work_dir="$4"
  local sources_file="$5"
  local roots_file="$6"
  local current_path start_path alternate_on pane_in_mode

  : > "${sources_file}"
  : > "${roots_file}"

  current_path="$(tmux_value "${pane_id}" '#{pane_current_path}')"
  start_path="$(tmux_value "${pane_id}" '#{pane_start_path}')"
  alternate_on="$(tmux_value "${pane_id}" '#{alternate_on}')"
  pane_in_mode="$(tmux_value "${pane_id}" '#{pane_in_mode}')"

  add_root "${current_path:-${base_path}}" "${roots_file}"
  add_root "${start_path}" "${roots_file}"
  add_git_root "${current_path:-${base_path}}" "${roots_file}"
  [ -z "${start_path}" ] || add_git_root "${start_path}" "${roots_file}"

  capture_source "${pane_id}" "main-history" 20 "${work_dir}/main.capture" -J -S "-${history_lines}" >> "${sources_file}"
  if [ "${alternate_on}" = "1" ]; then
    capture_source "${pane_id}" "alternate-screen" 10 "${work_dir}/alternate.capture" -a -q -J >> "${sources_file}"
  fi
  if [ "${pane_in_mode}" = "1" ]; then
    capture_source "${pane_id}" "tmux-mode" 0 "${work_dir}/mode.capture" -M -J >> "${sources_file}"
  fi
}
