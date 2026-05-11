if type -q fzf and type -q rg
    set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
end

if type -q eza
    alias ls 'eza'
end

if type -q bat
    set -x MANPAGER 'col -bx | bat -l man -p'
    alias cat 'bat'
end

# fd をfindにエイリアスするのはAI時代に相性が悪すぎる。
# if type -q fd
#     alias find 'fd'
# end

if type -q dog
    alias dig 'dog'
end

if type -q gping
    alias ping 'gping'
end

if type -q dust
    alias du 'dust'
end

# browse git remote repository
if type -q gh
    alias gitbr="gh browse"
end

# for texcount
if type -q perl
    alias texcount="perl $HOME/.texcount/texcount.pl"
end

# for convert HEIC to jpg
if type -q magick
    alias convHEIC="magick mogrify -monitor -format jpg *.HEIC"
end

if type -q windsurf
    alias code="windsurf ."
end
