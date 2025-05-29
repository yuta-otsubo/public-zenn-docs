---
title: "Amazon Q Developer CLI だけを使用してゲームを作成してみる"
emoji: "🐔"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["AmazonQCLI", "AWS", "AI"]
published: true
---

## はじめに

Amazon Q Developer CLI のみを使用して、1行もコードを書かずにゲームを作成してみます。(READMEは手書きで書いちゃいましたが...)

子供の頃に好きだった、スライドパズルを作成してみました。

## 環境構築

環境構築に参考資料のキャンペーンページに沿って、[AWS Bulders ID の登録](https://community.aws/builderid?trk=b085178b-f0cb-447b-b32d-bd0641720467&sc_channel=el)、[Amazon Q CLI のインストール](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html)、[pygame のインストール](https://www.pygame.org/wiki/GettingStarted) を行ったのみです

Amazon Q により、CLIの自動補完もしてくれますが、私の環境では自動補完を別で動かしている関係でおかしな挙動になってしまったので、自動補完は無効化して使用しました。

![](https://storage.googleapis.com/zenn-user-upload/06f4421d6b26-20250529.png)

## ゲームを作成してみる

まずは、ターミナルで `q chat` コマンドを実行して、AIコーディングアシスタントを起動させます。

```bash
q chat
```

後は、エージェントとやり取りをしながら、ゲームの作成と修正を繰り返すだけです。

最近のエージェントでは、画像を使って説明することができますが、CLIなので言語化して何がしたいのかを的確に指示していく必要があります。

最初に、何を作ってほしいか指示するとき以外は、プロンプトにはあまり多く指示せず、1箇所ずつ修正するように指示を行っていきました。

エージェントの修正に納得できなかった時に戻せるように、1つの指示毎にコミットポイントを作成しながら作業を行いましたが、指示をすれば元の状態に戻してくれたのかもしれません。

十数回の指示で、最低限動くゲームの作成が完成することができました。

![](https://storage.googleapis.com/zenn-user-upload/20ff56beb294-20250529.gif)

## まとめ

- 詳細に指示をしなくても、やりたいことを実現できた
- 業務で使用できるようなら、Pro の方も使用してみてもいいかも
- AWS アカウントも必要なく、無料の範囲でゲームを作成できるので、みなさんも是非試してみてもらえればと思います

## 参考資料

[Amazon Q CLI でゲームを作ろう Tシャツキャンペーン](https://aws.amazon.com/jp/blogs/news/build-games-with-amazon-q-cli-and-score-a-t-shirt/)

[構築したゲームのソースコード](https://github.com/yuta-otsubo/sliding-puzzle)
