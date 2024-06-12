#!/bin/bash

# SSH 포트 변경
sed -i 's/#Port 22/Port 1717/g' /etc/ssh/sshd_config

# SSH 서비스 재시작
systemctl restart sshd

# 방화벽 설정 (필요한 경우)
ufw allow 1717/tcp

# Docker 설치
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 현재 사용자를 docker 그룹에 추가
usermod -aG docker ubuntu
newgrp docker

