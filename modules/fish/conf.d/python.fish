# for pyenv
if test -d "$HOME/.pyenv"
    set -gx PYENV_ROOT "$HOME/.pyenv"
    fish_add_path "$PYENV_ROOT/bin"
    fish_add_path "$PYENV_ROOT/shims"
end

# for browser-use
if test -d "$HOME/.browser-use/bin"
    fish_add_path "$HOME/.browser-use/bin"
end
if test -d "$HOME/.browser-use-env/bin"
    fish_add_path "$HOME/.browser-use-env/bin"
end
