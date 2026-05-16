# Neovim コマンドパレット辞書生成

このディレクトリでは、コマンドパレットの候補生成、カバレッジ評価、辞書更新を必ず分けて扱う。

## 対象ファイル

`lua/config/command_palette_source.lua` は、現在の Neovim 設定から機械的に生成する候補一覧である。このファイルは `vim.fn.getcompletion('', 'command')` と `$VIMRUNTIME/doc/index.txt` に基づく生成物であり、手で編集しない。

`lua/config/command_palette.lua` は、AI が完成データとして埋める辞書である。このファイルは追跡対象であり、候補一覧とカバレッジに基づいて更新する。

`lua/config/command_palette_core.lua` は、候補生成、カバレッジ評価、コマンドパレット表示の実装を持つ。候補生成が `command_palette.lua` を読む設計に戻してはいけない。カバレッジ評価がファイルを書き換える設計に戻してはいけない。

## 作業手順

1. 候補一覧を生成する。

```sh
make nvim-command-palette-candidates
```

この手順は `lua/config/command_palette_source.lua` だけを更新する。ヘルプ参照だけの候補や Ex コマンドと重複する `index.txt` 由来の候補は、候補生成の時点で除外する。

2. カバレッジを確認する。

```sh
make nvim-command-palette-coverage
```

この手順は既存の `lua/config/command_palette_source.lua` と `lua/config/command_palette.lua` を比較するだけであり、候補一覧を再生成してはいけない。`command_palette_source.lua` がない場合は、先に候補一覧を生成する。

3. カバレッジに基づいて `lua/config/command_palette.lua` を埋める。

未登録、余剰、欠落、重複が出ている場合は、カバレッジの詳細を入力として `command_palette.lua` を更新する。すべての entry は完成データとして扱い、draft、confidence、人間確認待ち、未補完状態を作らない。

## 禁止されるアプローチ

### 一括スクリプト生成の禁止

`command_palette.lua` を Python スクリプト等の外部プログラムで一括生成してはいけない。各 entry は個別にコマンドやキー操作の意味を理解した上で記述する必要がある。コマンド名の prefix パターンマッチングや文字列合成で自動生成された label/description は、人間が読んで意味を理解できる情報にならない。

```lua
-- このような自動生成 entry を作ってはならない:
{
  command = 'balt',
  label = 'balt',                        -- コマンド名そのまま、情報ゼロ
  description = 'バッファ操作: balt',     -- 「カテゴリ名: コマンド名」は情報ゼロ
  category = 'buffer',                   -- b で始まるから推測しただけ
}
```

### フォールバック説明の禁止

以下のような、情報価値のないフォールバック説明で entry を埋めてはいけない:

- `「{カテゴリ名}操作: {コマンド名}」` 形式の説明
- `「{モード名}で{truncated 英文}」` 形式の説明
- コマンド名やキー名を言い換えただけの説明

適切な description を書けない entry は、**未登録のまま残し**、カバレッジの未登録数として可視化する。フォールバック説明で埋めてカバレッジの数値だけをゼロにすることは、完了条件を満たさない。

### カバレッジ数値を目的化しない

`make nvim-command-palette-coverage` の全指標がゼロであることは**必要条件**だが、それだけで完了ではない。すべての entry の description が上記の品質基準を満たしていることが**十分条件**である。カバレッジ数値だけをゼロにすることを目的化し、内容の品質を犠牲にしてはいけない。

## 辞書生成の進め方

辞書の生成は Sisyphus の delegation アーキテクチャに従う。

1. Plan agent で作業計画を立てる。entry 総数を確認し、バッチ分割の方針を決める。
2. `deep` または `unspecified-high` agent にバッチ単位で委譲する。1 バッチあたり 30〜50 entry を上限とし、各 agent が個々のコマンドの意味を十分に理解できる粒度にする。
3. 各バッチ agent には以下を渡す:
   - 担当する source entry の一覧（コマンド名、または builtin_key の mode/key/tag/description）
   - 各 entry の `:help {tag}` または `:help {command}` の内容（librarian agent で事前に取得するか、agent 自身に取得させる）
   - 上記の description 品質基準と禁止事項
4. 各バッチの完了時にカバレッジを確認し、未登録数の減少と description 品質を検証する。

## 辞書の構造

`command_palette.lua` は次のトップレベル構造を返す。

```lua
return {
  commands = {},
  builtin_keys = {},
}
```

`commands` の各 entry は、少なくとも次の項目を持つ。

```lua
{
  command = 'wq',
  label = '保存して終了',
  description = '現在ファイルを書き込み、現在ウィンドウを閉じる',
  category = 'file',
  aliases = { '保存終了', 'write quit', 'save quit' },
  action = 'execute',
}
```

`builtin_keys` の各 entry は、組み込みキー操作そのものを表す。`builtin_keys` に `command = 'help ...'` のような疑似コマンドを作ってはいけない。

