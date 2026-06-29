## nvim install and clean

```bash
# clean
make nvim-clean

# install
make nvim-install
```

初回起動時に mini.deps がプラグインを取得します。LSP は mason.nvim 経由で自動導入されます。
必要に応じて `:Mason` で状況確認や追加インストールを行ってください。

## fish install and clean

```bash
# clean
make fish-clean

# install
make fish-install

# update
make fish-update
```

## tmux install and clean

```bash
# clean
make tmux-clean

# install
make tmux-install
# Press `prefix` + `I` to install the plugins in the tmux-session.
```

## warp install and clean

```bash
# clean
make warp-clean

# install
make warp-install
```

Warp の通常設定は `~/.warp/settings.toml`、キーバインドは `~/.warp/keybindings.yaml` にシンボリックリンクされます。
`settings.toml` は保存時に反映されますが、`keybindings.yaml` は Warp の再起動が必要です。

## orca install and clean

```bash
# clean
make orca-clean

# install
make orca-install
```

Orca のキーバインドは `~/.orca/keybindings.json` にシンボリックリンクされます。
変更は Orca の再読込（`⌘⇧R` / Force Reload）または再起動で反映されます。

## homebrew backup

バックアップは Brewfile に書き込む

```bash
# install
brew bundle

# backup
brew bundle dump
```

## key bindings

### tmux

prefix: `Ctrl + q`

### fish

normal mode(fish_vi_key_bindings): `Ctrl + [`
