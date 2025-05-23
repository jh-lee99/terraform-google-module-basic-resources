# Docker Ubuntu 서비스 모듈

이 모듈은 Google Cloud Platform(GCP)에서 Docker가 설치된 Ubuntu 인스턴스와 관련 방화벽 규칙을 생성하는 Terraform 모듈입니다.

## 주요 기능

- Docker가 설치된 Ubuntu 컴퓨트 인스턴스(VM) 생성
- 인스턴스에 대한 방화벽 규칙 설정 (TCP/UDP 및 ICMP)
- SSH 키 설정 및 시작 스크립트를 통한 Docker 설치 및 구성

## 리소스

이 모듈은 다음과 같은 리소스를 생성합니다:

- `google_compute_instance`: Docker가 설치된 Ubuntu 인스턴스
- `google_compute_firewall`: TCP/UDP 및 ICMP 방화벽 규칙

## SSH 키 설정 가이드

1. SSH 키 쌍 생성:
   ```bash
   # 로컬 머신에서 SSH 키 쌍 생성
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/gcp_key -C "your-email@example.com"
   ```

2. 생성된 키 파일:
   - 개인 키: `~/.ssh/gcp_key` (안전하게 보관)
   - 공개 키: `~/.ssh/gcp_key.pub` (VM에 업로드)

3. 프로젝트 디렉토리에 키 폴더 생성:
   ```bash
   mkdir -p ./key
   cp ~/.ssh/gcp_key.pub ./key/id_rsa.pub
   ```

4. SSH 접속 방법:
   ```bash
   ssh -i ~/.ssh/gcp_key USERNAME@EXTERNAL_IP
   ```
   - `USERNAME`: Terraform 변수 `gce_ssh_user`에 설정한 사용자 이름
   - `EXTERNAL_IP`: 생성된 VM의 외부 IP 주소

## 사용 방법

```hcl
module "docker_ubuntu" {
  source                = "../../modules/services/docker-ubuntu"
  project_id            = "my-project-id"
  zone                  = "us-central1-a"
  service_account_email = "vm-admin-sa@my-project-id.iam.gserviceaccount.com"

  instance_name    = "docker-host"
  machine_type     = "e2-medium"
  source_image     = "ubuntu-os-cloud/ubuntu-2004-lts"
  subnet_self_link = "projects/my-project-id/regions/us-central1/subnetworks/my-subnet"
  network_self_link = "projects/my-project-id/global/networks/my-vpc"
  disk_size        = 20
  tags             = { "environment" = "dev", "service" = "docker" }

  gce_ssh_user         = "ubuntu"
  gce_ssh_pub_key_file = "${path.cwd}/key/id_rsa.pub"

  firewall_name          = "docker-firewall"
  tcp_udp_firewall_rules = [
    {
      protocol      = "tcp"
      ports         = ["22", "80", "443", "2375", "2376"]
      source_ranges = ["0.0.0.0/0"]
    }
  ]
  icmp_firewall_rules    = [
    {
      source_ranges = ["0.0.0.0/0"]
    }
  ]
}
```

## 모듈 구성 예시

main.tf 파일의 대문자로 표시된 부분을 다음과 같이 수정하세요:

```hcl
# Terraform 설정
terraform {
  required_version = "~> 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.21.0"
    }
  }

  backend "gcs" {
    bucket                      = "my-tf-state-bucket"
    prefix                      = "docker-vm-tfstate/"
    impersonate_service_account = "vm-admin-sa@my-project-id.iam.gserviceaccount.com"
  }
}

# 시작 스크립트 경로 설정
metadata_startup_script = file("${path.cwd}/userdata/user_data.sh")
```

## 시작 스크립트 예시 (userdata/user_data.sh)

```bash
#!/bin/bash

# 시스템 업데이트
apt-get update
apt-get upgrade -y

# Docker 설치 필수 패키지
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Docker 공식 GPG 키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker 저장소 설정
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 엔진 설치
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# 현재 사용자를 docker 그룹에 추가
usermod -aG docker ubuntu

# Docker Compose 설치
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Docker 서비스 시작 및 부팅 시 자동 시작 설정
systemctl start docker
systemctl enable docker

# 테스트 컨테이너 실행
docker run -d -p 80:80 --name webserver nginx
```

## 입력 변수

| 이름 | 설명 | 타입 | 필수 여부 |
|------|-------------|------|----------|
| project_id | 프로젝트 ID | string | 예 |
| zone | 인스턴스를 생성할 영역 | string | 예 |
| service_account_email | 인스턴스에 연결할 서비스 계정 이메일 | string | 예 |
| instance_name | 인스턴스 이름 | string | 예 |
| machine_type | 머신 타입 (예: e2-medium) | string | 예 |
| source_image | 소스 이미지 (Ubuntu 이미지 권장) | string | 예 |
| network_self_link | VPC 네트워크 self_link | string | 예 |
| subnet_self_link | 서브넷 self_link | string | 예 |
| disk_size | 디스크 크기(GB) | number | 예 |
| tags | 인스턴스 태그 | map(string) | 예 |
| gce_ssh_user | SSH 사용자 이름 | string | 예 |
| gce_ssh_pub_key_file | SSH 공개 키 파일 경로 | string | 예 |
| firewall_name | 방화벽 규칙 이름 | string | 예 |
| tcp_udp_firewall_rules | TCP/UDP 방화벽 규칙 목록 | list(object) | 예 |
| icmp_firewall_rules | ICMP 방화벽 규칙 목록 | list(object) | 아니오 |

## 출력 변수

| 이름 | 설명 | 타입 |
|------|-------------|------|
| instance_id | 인스턴스 ID | string |
| instance_name | 인스턴스 이름 | string |
| instance_self_link | 인스턴스 self_link | string |
| instance_external_ip | 인스턴스 외부 IP 주소 | string |