```lua
{
  label = '選択範囲を小文字化',
  description = 'ビジュアル選択範囲の英字を小文字に変換する',
  category = 'keymap',
  aliases = { 'v_u', 'u', 'x', 'make highlighted area lowercase' },
  mode = 'x',
  key = 'u',
  tag = 'v_u',
  action = 'execute',
}
```

`source_command` が候補一覧に存在する場合は、組み込みキー操作と Ex コマンドの対応を表すために保持する。表示時のキー列は `builtin_keys.source_command`、辞書内の `keys`、実際の keymap から合成されるため、動的 keymap を `command_palette.lua` に手で固定しない。

## 内容の決め方

`description` は原則として日本語で書く。検索性のために英語のヘルプ文、実コマンド名、別名は `aliases` に入れてよい。

`label` は、候補一覧でユーザーが機能を判別するための短い名前にする。`description` は、対象のコマンドやキー操作が何に対して何を行い、実行後に何が起きるのかを書く。`description` に、コマンド名、キー名、モード名、ヘルプタグを言い換えただけの文を書いてはいけない。

### description の品質基準

`description` は、**その entry を単独で読んだとき**に、コマンドやキー操作が何をするか理解できる文章でなければならない。

**合格例（何をするか、何が起きるかが明確）**:
- `現在ファイルを書き込み、現在ウィンドウを閉じる`
- `ビジュアル選択範囲の英字を小文字に変換する`
- `カーソル位置から行末まで削除し、挿入モードに切り替える`

**不合格例**:
- `バッファ操作: balt` ← コマンド名の言い換えに過ぎず、情報ゼロ
- `ノーマルモードでcursor N words forward` ← モード名の前置きは冗長（`mode` が別フィールドにある）、英語断片との混在
- `表示操作: redrawstatus` ← カテゴリ名とコマンド名の羅列、何が起きるか不明

### builtin_keys の description 固有のルール

builtin_keys の `description` には、以下の要素を書いてはいけない。これらはすべて別フィールドで表示されるため、description に含めると冗長になり全エントリが似た文章になる:

- **モード名**（「ノーマルモードで」「ビジュアルモードで」「コマンドラインモードで」等）→ `mode` フィールドがある
- **キー名**（「u を押すと」「CTRL-W q は」等）→ `key` フィールドがある
- **ヘルプタグ**（「詳細は v_u を参照」等）→ `tag` フィールドがある

builtin_keys の `description` に書くべきことは、そのキーを押した**結果**と、操作の**対象範囲**だけである。

**合格例**（キーを押した結果だけを説明）:
- `ビジュアル選択範囲の英字を小文字に変換する`
- `カーソル位置から行末まで削除する`
- `指定範囲を外部フィルタコマンドで処理する`

**不合格例**（モード名・キー名の前置きで冗長）:
- `ノーマルモードでカーソルを1文字左に移動する` → `カーソルを1文字左に移動する`
- `コマンドラインモードでカーソル前の文字を削除する` → `カーソル前の文字を削除する`
- `ビジュアルモードで選択範囲を削除する` → `選択範囲を削除する`

### 情報源

組み込み Ex コマンドは、Neovim のヘルプを根拠にする。各コマンドの `:help {command}` を参照し、そこから description を起こす。コマンド名の文字列パターンや prefix からの推測で description を生成してはいけない。

プラグインやユーザー定義コマンドは、`vim.api.nvim_get_commands({})`、`:verbose command` 相当の情報、プラグインの設定やドキュメントを根拠にする。

組み込みキー操作は、`command_palette_source.lua` の `mode`、`key`、`tag`、`description` の情報と、対応する `:help {tag}` を根拠にする。`:help {tag}` を実行する entry ではなく、キー操作そのものの entry として記述する。source の `description` は truncated な断片であるため、必ず `:help {tag}` の全文で補完する。

### action の判定

`action` は、引数なしで安全に実行できるコマンドだけを `execute` にする。引数入力が必要なコマンド、対象範囲を指定するコマンド、破壊的または取り消しにくいコマンドは `edit` にする。`edit` は Enter 時にコマンドラインへ展開するだけで、即実行しない。

`execute` にしてよいのは、`:nohlsearch` のように実行するだけで完結し、副作用が小さいコマンド、および情報表示のみを行うコマンドに限る。

## 完了条件

最後に必ず次を実行する。

```sh
make nvim-command-palette-coverage
```

カバレッジの未登録、余剰、必須項目欠落、action 不正、重複がすべて 0 であることを完了条件にする。0 でない値が残る場合は、その値を個別例外として扱わず、候補生成、辞書構造、または entry の内容を修正する。

`command_palette_source.lua` は生成物なので、直接編集した差分を残さない。`command_palette.lua` は成果物なので、必要な更新を残す。
