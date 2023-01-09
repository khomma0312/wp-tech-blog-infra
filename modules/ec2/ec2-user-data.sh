#!/bin/bash
sudo yum update -y

# dockerのインストール、起動
DOCKER_CONFIG="/home/ec2-user/.docker"
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo service docker restart

# docker-composeのインストール
mkdir -p ${DOCKER_CONFIG}/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
sudo chown -R ec2-user:ec2-user $DOCKER_CONFIG

# gitのインストール
sudo yum install git -y
