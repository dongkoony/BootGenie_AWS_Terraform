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
newgrp docker

# Docker Swarm 초기화 (첫 번째 노드에서만 실행)
if ! docker info | grep -q "Swarm: active"; then
    docker swarm init
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

# Jenkins 컨테이너가 완전히 시작될 때까지 대기
echo "Jenkins 서비스 시작 중... (최대 2분 대기)"
for i in {1..24}; do
    if docker service ls | grep -q "jenkins"; then
        break
    fi
    sleep 5
done

# Jenkins 컨테이너 ID 찾기
CONTAINER_ID=$(docker ps --filter name=jenkins --format "{{.ID}}" | head -n1)

# 초기 관리자 비밀번호 추출 (최대 30초 대기)
for i in {1..6}; do
    PASSWORD=$(docker exec $CONTAINER_ID cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
    if [ ! -z "$PASSWORD" ]; then
        break
    fi
    sleep 5
done

# Jenkins 초기 관리자 비밀번호 추출 및 저장
PASSWORD_DIR="/home/ubuntu/Project/BootGenie_AWS_Terraform"
PASSWORD_FILE="$PASSWORD_DIR/jenkins_initial_password.txt"

if [ -z "$PASSWORD" ]; then
    echo "Jenkins 초기 비밀번호를 가져오지 못했습니다. 나중에 수동으로 확인해주세요."
else
    echo "Jenkins 초기 관리자 비밀번호: $PASSWORD"
    
    # 디렉토리가 없으면 생성
    mkdir -p "$PASSWORD_DIR"
    
    # 비밀번호 파일 저장
    echo $PASSWORD > "$PASSWORD_FILE"
    
    echo "비밀번호가 $PASSWORD_FILE 파일에 저장되었습니다."
fi

echo "Jenkins UI는 http://$(curl -s ifconfig.me):11117 에서 접속 가능합니다."