# Terraform AWS 3層Webアーキテクチャ構築

## プロジェクト概要

このリポジトリは、Terraformを用いてAWS上に3層Webアーキテクチャを構築する学習用ポートフォリオです。

単にAWSリソースを作成することではなく、以下を理解・説明できることを目的としています。

- VPC / Subnet / Route Table / Internet Gateway / NAT Gateway の役割
- ALB / Auto Scaling Group / EC2 の構成意図
- RDSをPrivateなネットワークに配置する理由
- Security Groupによる通信制御
- Terraform moduleによる構造化
- S3 Backend / State Lock によるRemote State管理

---

## アーキテクチャ図

```text
Internet
   |
   v
[ Application Load Balancer ]
   |  Public Subnet / Multi-AZ
   |
   v
[ Target Group ]
   |
   v
[ Auto Scaling Group ]
   |  Private Subnet / Multi-AZ
   |
   v
[ Amazon RDS MySQL ]
      DB Subnet / Multi-AZ
ネットワーク構成
VPC: 10.0.0.0/16

Public Subnet
- 10.0.1.0/24  ap-northeast-1a
- 10.0.2.0/24  ap-northeast-1c
- ALB
- NAT Gateway

Private Subnet
- 10.0.11.0/24 ap-northeast-1a
- 10.0.12.0/24 ap-northeast-1c
- EC2 / Auto Scaling Group

DB Subnet
- 10.0.21.0/24 ap-northeast-1a
- 10.0.22.0/24 ap-northeast-1c
- RDS用Subnet
使用技術
種別	技術
IaC	Terraform
Cloud	AWS
Network	VPC, Subnet, Route Table, Internet Gateway, NAT Gateway
Compute	EC2, Launch Template, Auto Scaling Group
Load Balancer	Application Load Balancer
Database	Amazon RDS for MySQL
Security	Security Group
State管理	S3 Backend, DynamoDB Lock
Region	ap-northeast-1
ディレクトリ構成
.
├── backend.tf
├── main.tf
├── outputs.tf
├── user_data.sh
└── modules
    ├── vpc
    │   ├── main.tf
    │   └── outputs.tf
    ├── app
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── variables.tf
    │   └── userdata.sh
    └── db
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
設計方針
1. Public Subnet

Public Subnetには、インターネットから直接アクセスを受ける必要があるALBと、Private Subnet内のEC2が外部通信するためのNAT Gatewayを配置しています。

EC2やRDSをPublic Subnetに置かないことで、外部からの直接アクセスを避ける構成にしています。

2. Private Subnet

Private Subnetには、Auto Scaling Group配下のEC2を配置しています。

ユーザーからの通信は直接EC2へ到達せず、必ず以下の経路を通ります。

User → ALB → Target Group → EC2

これにより、EC2を直接インターネットに公開せずにWebサーバとして利用できます。

3. DB Subnet

RDS用にDB Subnetを分離しています。

RDSは publicly_accessible = false とし、インターネットから直接アクセスできない構成にしています。

通信はSecurity Groupにより、アプリケーション用EC2からのMySQL通信のみ許可しています。

EC2 Security Group → RDS Security Group : TCP 3306
Security Group設計
ALB Security Group
Inbound
HTTP 80番を 0.0.0.0/0 から許可
Outbound
全許可
EC2 / nginx Security Group
Inbound
ALB Security GroupからHTTP 80番のみ許可
SSH 22番は学習用に許可
Outbound
全許可
RDS Security Group
Inbound
EC2 / nginx Security GroupからMySQL 3306番のみ許可
Outbound
全許可
Terraform Module構成

この構成では、Terraformコードを以下の3つのmoduleに分割しています。

vpc module
VPC
Public Subnet
Private Subnet
DB Subnet
Internet Gateway
NAT Gateway
Route Table
Route Table Association
app module
Application Load Balancer
Target Group
Listener
Launch Template
Auto Scaling Group
Security Group
db module
RDS MySQL
DB Subnet Group
RDS Security Group

module化することで、ネットワーク・アプリケーション・データベースの責務を分離しています。

Remote State

Terraform stateはローカルではなく、S3 Backendで管理しています。

terraform {
  backend "s3" {
    bucket         = "ydtnk-terraform-state-20260614"
    key            = "env/dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
Remote Stateを使う理由
stateファイルの紛失を防ぐ
複数端末・複数人での作業に対応しやすくする
state lockにより同時実行による破損を防ぐ
将来的なCI/CD連携の土台にする
実行手順
初期化
terraform init
フォーマット
terraform fmt -recursive
構文確認
terraform validate
差分確認
terraform plan
適用
terraform apply
削除
terraform destroy
動作確認
Terraform差分確認
terraform plan

確認結果：

No changes. Your infrastructure matches the configuration.
Remote State確認
aws s3 ls s3://ydtnk-terraform-state-20260614/env/dev/

確認結果：

terraform.tfstate
ALB DNS確認
terraform output alb_dns

ALBのDNS名へHTTPアクセスすることで、Auto Scaling Group配下のEC2で起動したnginxへ到達できることを確認します。

学習したこと

このプロジェクトを通じて、以下を学習しました。

Default VPCに依存しないVPC構築
Public / Private / DB Subnetの役割分離
ALBをPublic Subnetに配置する理由
EC2をPrivate Subnetに配置する理由
RDSをPublicにしない理由
Security Groupによる通信制御
Auto Scaling GroupとLaunch Templateの基本構成
Terraform moduleによるコード構造化
S3 BackendとDynamoDB LockによるRemote State管理
terraform plan による差分確認の重要性
既知の改善点

現時点では学習用構成として完成していますが、実務構成に近づけるために以下の改善余地があります。

1. RDSパスワード管理

現在は学習用としてRDSパスワードをコード内で扱っています。
今後は以下のような方法で管理する必要があります。

terraform.tfvars
環境変数
AWS Secrets Manager
SSM Parameter Store
2. SSH接続の見直し

現在は学習用にSSH 22番を許可しています。
実務ではSecurity GroupでSSHを開けず、SSM Session Managerを利用する構成が望ましいです。

3. DB Subnet Groupの整理

既存RDSのSubnet利用状況を考慮し、DB Subnet GroupにはPrivate SubnetとDB Subnetの両方を含めています。
将来的にはRDSの再作成または移行により、DB Subnet専用構成へ整理する余地があります。

4. backend設定の更新

Terraformのバージョンによっては、dynamodb_table に非推奨警告が表示されます。
今後はS3 backendのlockfile方式など、新しい方式への移行も検討します。

5. CI/CD

今後はGitHub Actionsを用いて、以下を自動化する予定です。

terraform fmt
terraform validate
terraform plan
まとめ

このプロジェクトでは、AWS上に3層WebアーキテクチャをTerraformで構築しました。

単なるリソース作成ではなく、ネットワーク分離、Security Group設計、Auto Scaling、RDS配置、Remote State管理まで含めて、実務に近いIaC構成を意識しています。

今後はREADMEや構成図の改善、CI/CD、自動テスト、Secret管理を追加し、より実務レベルのTerraformプロジェクトへ発展させます。
