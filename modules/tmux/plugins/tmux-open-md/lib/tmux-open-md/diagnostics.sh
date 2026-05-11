print_no_candidates() {
  local sources_file="$1"
  local roots_file="$2"
  local refs_file="$3"
  local source_names token_count root_values

  source_names="$(awk -F '\t' '{ values = values sep $2; sep = ", " } END { print values }' "${sources_file}")"
  token_count="$(wc -l < "${refs_file}" | tr -d ' ')"
  root_values="$(awk '{ values = values sep $0; sep = ", " } END { print values }' "${roots_file}")"

  printf '信頼できる .md 候補は見つかりませんでした。\n\n'
  printf '診断:\n'
  printf '  capture_sources: %s\n' "${source_names:--}"
  printf '  extracted_tokens: %s\n' "${token_count:-0}"
  printf '  resolution_roots: %s\n' "${root_values:--}"
  printf '\n'
  printf 'tmux から安全に扱えるのは、画面または履歴に明示された既存ローカル .md 参照だけです。\n'
}

write_debug_log() {
  local log_path="$1"
  local sources_file="$2"
  local roots_file="$3"
  local refs_file="$4"
  local candidates_file="$5"

  {
    printf '%s\n' '----'
    printf 'sources=%s\n' "$(cat "${sources_file}")"
    printf 'roots=%s\n' "$(cat "${roots_file}")"
    printf 'references_count=%s\n' "$(wc -l < "${refs_file}" | tr -d ' ')"
    printf 'candidates_count=%s\n' "$(wc -l < "${candidates_file}" | tr -d ' ')"
  } >> "${log_path}" 2>/dev/null || true
}
