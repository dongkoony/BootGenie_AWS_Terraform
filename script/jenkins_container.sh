#!/bin/bash

# SSH 포트 변경
sed -i 's/#Port 22/Port 1717/g' /etc/ssh/sshd_config

# SSH 서비스 재시작
systemctl restart sshd

# 방화벽 설정 (필요한 경우)
ufw allow 1717/tcp  # ssh
ufw allow 11117/tcp # jenkins
ufw allow 2377/tcp  # Docker Swarm 클러스터 관리
ufw allow 7946/tcp  # Docker Swarm 노드 간 통신
ufw allow 7946/udp  # Docker Swarm 노드 간 통신
ufw allow 4789/udp  # Docker Swarm 오버레이 네트워크
ufw reload

# Docker 설치
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 현재 사용자를 docker 그룹에 추가
usermod -aG docker ubuntu

# Docker 소켓 권한 설정
sudo chmod 666 /var/run/docker.sock

# Docker Swarm 초기화 (첫 번째 노드에서만 실행)
if ! docker info | grep -q "Swarm: active"; then
    sudo docker swarm init
    echo "Docker Swarm initialized"
else
    echo "Docker Swarm is already active"
fi

# Jenkins 서비스 생성
docker service create \
    --name jenkins \
    --publish 11117:8080 \
    --mount type=volume,source=jenkins-data,target=/var/jenkins_home \
    jenkins/jenkins:lts
