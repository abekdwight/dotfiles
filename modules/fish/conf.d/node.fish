# Project-local tool versions are resolved by mise.
if type -q mise
    fish_add_path --prepend $HOME/.local/share/mise/shims
end
