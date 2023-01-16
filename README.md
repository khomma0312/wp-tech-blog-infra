# インフラ構成
## 構成図
![terraform-architecture drawio](https://user-images.githubusercontent.com/43176969/212724909-e3e72957-d168-45a1-98de-e7969addba47.png)

## 使用サービス
- VPC
- Route 53
- CloudFront
- ALB
- EC2
- RDS
- ACM
- IAM
- Systems Manager

## 各サービス間の通信
- ユーザー端末・CloudFront間: HTTP/HTTPS通信。HTTPでアクセスされた場合、CloudFrontでHTTPSにリダイレクトさせている。
- CloudFront・ALB間: HTTPS通信。
- ALB・EC2間: HTTP通信。ALBでSSL終端させている。
- EC2・RDS間: MySQLにポート3306で通信。
