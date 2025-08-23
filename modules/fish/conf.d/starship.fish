# [ alias ]
if type -q starship
    # VSCodeのターミナルでは、transient prompt機能を無効化
    if test "$TERM_PROGRAM" = "vscode"
        starship init fish --print-full-init | sed -e '/^function enable_transience/,/^end/d' -e '/^enable_transience/d' | source
    else
        starship init fish | source
    end
end
