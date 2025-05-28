---
title: "Terraform backend/remote state の参照先を環境毎に変更する"
emoji: "🐔"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Terraform"]
published: false
---

# Terraform backend/remote state の環境別設定方法

## はじめに

Terraformでインフラ構築を行う際、複数環境（開発、テスト、本番など）を管理するケースは非常に多いです。この記事では、環境ごとに適切にTerraform backendを設定し、remote stateを参照する方法について説明します。

## Terraform backendとは

Terraform backendは、Terraformの状態（state）ファイルをどこに保存するかを定義する機能です。デフォルトでは、terraform.tfstateというファイルがローカルに保存されますが、チーム開発やCI/CDパイプラインでの利用を考えると、リモートの場所に保存するのが一般的です。

一般的なbackendの例：
- S3 (AWS)
- Azure Blob Storage
- Google Cloud Storage
- HashiCorp Terraform Cloud

## 環境ごとのbackend設定方法

### 方法1: 部分的な設定ファイル

```hcl
terraform {
  backend "s3" {
    # 共通設定のみここに記述
    bucket = "my-terraform-states"
    key    = "path/to/my/key"
    region = "us-west-1"
    # 環境依存の値は指定しない
  }
}
```

この方法では、`terraform init` コマンド実行時に `-backend-config` オプションを使用して環境固有の設定を追加します：

```bash
# 開発環境
terraform init -backend-config=env/dev-backend.hcl

# 本番環境
terraform init -backend-config=env/prod-backend.hcl
```

各環境のbackend設定ファイル例（`env/dev-backend.hcl`）：

```hcl
bucket = "dev-terraform-states"
key    = "dev/terraform.tfstate"
region = "us-west-1"
```

### 方法2: ワークスペースを利用する

Terraformのワークスペース機能を使用すると、同じバックエンド内で複数の状態ファイルを管理できます：

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-states"
    key    = "terraform.tfstate"
    region = "us-west-1"
    dynamodb_table = "terraform-locks"
  }
}
```

ワークスペースの作成と切り替え：

```bash
# 開発環境のワークスペース作成
terraform workspace new dev

# 本番環境のワークスペース作成
terraform workspace new prod

# 開発環境に切り替え
terraform workspace select dev

# 本番環境に切り替え
terraform workspace select prod
```

この方法では、S3バケット内にworkspace別のパスが自動的に作成されます（例：`env:/dev/terraform.tfstate`）。

## remote stateの参照

異なるTerraformプロジェクト間でリソース情報を共有する場合、`terraform_remote_state`データソースを使用します。環境ごとに正しいstateファイルを参照するには以下の方法があります：

### 方法1: 変数による動的参照

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  
  config = {
    bucket = "my-terraform-states"
    key    = "${var.environment}/network/terraform.tfstate"
    region = "us-west-1"
  }
}
```

`var.environment`は環境名を保持する変数です：

```hcl
variable "environment" {
  description = "環境名（dev, stg, prod）"
  type        = string
}
```

環境ごとに適切な値を指定してapplyします：

```bash
terraform apply -var="environment=dev"
```

### 方法2: ワークスペースに基づく参照

```hcl
locals {
  workspace_to_environment_map = {
    dev  = "development"
    stg  = "staging"
    prod = "production"
  }
  
  environment = local.workspace_to_environment_map[terraform.workspace]
}

data "terraform_remote_state" "network" {
  backend = "s3"
  
  config = {
    bucket = "my-terraform-states"
    key    = "${local.environment}/network/terraform.tfstate"
    region = "us-west-1"
  }
}
```

この方法では、現在選択されているワークスペース名に基づいて自動的に適切な環境が選択されます。

## まとめ

Terraformで複数環境を管理する際は、以下の方法が効果的です：

1. `-backend-config`オプションを使用して環境ごとに異なるbackend設定を適用する
2. Terraformワークスペースを使用して同じbackend内で環境ごとのstateを管理する
3. 変数やワークスペースを活用して、環境に応じた適切なremote stateを参照する

これらの方法を組み合わせることで、環境ごとのインフラ管理を効率的かつ安全に行うことができます。

## 参考資料

- [Terraform Backend Configuration](https://www.terraform.io/docs/language/settings/backends/configuration.html)
- [Terraform Workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
- [Terraform Remote State Data Source](https://www.terraform.io/docs/language/state/remote-state-data.html)
