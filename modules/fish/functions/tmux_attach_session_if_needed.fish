function tmux_attach_session_if_needed
    if not type -q tmux
        return
    end

    # locale が UTF-8 以外なら tmux -u を使う
    set -l locale_value ""
    if set -q LC_ALL; and test -n "$LC_ALL"
        set locale_value "$LC_ALL"
    else if set -q LC_CTYPE; and test -n "$LC_CTYPE"
        set locale_value "$LC_CTYPE"
    else if set -q LANG; and test -n "$LANG"
        set locale_value "$LANG"
    end

    set -l tmux_cmd tmux
    if test -n "$locale_value"; and not string match -rq 'UTF-?8' -- "$locale_value"
        set tmux_cmd tmux -u
    end

    set ID (command $tmux_cmd list-sessions)
    if test -z "$ID"
        command $tmux_cmd new-session
        return
    end

    set new_session "Create New Session"
    set ID (string join \n (command $tmux_cmd list-sessions) $new_session | peco --on-cancel=error | cut -d: -f1)
    if test "$ID" = "$new_session"
        command $tmux_cmd new-session
    else if test -n "$ID"
        command $tmux_cmd attach-session -t "$ID"
    end
end
