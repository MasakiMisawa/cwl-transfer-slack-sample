# cwl-transfer-slack-sample  

1. [What is?](#what-is?)  
1. [Architecture.](#architecture)　　
1. [Usage](#usage)  
  
## What is?  
CloudWatch Logsに出力されたログ本文をSlackに転送させる為のアーキテクチャを作成する為のサンプルコードです。  
詳細は、[この記事](https://masakimisawa.com/cwl-transfer-slack)をご参照ください。  

## Architecture　　
全体構成です。  
![architecture](document/architecture/cwl-transfer-slack-architecture.png)
  
## Usage  
以下の手順でリソースを作成していくことで、上記アーキテクチャを作成可能です。  
  
1. S3バケットの作成  
`バケット名はリージョン全体でユニークの為、cwl-transfer-slack-sample-bucket の部分は任意のバケット名に置き換えてください。`  
```
$ cd src/resource/s3
$ terraform init
* locals.tfのbucketを任意のバケット名に書き換えて保存 *
$ terraform apply
```  
  
2. CloudWatch Logsから転送されたログ内容の解凍用Lambda function作成  
```
$ cd src/resource/kinesis/firehose/processor
$ terraform init
$ terraform apply
```  
  
3. KinesisFirehose作成  
```
$ cd src/resource/kinesis/firehose
$ terraform init
$ terraform apply
```  
  
4. CloudWatch Logsのロググループに対してサブスクリプションフィルタ作成  
```
$ cd src/ops/cwl/subscription_filter
$ terraform init
* locals.tfのlog_group_nameを任意のロググループ名に書き換えて保存 *
$ terraform apply
```  
  
5. パラメータストアの作成とログ転送先SlackチャネルのIncomming webhook URL保存  
```
$ cd src/resource/ssm/parameter_store
$ terraform init
$ terraform apply
* 作成したパラメータストアにログ転送先SlackチャネルのIncomming webhook URLを保存 *
```  
  
6. Slackにログ転送するLambda function作成  
```
$ cd src/ops/lambda
$ terraform init
$ terraform apply
```