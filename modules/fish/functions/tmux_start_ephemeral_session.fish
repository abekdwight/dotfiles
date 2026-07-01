function tmux_start_ephemeral_session --description 'Orca 用の使い捨て tmux セッションを起動する（専用ソケットで隔離し永続化しない）'
    if not type -q tmux
        return
    end

    # locale が UTF-8 以外なら tmux -u を使う（tmux_attach_session_if_needed と同じ配慮）
    set -l locale_value ""
    if set -q LC_ALL; and test -n "$LC_ALL"
        set locale_value "$LC_ALL"
    else if set -q LC_CTYPE; and test -n "$LC_CTYPE"
        set locale_value "$LC_CTYPE"
    else if set -q LANG; and test -n "$LANG"
        set locale_value "$LANG"
    end

    set -l u_flag
    if test -n "$locale_value"; and not string match -rq 'UTF-?8' -- "$locale_value"
        set u_flag -u
    end

    # -L orca               : 通常(維持用)tmux とは別ソケットで隔離し、普通のターミナルの一覧に出さない
    # destroy-unattached on : ターミナルを閉じた瞬間にセッションを破棄し、使い捨てにする（溜めない）
    exec tmux $u_flag -L orca new-session \; set-option destroy-unattached on
end
