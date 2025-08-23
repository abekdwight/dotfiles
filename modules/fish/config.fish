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

## あとでrustに移動
fish_add_path ~/.cargo/bin

# Java Home設定
set -x JAVA_HOME /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home

# JavaのbinディレクトリをPATHに追加
fish_add_path $JAVA_HOME/bin

# C++コンパイラフラグ設定
set -x CPPFLAGS "-I/opt/homebrew/opt/openjdk@17/include"
