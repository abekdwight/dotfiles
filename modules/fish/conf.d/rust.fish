if type -q cargo
    fish_add_path ~/.cargo/bin
    # for rust, rustep, cargo
    source $HOME/.cargo/env
end
