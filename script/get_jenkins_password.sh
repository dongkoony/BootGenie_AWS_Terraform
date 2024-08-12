#!/bin/bash

PASSWORD_FILE="/home/ubuntu/jenkins_initial_password.txt"

# Jenkins 컨테이너가 완전히 시작될 때까지 대기
echo "Jenkins 서비스 시작 확인 중... (최대 10분 대기)"
for i in {1..60}; do
    if docker ps --filter name=jenkins --format "{{.ID}}" | grep -q "."; then
        echo "Jenkins 서비스가 시작되었습니다."
        break
    fi
    sleep 10
done

# Jenkins 컨테이너 ID 찾기
CONTAINER_ID=$(docker ps --filter name=jenkins --format "{{.ID}}" | head -n1)

# 초기 관리자 비밀번호 추출 (최대 5분 대기)
for i in {1..30}; do
    PASSWORD=$(docker exec $CONTAINER_ID cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
    if [ ! -z "$PASSWORD" ]; then
        break
    fi
    sleep 10
done

if [ -z "$PASSWORD" ]; then
    echo "Jenkins 초기 비밀번호를 가져오지 못했습니다. 나중에 수동으로 확인해주세요."
else
    echo "Jenkins 초기 관리자 비밀번호: $PASSWORD"
    
    # 비밀번호 파일 저장
    echo $PASSWORD > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"  # 보안 설정
    
    echo "비밀번호가 $PASSWORD_FILE 파일에 저장되었습니다."
fi

echo "Jenkins UI는 http://$(curl -s ifconfig.me):8080 에서 접속 가능합니다."
