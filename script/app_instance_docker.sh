#!/bin/bash

# 로그 파일 위치 설정
LOG_FILE="/home/ubuntu/docker_install.log"

# 로그 파일 초기화
> $LOG_FILE

# 시스템 시간대를 서울로 설정
echo "시간대를 Asia/Seoul로 설정 중" >> $LOG_FILE 2>&1
sudo timedatectl set-timezone Asia/Seoul >> $LOG_FILE 2>&1

# 시간대 설정 확인
echo "서울(한국) 시간대 설정 완료" >> $LOG_FILE 2>&1
timedatectl >> $LOG_FILE 2>&1

# SSH 포트 변경
echo "SSH 포트를 1717로 변경 중" >> $LOG_FILE 2>&1
sudo sed -i 's/#Port 22/Port 1717/g' /etc/ssh/sshd_config >> $LOG_FILE 2>&1

# SSH 서비스 재시작
echo "SSH 서비스를 재시작 중" >> $LOG_FILE 2>&1
sudo systemctl restart sshd >> $LOG_FILE 2>&1

# 방화벽 설정 (필요한 경우)
echo "포트 1717을 방화벽에 허용 중" >> $LOG_FILE 2>&1
sudo ufw allow 1717/tcp >> $LOG_FILE 2>&1

# Docker 설치
echo "패키지 정보 업데이트 중" >> $LOG_FILE 2>&1
sudo apt-get update >> $LOG_FILE 2>&1
echo "필요한 패키지 설치 중" >> $LOG_FILE 2>&1
sudo apt-get install -y ca-certificates curl gnupg lsb-release >> $LOG_FILE 2>&1

echo "Docker 저장소 설정 중" >> $LOG_FILE 2>&1
sudo mkdir -p /etc/apt/keyrings >> $LOG_FILE 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg >> $LOG_FILE 2>&1

echo "Docker 저장소를 소스 리스트에 추가 중" >> $LOG_FILE 2>&1
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Docker 저장소에서 패키지 정보 업데이트 중" >> $LOG_FILE 2>&1
sudo apt-get update >> $LOG_FILE 2>&1
echo "Docker 설치 중" >> $LOG_FILE 2>&1
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin >> $LOG_FILE 2>&1

# 현재 사용자를 docker 그룹에 추가
echo "ubuntu 사용자를 docker 그룹에 추가 중" >> $LOG_FILE 2>&1
sudo usermod -aG docker ubuntu >> $LOG_FILE 2>&1
newgrp docker >> $LOG_FILE 2>&1

echo "Docker 설치 및 설정 완료" >> $LOG_FILE 2>&1
