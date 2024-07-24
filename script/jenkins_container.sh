#!/bin/bash

LOG_FILE="/home/ubuntu/docker_install.log"

echo "시작: $(date)" > $LOG_FILE

# SSH 포트 변경
echo "SSH 포트 변경 시작" >> $LOG_FILE
sed -i 's/#Port 22/Port 1717/g' /etc/ssh/sshd_config
systemctl restart sshd
echo "SSH 포트 변경 완료" >> $LOG_FILE

# 방화벽 설정 (필요한 경우)
echo "방화벽 설정 시작" >> $LOG_FILE
ufw allow 1717/tcp  # ssh
ufw allow 11117/tcp # jenkins
ufw allow 443/tcp   # HTTPS
ufw allow 2377/tcp  # Docker Swarm 클러스터 관리
ufw allow 7946/tcp  # Docker Swarm 노드 간 통신
ufw allow 7946/udp  # Docker Swarm 노드 간 통신
ufw allow 4789/udp  # Docker Swarm 오버레이 네트워크
ufw reload
echo "방화벽 설정 완료" >> $LOG_FILE

# Docker 및 JDK 17 설치
echo "Docker 및 JDK 17 설치 시작" >> $LOG_FILE
apt-get update >> $LOG_FILE 2>&1
apt-get install -y ca-certificates curl gnupg lsb-release openjdk-17-jdk >> $LOG_FILE 2>&1

mkdir -p /etc/apt/keyrings >> $LOG_FILE 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg >> $LOG_FILE 2>&1

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null >> $LOG_FILE 2>&1

apt-get update >> $LOG_FILE 2>&1
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin >> $LOG_FILE 2>&1
echo "Docker 및 JDK 17 설치 완료" >> $LOG_FILE

# 현재 사용자를 docker 그룹에 추가
usermod -aG docker ubuntu
echo "사용자를 docker 그룹에 추가 완료" >> $LOG_FILE

# Docker 소켓 권한 설정
chmod 666 /var/run/docker.sock

# Docker 환경 변수 설정
echo 'export PATH=$PATH:/usr/bin' >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc

# Docker 브리지 네트워크 설정 변경
cat <<EOL > /etc/docker/daemon.json
{
    "bip": "172.18.0.1/16"
}
EOL

# Docker 데몬 재시작
systemctl restart docker
echo "Docker 데몬 설정 변경 및 재시작 완료" >> $LOG_FILE

# Docker 데몬이 실행 중인지 확인 (최대 2분 대기)
echo "Docker 데몬 상태 확인 시작" >> $LOG_FILE
for i in {1..24}; do
    if systemctl is-active --quiet docker; then
        echo "Docker 데몬이 실행 중입니다." >> $LOG_FILE
        break
    fi
    echo "Docker 데몬을 기다리는 중... ($i)" >> $LOG_FILE
    sleep 5
done

# Docker 명령어가 작동하는지 확인
if ! docker --version; then
    echo "Docker가 제대로 설치되지 않았습니다." >> $LOG_FILE
    exit 1
fi

# Docker Swarm 초기화 (첫 번째 노드에서만 실행)
if ! docker info | grep -q "Swarm: active"; then
    docker swarm init
    echo "Docker Swarm initialized" >> $LOG_FILE
else
    echo "Docker Swarm is already active" >> $LOG_FILE
fi

# Jenkins 서비스 생성
docker service create \
    --name jenkins \
    --publish 11117:8080 \
    --mount type=volume,source=jenkins-data,target=/var/jenkins_home \
    jenkins/jenkins:latest-jdk17
echo "Jenkins 서비스 생성 완료" >> $LOG_FILE

# Jenkins 설정 파일 수정
sleep 30  # Jenkins가 충분히 시작될 때까지 대기
CONTAINER_ID=$(docker ps --filter name=jenkins --format "{{.ID}}" | head -n1)
docker exec $CONTAINER_ID sed -i 's/https:\/\/updates.jenkins.io/http:\/\/updates.jenkins.io/g' /var/jenkins_home/hudson.model.UpdateCenter.xml
echo "Jenkins 설정 파일 수정 완료" >> $LOG_FILE

# Jenkins 서비스 재시작
docker restart $CONTAINER_ID
echo "Jenkins 서비스 재시작 완료" >> $LOG_FILE

# Docker 설치가 완료되었음을 표시하는 파일 생성
touch /home/ubuntu/docker_installed
echo "끝: $(date)" >> $LOG_FILE
