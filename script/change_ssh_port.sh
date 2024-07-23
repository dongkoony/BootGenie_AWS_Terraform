#!/bin/bash

# SSH 포트 변경
sed -i 's/#Port 22/Port 1717/g' /etc/ssh/sshd_config

# SSH 서비스 재시작
systemctl restart sshd

# 방화벽 설정 (필요한 경우)
ufw allow 1717/tcp

# 패키지 인덱스 업데이트
apt-get update -y

# Apache httpd 설치
apt-get install -y apache2

# Apache httpd 서비스 시작 및 활성화
systemctl start apache2
systemctl enable apache2

# Docker 설치
apt-get install -y docker.io

# Docker 서비스 시작 및 활성화
systemctl start docker
systemctl enable docker

# ubuntu 사용자를 docker 그룹에 추가
usermod -aG docker ubuntu

# Docker Compose 설치
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Docker Swarm 초기화
docker swarm init

# Docker Compose 파일을 위한 디렉토리 생성
mkdir -p /home/ubuntu/docker-app

# Apache 컨테이너용 Docker Compose 파일 예제
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

# Apache 설정 파일을 위한 디렉토리 생성
mkdir -p /home/ubuntu/docker-app/conf

# HTTP에서 HTTPS로 리디렉션 설정 추가
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

# HTML 파일을 위한 디렉토리 생성
mkdir -p /home/ubuntu/docker-app/html

# 샘플 HTML 파일 생성
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

# Docker Compose 스택 배포
cd /home/ubuntu/docker-app
docker stack deploy -c docker-compose.yml apache

# 디렉토리 소유권을 ubuntu 사용자로 설정
chown -R ubuntu:ubuntu /home/ubuntu/docker-app
