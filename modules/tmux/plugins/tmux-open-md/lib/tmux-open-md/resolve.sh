expand_candidate() {
  local value="$1"
  case "${value}" in
    ~/*) printf '%s/%s\n' "${HOME}" "${value#~/}" ;;
    *) printf '%s\n' "${value}" ;;
  esac
}

canonical_file() {
  local path="$1"
  local dir base
  [ -f "${path}" ] || return 1
  dir="$(dirname "${path}")"
  base="$(basename "${path}")"
  dir="$(cd "${dir}" && pwd -P)" || return 1
  printf '%s/%s\n' "${dir}" "${base}"
}

resolve_one_reference() {
  local value="$1"
  local roots_file="$2"
  local expanded variant root path canonical

  for variant in "${value}" "${value#a/}" "${value#b/}"; do
    expanded="$(expand_candidate "${variant}")"
    case "${expanded}" in
      /*)
        canonical="$(canonical_file "${expanded}" 2>/dev/null || true)"
        if [[ "${canonical}" == *.md ]]; then
          printf '100\tabsolute\t%s\n' "${canonical}"
          return 0
        fi
        ;;
      *)
        while IFS= read -r root; do
          [ -n "${root}" ] || continue
          path="${root}/${expanded}"
          canonical="$(canonical_file "${path}" 2>/dev/null || true)"
          if [[ "${canonical}" == *.md ]]; then
            printf '80\troot-relative\t%s\n' "${canonical}"
            return 0
          fi
        done < "${roots_file}"
        ;;
    esac
  done
  return 1
}

resolve_references() {
  local refs_file="$1"
  local roots_file="$2"
  local seen_file
  seen_file="$(mktemp -t tmux-open-md.seen.XXXXXX)"
  trap 'rm -f "${seen_file}" >/dev/null 2>&1 || true' RETURN

  while IFS=$'\t' read -r source_order position extractor source_name value; do
    [ -n "${value}" ] || continue
    resolved="$(resolve_one_reference "${value}" "${roots_file}" || true)"
    [ -n "${resolved}" ] || continue
    confidence="${resolved%%$'\t'*}"
    rest="${resolved#*$'\t'}"
    reason="${rest%%$'\t'*}"
    path="${rest#*$'\t'}"
    if grep -Fqx "${path}" "${seen_file}" 2>/dev/null; then
      continue
    fi
    printf '%s\n' "${path}" >> "${seen_file}"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "${confidence}" "${source_order}" "${position}" "${path}" "${source_name}" "${extractor}" "${reason}"
  done < "${refs_file}"
}

candidate_source_label() {
  local source_name="$1"
  local extractor="$2"
  local source_label extractor_label

  case "${source_name}" in
    main-history) source_label="tmux履歴" ;;
    alternate-screen) source_label="代替画面" ;;
    tmux-mode) source_label="tmuxコピーモード" ;;
    fixture) source_label="テスト入力" ;;
    *) source_label="${source_name}" ;;
  esac

  case "${extractor}" in
    visible-token) extractor_label="表示されたMarkdown参照" ;;
    diff-token) extractor_label="diff内のMarkdown参照" ;;
    *) extractor_label="${extractor}" ;;
  esac

  printf '%s / %s\n' "${source_label}" "${extractor_label}"
}

rank_candidates() {
  local resolved_file="$1"
  local index=1 source_label
  sort -t $'\t' -k1,1nr -k2,2n -k3,3n -k4,4 "${resolved_file}" | while IFS=$'\t' read -r confidence source_order position path source_name extractor reason; do
    [ -n "${path}" ] || continue
    source_label="$(candidate_source_label "${source_name}" "${extractor}")"
    printf '%s\t%s\t%s\t%s\t%s. %s [%s]\n' "${confidence}" "${source_order}" "${position}" "${path}" "${index}" "${path}" "${source_label}"
    index=$((index + 1))
  done
}
