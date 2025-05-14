if type -q tmux && test -z $TMUX && status --is-login && test "$TERM_PROGRAM" != "vscode"
    tmux_attach_session_if_needed
end

test -f ~/.config/fish/chefrepi.fish && source ~/.config/fish/chefrepi.fish
test -f ~/.config/fish/project.fish &&  source ~/.config/fish/project.fish

if test "$TERM_PROGRAM" = "vscode"
    set -g theme_newline_cursor no
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
