#!/bin/bash
cd /root

# 시스템 업데이트
echo "시스템 업데이트 중..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 필수 패키지 설치
echo "필수 패키지 설치 중..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Docker의 공식 GPG 키 및 저장소 추가
echo "Docker 저장소 설정 중..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 엔진 설치
echo "Docker 설치 중..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 서비스 시작 및 활성화
echo "Docker 서비스 시작 및 활성화..."
sudo systemctl start docker
sudo systemctl enable docker

# Docker 서비스 상태 확인 및 대기
echo "Docker 서비스 상태 확인 중..."
for i in {1..10}; do
    if systemctl is-active --quiet docker; then
        echo "Docker 서비스가 실행 중입니다."
        break
    fi
    echo "Docker 서비스가 아직 준비되지 않았습니다. 5초 대기 중... ($i/10)"
    sleep 5
done

# kubectl 설치
echo "kubectl 설치 중..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# KinD 설치
echo "KinD 설치 중..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# KinD 클러스터 생성
echo "KinD 클러스터 생성 중..."
kind create cluster --name my-cluster

# 클러스터 생성 확인 및 대기 (최대 60초)
echo "KinD 클러스터 상태 확인 중..."
for i in {1..12}; do
    if kubectl cluster-info --context kind-my-cluster &>/dev/null; then
        echo "KinD 클러스터가 성공적으로 생성되었습니다."
        break
    fi
    echo "KinD 클러스터가 아직 준비되지 않았습니다. 5초 대기 중... ($i/12)"
    sleep 5
done

# locale 변경 및 세션 타임아웃, 히스토리 환경 변수 설정
echo 'export LANG="ko_KR.UTF-8"' | sudo tee -a /etc/profile
echo 'export TMOUT=600' | sudo tee -a /etc/profile
echo 'export HISTTIMEFORMAT="%F %T - "' | sudo tee -a /etc/profile
echo 'export HISTIGNORE="clear:history:exit"' | sudo tee -a /etc/profile
source /etc/profile

# vi alias 설정
echo 'alias vi="vim"' | sudo tee -a /etc/skel/.bashrc
echo 'alias vi="vim"' >> ~/.bashrc
source ~/.bashrc

echo "설치 및 설정 완료!"