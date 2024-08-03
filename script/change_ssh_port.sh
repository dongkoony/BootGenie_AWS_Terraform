#!/bin/bash

# 로그 파일 설정
LOG_FILE="/home/ubuntu/setup.log"

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
echo "SSH 서비스 재시작 중" >> $LOG_FILE 2>&1
sudo systemctl restart sshd >> $LOG_FILE 2>&1

# 방화벽 설정 (필요한 경우)
echo "방화벽에서 포트 1717 허용 중" >> $LOG_FILE 2>&1
sudo ufw allow 1717/tcp >> $LOG_FILE 2>&1

# 패키지 인덱스 업데이트
echo "패키지 인덱스 업데이트 중" >> $LOG_FILE 2>&1
sudo apt-get update -y >> $LOG_FILE 2>&1

# Apache httpd 설치
echo "Apache HTTP 서버 설치 중" >> $LOG_FILE 2>&1
sudo apt-get install -y apache2 >> $LOG_FILE 2>&1

# Apache httpd 서비스 시작 및 활성화
echo "Apache HTTP 서버 시작 및 활성화 중" >> $LOG_FILE 2>&1
sudo systemctl start apache2 >> $LOG_FILE 2>&1
sudo systemctl enable apache2 >> $LOG_FILE 2>&1

# Docker 설치
echo "Docker 설치 중" >> $LOG_FILE 2>&1
sudo apt-get install -y docker.io >> $LOG_FILE 2>&1

# Docker 서비스 시작 및 활성화
echo "Docker 서비스 시작 및 활성화 중" >> $LOG_FILE 2>&1
sudo systemctl start docker >> $LOG_FILE 2>&1
sudo systemctl enable docker >> $LOG_FILE 2>&1

# ubuntu 사용자를 docker 그룹에 추가
echo "사용자 'ubuntu'를 docker 그룹에 추가 중" >> $LOG_FILE 2>&1
sudo usermod -aG docker ubuntu >> $LOG_FILE 2>&1

# Docker Compose 설치
echo "Docker Compose 설치 중" >> $LOG_FILE 2>&1
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> $LOG_FILE 2>&1
sudo chmod +x /usr/local/bin/docker-compose >> $LOG_FILE 2>&1

# Docker Swarm 초기화
echo "Docker Swarm 초기화 중" >> $LOG_FILE 2>&1
sudo docker swarm init >> $LOG_FILE 2>&1

# Docker Compose 파일을 위한 디렉토리 생성
echo "Docker Compose 파일을 위한 디렉토리 생성 중" >> $LOG_FILE 2>&1
mkdir -p /home/ubuntu/docker-app >> $LOG_FILE 2>&1

# Apache 컨테이너용 Docker Compose 파일 예제 생성
echo "Apache 컨테이너용 Docker Compose 파일 생성 중" >> $LOG_FILE 2>&1
cat <<EOL > /home/ubuntu/docker-app/docker-compose.yml
version: '3.3'

services:
  web:
    image: httpd:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /home/ubuntu/docker-app/html:/usr/local/apache2/htdocs
      - /home/ubuntu/docker-app/conf:/usr/local/apache2/conf
    command: ["/usr/local/apache2/bin/httpd", "-D", "FOREGROUND", "-f", "/usr/local/apache2/conf/httpd.conf"]
EOL
echo "Docker Compose 파일 생성 완료" >> $LOG_FILE 2>&1

# Apache 설정 파일을 위한 디렉토리 생성
echo "Apache 설정 파일을 위한 디렉토리 생성 중" >> $LOG_FILE 2>&1
mkdir -p /home/ubuntu/docker-app/conf >> $LOG_FILE 2>&1

# HTTP에서 HTTPS로 리디렉션 설정 추가
echo "Apache 설정에 HTTP에서 HTTPS로 리디렉션 설정 추가 중" >> $LOG_FILE 2>&1
cat <<EOL > /home/ubuntu/docker-app/conf/httpd.conf
<VirtualHost *:80>
    ServerName boot-genie-test.click
    ServerAlias www.boot-genie-test.click
    Redirect "/" "https://boot-genie-test.click/"
</VirtualHost>

<VirtualHost *:443>
    DocumentRoot "/usr/local/apache2/htdocs"
    ServerName boot-genie-test.click
    ServerAlias www.boot-genie-test.click
    SSLEngine on
    SSLCertificateFile "/usr/local/apache2/conf/server.crt"
    SSLCertificateKeyFile "/usr/local/apache2/conf/server.key"
    <Directory "/usr/local/apache2/htdocs">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOL
echo "Apache 설정 파일 생성 완료" >> $LOG_FILE 2>&1

# HTML 파일을 위한 디렉토리 생성
echo "HTML 파일을 위한 디렉토리 생성 중" >> $LOG_FILE 2>&1
mkdir -p /home/ubuntu/docker-app/html >> $LOG_FILE 2>&1

# 샘플 HTML 파일 생성
echo "샘플 HTML 파일 생성 중" >> $LOG_FILE 2>&1
cat <<EOL > /home/ubuntu/docker-app/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Hello Boot-Genie First Web Site</title>
</head>
<body>
    <h1>Hello Boot-Genie First Web Site</h1>
</body>
</html>
EOL
echo "샘플 HTML 파일 생성 완료" >> $LOG_FILE 2>&1

# Docker Compose 스택 배포
echo "Docker Compose 스택 배포 중" >> $LOG_FILE 2>&1
cd /home/ubuntu/docker-app
sudo docker stack deploy -c docker-compose.yml apache >> $LOG_FILE 2>&1

# 디렉토리 소유권을 ubuntu 사용자로 설정
echo "디렉토리 소유권을 'ubuntu' 사용자로 설정 중" >> $LOG_FILE 2>&1
sudo chown -R ubuntu:ubuntu /home/ubuntu/docker-app >> $LOG_FILE 2>&1

echo "설치 및 설정 완료" >> $LOG_FILE 2>&1
