if type -q tmux && test -z $TMUX && status --is-login && test "$TERM_PROGRAM" != "vscode" && test "$TERM_PROGRAM" != "WarpTerminal" && test "$TERM_PROGRAM" != "zed" && test "$TERM_PROGRAM" != "Orca" && not set -q CMUX_SOCKET && not set -q CMUX_SOCKET_PATH && not set -q MUXY_SOCKET_PATH
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

## あとでrustに移動
fish_add_path ~/.cargo/bin

# Java Home設定
set -x JAVA_HOME /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home

# JavaのbinディレクトリをPATHに追加
fish_add_path $JAVA_HOME/bin

# C++コンパイラフラグ設定
set -x CPPFLAGS "-I/opt/homebrew/opt/openjdk@17/include"
fish_add_path "$HOME/.local/bin"
fish_add_path $HOME/.local/bin

# Added by Windsurf
fish_add_path /Users/abekeishi/.codeium/windsurf/bin

# Added by Antigravity
fish_add_path /Users/abekeishi/.antigravity/antigravity/bin

# Added by WTP
wtp shell-init fish | source

# opencode
fish_add_path /Users/abekeishi/.opencode/bin

functions -q __phpbrew_set_path; and __phpbrew_set_path

status --is-interactive; and fish_user_key_bindings
