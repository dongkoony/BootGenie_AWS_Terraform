#!/bin/bash

# SSH 포트 변경
sed -i 's/#Port 22/Port 1717/g' /etc/ssh/sshd_config

# SSH 서비스 재시작
systemctl restart sshd

# 방화벽 설정 (필요한 경우)
ufw allow 1717/tcp

# Update the package index
apt-get update -y

# Install Apache httpd
apt-get install -y apache2

# Start and enable Apache httpd service
systemctl start apache2
systemctl enable apache2

# Install Docker
apt-get install -y docker.io

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Add the ubuntu user to the docker group
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Initialize Docker Swarm
docker swarm init

# Create a directory for Docker Compose files
mkdir -p /home/ubuntu/docker-app

# Example Docker Compose file for Apache container
cat <<EOL > /home/ubuntu/docker-app/docker-compose.yml
version: '3.3'

services:
  web:
    image: httpd:latest
    ports:
      - "80:80"
EOL

# Deploy the Docker Compose stack
cd /home/ubuntu/docker-app
docker stack deploy -c docker-compose.yml apache

# Set ownership of the directory to ubuntu user
chown -R ubuntu:ubuntu /home/ubuntu/docker-app
