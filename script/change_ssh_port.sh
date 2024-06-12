#!/bin/bash

# SSH 포트 변경
sed -i 's/#Port 22/Port 1717/g' /etc/ssh/sshd_config

# SSH 서비스 재시작
systemctl restart sshd

# 방화벽 설정 (필요한 경우)
ufw allow 1717/tcp