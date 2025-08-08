---
title: "Terraform で EC2 インスタンスを停止状態で管理する方法と注意点"
emoji: "🐔"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Terraform", "AWS", "EC2"]
published: true
---

# Terraform で EC2 インスタンスを停止状態で管理する方法と注意点

## はじめに

Terraform を使って AWS の EC2 インスタンスを管理していると、「インスタンスを削除ではなく停止状態で維持したい」という場面がたまにあります。

しかし、単純に AWS コンソールでインスタンスを停止しただけでは、次回の`terraform plan`で予期しない差分が発生することがあります。

この記事では、Terraform を使って EC2 インスタンスを適切に停止状態で管理する方法と、その際に発生した問題について解説します。

## aws_ec2_instance_state リソースの使用

Terraform で EC2 インスタンスの状態を明示的に管理するには、`aws_ec2_instance_state`リソースを使用します。

### 基本的な使い方

```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t3.small"
  # その他の設定...
}

resource "aws_ec2_instance_state" "example" {
  instance_id = aws_instance.example.id
  state       = "stopped"  # または "running"
}
```

構築済みのインスタンスに対して、この設定で`terraform apply`することで、インスタンスが停止状態となります。

## 実際に遭遇した問題

### 問題の発生

インスタンスに対して`aws_ec2_instance_state`を追加し、停止状態に設定しました。

```hcl
resource "aws_ec2_instance_state" "test_1" {
  instance_id = aws_instance.test_1.id
  state       = "stopped"
}
```

インスタンスは正常に停止されましたが、再度`terraform plan`を実行すると以下のようなリソースを置き換える差分が表示されました。
</br>(EC2のリソースの置き換えは、大量の差分が表示されるため結構びっくりします）

```
# aws_instance.test_1 must be replaced
-/+ resource "aws_instance" "test_1" {
  ~ associate_public_ip_address = false -> true # forces replacement
  # その他の差分...
}
```

### 問題の原因

この問題の根本原因は、**既存のインスタンスの実際の設定と Terraform の設定に差異があること**でした。

インスタンスが停止状態になったことで、パブリックIPアドレスが割り当てられなくなるため、パラメータが変更されていました。

具体的には：

-   既存のインスタンス：`associate_public_ip_address = false`
-   Terraform の設定：`associate_public_ip_address = true`

`associate_public_ip_address`の変更は、インスタンスの置き換えを強制する設定のため、`# forces replacement`が表示されていました。

## 解決方法

設定の差異を無視するように`lifecycle`ブロックを設定します。

```hcl
resource "aws_instance" "test_1" {
  ami                         = data.aws_ami.test_1_ami.id
  associate_public_ip_address = true
  # その他の設定...

  lifecycle {
    ignore_changes = [
      associate_public_ip_address
    ]
  }
}
```

実際の設定に、Terraform の設定を合わせることでも対応できますが、インスタンスの起動状態ではパラメータが逆転してしまうためリソースの置き換えが発生してしまいます。

## まとめ

Terraform で EC2 インスタンスを停止状態で管理する際は：

1. `aws_ec2_instance_state`リソースを使用する
2. 既存のインスタンスと Terraform の設定に差異がないか確認する
3. 差異がある場合は、`ignore_changes`を使用する

適切な設定により、Terraform を使って EC2 インスタンスの状態を安全かつ確実に管理できるようになります。

不要になったインスタンスは削除した方がいいと思っていますが、状況に合わせて停止で運用する場合には参考にされて下さい。

## 参考

-   [Terraform AWS Provider - aws_ec2_instance_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_instance_state)
-   [Terraform AWS Provider - aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

