#!/bin/bash

# 로그 파일 설정
LOG_FILE="/home/ubuntu/docker_install.log"

# 로그 파일 초기화
> $LOG_FILE

# 시스템 시간대를 서울로 설정
echo "시간대를 Asia/Seoul로 설정 중" >> $LOG_FILE 2>&1
sudo timedatectl set-timezone Asia/Seoul >> $LOG_FILE 2>&1

# 시간대 설정 확인
echo "현재 시간대 설정:" >> $LOG_FILE 2>&1
timedatectl >> $LOG_FILE 2>&1

# 환경 변수 로드
echo "환경 변수 로드 중" >> $LOG_FILE 2>&1
source ${PROJECT_ROOT}/.env >> $LOG_FILE 2>&1

# Script 시작
echo "시작: $(date)" >> $LOG_FILE 2>&1

# SSH 포트 변경
echo "SSH 포트 변경 시작" >> $LOG_FILE 2>&1
sudo sed -i 's/#Port 22/Port 1717/g' /etc/ssh/sshd_config >> $LOG_FILE 2>&1
sudo systemctl restart sshd >> $LOG_FILE 2>&1
echo "SSH 포트 변경 완료" >> $LOG_FILE 2>&1

# 방화벽 설정 (필요한 경우)
echo "방화벽 설정 시작" >> $LOG_FILE 2>&1
sudo ufw allow 1717/tcp >> $LOG_FILE 2>&1  # ssh
sudo ufw allow 11117/tcp >> $LOG_FILE 2>&1 # jenkins
sudo ufw allow 80/tcp >> $LOG_FILE 2>&1    # HTTP
sudo ufw allow 443/tcp >> $LOG_FILE 2>&1   # HTTPS
sudo ufw allow 2377/tcp >> $LOG_FILE 2>&1  # Docker Swarm 클러스터 관리
sudo ufw allow 7946/tcp >> $LOG_FILE 2>&1  # Docker Swarm 노드 간 통신
sudo ufw allow 7946/udp >> $LOG_FILE 2>&1  # Docker Swarm 노드 간 통신
sudo ufw allow 4789/udp >> $LOG_FILE 2>&1  # Docker Swarm 오버레이 네트워크
sudo ufw reload >> $LOG_FILE 2>&1
echo "방화벽 설정 완료" >> $LOG_FILE 2>&1

# Docker 및 JDK 17 설치
echo "Docker 및 JDK 17 설치 시작" >> $LOG_FILE 2>&1
sudo apt-get update >> $LOG_FILE 2>&1
sudo apt-get install -y ca-certificates curl gnupg lsb-release openjdk-17-jdk >> $LOG_FILE 2>&1

sudo mkdir -p /etc/apt/keyrings >> $LOG_FILE 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg >> $LOG_FILE 2>&1

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null >> $LOG_FILE 2>&1

sudo apt-get update >> $LOG_FILE 2>&1
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin >> $LOG_FILE 2>&1
echo "Docker 및 JDK 17 설치 완료" >> $LOG_FILE 2>&1

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker ubuntu >> $LOG_FILE 2>&1
echo "사용자를 docker 그룹에 추가 완료" >> $LOG_FILE 2>&1

# Docker 소켓 권한 설정
sudo chmod 666 /var/run/docker.sock >> $LOG_FILE 2>&1

# Docker 환경 변수 설정
echo 'export PATH=$PATH:/usr/bin' >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc >> $LOG_FILE 2>&1

# Docker 브리지 네트워크 설정 변경
echo "Docker 브리지 네트워크 설정 변경 중" >> $LOG_FILE 2>&1
cat <<EOL | sudo tee /etc/docker/daemon.json > /dev/null
{
    "bip": "172.18.0.1/16",
    "dns": ["8.8.8.8", "8.8.4.4"]
}
EOL

# Docker 데몬 재시작
sudo systemctl restart docker >> $LOG_FILE 2>&1
echo "Docker 데몬 설정 변경 및 재시작 완료" >> $LOG_FILE 2>&1

# Docker 데몬이 실행 중인지 확인 (최대 2분 대기)
echo "Docker 데몬 상태 확인 시작" >> $LOG_FILE 2>&1
for i in {1..24}; do
    if sudo systemctl is-active --quiet docker; then
        echo "Docker 데몬이 실행 중입니다." >> $LOG_FILE 2>&1
        break
    fi
    echo "Docker 데몬을 기다리는 중... ($i)" >> $LOG_FILE 2>&1
    sleep 5
done

# Docker 명령어가 작동하는지 확인
if ! docker --version >> $LOG_FILE 2>&1; then
    echo "Docker가 제대로 설치되지 않았습니다." >> $LOG_FILE 2>&1
    exit 1
fi

# Docker Swarm 초기화 (첫 번째 노드에서만 실행)
if ! sudo docker info | grep -q "Swarm: active" >> $LOG_FILE 2>&1; then
    sudo docker swarm init >> $LOG_FILE 2>&1
    echo "Docker Swarm 초기화 완료" >> $LOG_FILE 2>&1
else
    echo "Docker Swarm이 이미 활성화되어 있습니다." >> $LOG_FILE 2>&1
fi

# 로컬에서 EC2로 docker-compose.yaml 파일 전송
# scp -i $PEM_KEY_PATH ${PROJECT_ROOT}/docker-compose.yaml ubuntu@$EC2_PUBLIC_IP:/home/ubuntu/docker-compose.yaml

# docker-compose 실행
sudo docker stack deploy -c /home/ubuntu/docker-compose.yaml jenkins >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
    echo "docker-compose 실행 실패" >> $LOG_FILE 2>&1
    exit 1
else
    echo "docker-compose로 Jenkins 및 Traefik 서비스 생성 완료" >> $LOG_FILE 2>&1
fi

# Docker 설치가 완료되었음을 표시하는 파일 생성
touch /home/ubuntu/docker_installed
echo "끝: $(date)" >> $LOG_FILE 2>&1
