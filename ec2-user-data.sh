#!/bin/bash
# EC2のユーザーデータ用スクリプト
sudo su ec2-user
cd ~
aws ssm get-parameter --name wp_tech_blog_SSH_KEY --query Parameter.Value --with-decryption --output text --region ap-northeast-1 > /home/ec2-user/.ssh/id_rsa
chmod 600 .ssh/config
chmod 400 .ssh/id_rsa

sudo yum update -y

# dockerのインストール、起動
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# docker-composeのインストール
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# gitのインストール
EC2_GIT_USER=$(aws ssm get-parameter --name wp_tech_blog_EC2_GIT_USER --query Parameter.Value --output text --region ap-northeast-1)
EC2_GIT_EMAIL=$(aws ssm get-parameter --name wp_tech_blog_EC2_GIT_EMAIL --query Parameter.Value --output text --region ap-northeast-1)
sudo yum install git -y
git config --global user.name "$EC2_GIT_USER"
git config --global user.email "$EC2_GIT_EMAIL"

git clone git@github.com:khomma0312/wp-tech-blog.git

# アプリをスタート
aws s3 cp s3://wp-tech-blog-info/.env /home/ec2-user/wp-tech-blog/app/
cp /home/ec2-user/wp-tech-blog/docker/compose-template/docker-compose.prod.yml /home/ec2-user/wp-tech-blog/docker-compose.yml
docker compose up -d

docker compose exec web composer install
docker compose restart

sudo rm /home/ec2-user/.ssh/id_rsa
