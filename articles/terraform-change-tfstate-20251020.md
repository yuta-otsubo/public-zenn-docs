---
title: "Terraformのtfstateファイルを別のS3バケットに移動する方法"
emoji: "🐔"
type: "tech"
topics: ["Terraform", "AWS"]
published: true
---

## はじめに

Terraformのtfstate(ステートファイル)をS3バケット保存していますが、環境差異があり別のS3バケットに保存している箇所があったため、tfstateの保存バケットを変更する必要がありました。

ステートファイルを保存しているS3バケットを変更するだけでは、全てのリソースが再作成されてしまうため、 `terraform init -migrate-state`コマンドを使用して安全に移行する必要があります。

この記事では、その手順を紹介します。

## 前提条件と事前確認

バックエンドについては、`.tfbackend`を使用しての手順になっていますが、`terraform_backend.tf`を使用したやり方でも応用できるものになっているかと思います。

`dev.tfbackend`
```
bucket = "old-dev-terraform-bucket"
region  = "ap-northeast-1"
key     = "state/dev.tfstate"
encrypt = true
```

バックエンド保存先の変更前後で `terraform plan` の差異がないことを確認できるように、事前に実行結果を確認されることをオススメします。

## 移行手順

### 1. 元のバックエンドで初期化

まず、元のバックエンド設定を指定した状態で`terraform init`を実行します。

```bash
terraform init -migrate-state -backend-config=dev.tfbackend
```

実行結果:

```
Initializing the backend...
Backend configuration changed!

Terraform has detected that the configuration specified for the backend
has changed. Terraform will now check for existing state in the backends.

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
Initializing provider plugins...
- terraform.io/builtin/terraform is built in to Terraform
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.xx.0

Terraform has been successfully initialized!
```

`-migrate-state` オプションを指定することで `Backend configuration changed!` となり、これにより既存のステートファイルを新しいバックエンドへ移行する準備をしてくれます。

### 2. バックエンド設定を変更

バックエンドファイル（`dev.tfbackend`）の保存先を新しいS3バケットに変更します。

`dev.tfbackend`
```
bucket = "new-dev-terraform-bucket"
region  = "ap-northeast-1"
key     = "state/dev.tfstate"
encrypt = true
```

### 3. 新しいバックエンドへ移行

再度、同じコマンドを実行します。

```bash
terraform init -migrate-state -backend-config=dev.tfbackend
```

実行結果:

```
Initializing the backend...
Backend configuration changed!

Terraform has detected that the configuration specified for the backend
has changed. Terraform will now check for existing state in the backends.

Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "s3" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
```

既存のステートの状態を新しいバックエンドにコピーするか確認が入るので、`yes` とすることで、 ステートファイルが新しいバックエンドにコピーされます。

### 4. 動作確認

最後に、`terraform plan`を実行してリソースの再作成が発生しないこと、変更前と同じ実行結果になっていることを確認します。

## まとめ

`terraform init -migrate-state`を使用することで、tfstateファイルを安全に別のS3バケットに移行できます。

移行後は `terraform plan`で差分が発生していないことを確認することをオススメします。
