---
title: "claude code を Neovim で使用できるようにするまで"
emoji: "🐔"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Neovim", "Claude Code", "AI"]
published: true
---

# はじめに

この記事では、Neovim で Claude Code を使用できるようにするまでの手順を紹介します。

Cloude Code の具体的な使用方法までは説明していません。

## Claude Codeとは

Claude Codeは、Anthropic社が開発したターミナルベースのAIコーディングアシスタントです。コードベースを理解し、自然言語のコマンドを通じてタスクを実行できます。

公式のドキュメントは[こちら](https://docs.anthropic.com/en/docs/claude-code)

# インストール方法

## 1. Claude Codeのインストール

Claude Code をインストールします。

```bash
npm install -g @anthropic-ai/claude-code
```

インストールされたことを確認します。

```bash
claude --version
```

私の環境では、上記のコマンドではインストールできませんでした。
そのため、以下のコマンドを実行しています。

```bash
# 既存のグローバルパッケージのリストを保存
pm list -g --depth=0 > ~/npm-global-packages.txt

# npmのグローバルパッケージ用のディレクトリを作成
mkdir -p ~/.npm-global

# npmの設定を変更
npm config set prefix ~/.npm-global

# PATHに追加（.zshrcや.bashrcなど使用しているシェルの設定ファイルに追加）
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc

# 設定を反映
source ~/.zshrc

# Claude Codeをインストール
npm install -g @anthropic-ai/claude-code
```

インストール後、プロジェクトディレクトリに移動して`claude`コマンドを実行し、`Anthropic Console`アカウントを使って認証を完了します。

## 2. Neovimのセットアップ

### vim-plugを使ったインストール

`claude-code.nvim`プラグインをインストールするために、まず`~/.config/nvim/init.vim`（または設定ファイルの場所）を編集します：

```vim:init.vim
" vim-plugの設定部分
call plug#begin()

" 必須の依存関係
Plug 'nvim-lua/plenary.nvim'

" Claude Code Neovimプラグイン
Plug 'greggh/claude-code.nvim'

" その他のプラグイン...

call plug#end()

" プラグインの設定
lua << EOF
require('claude-code').setup({
  -- 設定オプション（必要に応じて）
})
EOF

" キーマッピング
let mapleader = ","
nnoremap <leader>cc <cmd>ClaudeCode<CR>
```

設定ファイルを保存した後、Neovimを起動して`:PlugInstall`を実行します。

## 3. 基本的な使い方

### コマンド

Neovim を起動して、以下のコマンドを実行します。

- `:ClaudeCode` - Claude Codeターミナルウィンドウの表示/非表示を切り替え
- `:ClaudeCodeContinue` - 最近の会話を再開
- `:ClaudeCodeResume` - 会話選択インタラクティブピッカーを表示

キーマッピングを設定している場合は、Neovim を起動して、以下のキーを押します。

```
,cc
```

- Claude Code の終了は、Claude Code のターミナル内で`/exit` または、 <C-d> を2回実行します。

# まとめ

Claude CodeとNeovimの統合により、AIアシスタントの力をお気に入りのエディタ内で直接活用できます。この組み合わせにより、コーディングの効率が大幅に向上し、複雑なタスクも簡単に処理できるようになります。

プラグインのさらなる機能や最新の更新については、[GitHub リポジトリ](https://github.com/greggh/claude-code.nvim)を参照してください。

# 参考資料

- [claude-code.nvim](https://github.com/greggh/claude-code.nvim)
- [claude-code](https://docs.anthropic.com/en/docs/claude-code)
- [claude-code(github)](https://github.com/anthropics/claude-code)
- [Troubleshooting](https://docs.anthropic.com/en/docs/claude-code/troubleshooting#recommended-solution-create-a-user-writable-npm-prefix)
