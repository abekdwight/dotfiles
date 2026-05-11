extract_references() {
  local sources_file="$1"
  local source_order source_name source_path

  while IFS=$'\t' read -r source_order source_name source_path; do
    [ -n "${source_path}" ] || continue
    awk -v source_order="${source_order}" -v source_name="${source_name}" '
      function clean(token) {
        gsub(/\033\[[0-?]*[ -\/]*[@-~]/, "", token)
        gsub(/\033\][^\007]*(\007|\033\\)/, "", token)
        gsub(/^file:\/\//, "", token)
        gsub(/["`\047]/, "", token)
        gsub(/^[\(\[\{<,;:[:space:]]+/, "", token)
        gsub(/[\)\]\}>。,;:]+$/, "", token)
        sub(/[?#].*$/, "", token)
        sub(/:[0-9]+(:[0-9]+)?$/, "", token)
        gsub(/\. *md$/, ".md", token)
        return token
      }

      {
        line = $0
        gsub(/[\(\)\[\]\{\}<>,"`\047]/, " ", line)
        count = split(line, fields, /[[:space:]]+/)
        for (field_index = 1; field_index <= count; field_index++) {
          token = clean(fields[field_index])
          lower = tolower(token)
          if (lower ~ /\.md$/ && lower !~ /^https?:\/\//) {
            position = (NR * 1000) + field_index
            extractor = "visible-token"
            if (token ~ /^a\// || token ~ /^b\//) extractor = "diff-token"
            printf "%s\t%s\t%s\t%s\t%s\n", source_order, position, extractor, source_name, token
          }
        }
      }
    ' "${source_path}"
  done < "${sources_file}"
}
