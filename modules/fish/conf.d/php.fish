# for phpbrew
if type -q phpbrew
    source ~/.phpbrew/phpbrew.fish
end

# for composer
if type -q composer
    fish_add_path ~/.composer/vendor/bin
end
