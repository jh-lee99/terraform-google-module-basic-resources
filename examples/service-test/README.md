# 서비스 테스트 예제

이 예제는 Google Cloud Platform(GCP)에서 관리형 인스턴스 그룹(MIG)과 로드 밸런서를 사용하여 확장 가능한 서비스를 구축하는 방법을 보여줍니다.

## 개요

이 예제는 다음과 같은 리소스를 생성합니다:

- 관리형 인스턴스 그룹(MIG)
  - 인스턴스 템플릿
  - 자동 복구 정책
  - 헬스 체크
  - 방화벽 규칙
- 리전 외부 애플리케이션 로드 밸런서
  - 백엔드 서비스
  - URL 맵
  - HTTP 및 HTTPS(선택적) 프록시
  - 포워딩 규칙
  - SSL 인증서(HTTPS 사용 시)

## 사용 방법

1. `key` 디렉토리에 SSH 공개 키 파일(`id_rsa.pub`)을 준비합니다.
2. `userdata` 디렉토리에 시작 스크립트(`user_data.sh`)를 준비합니다.
3. `terraform.tfvars` 파일을 수정하여 필요한 변수 값을 설정합니다.
4. 다음 명령을 실행하여 Terraform 초기화 및 적용:

```bash
# 백엔드 구성으로 초기화
terraform init -backend-config=backend.hcl

# 계획 확인
terraform plan -var-file="terraform.tfvars"

# 인프라 생성
terraform apply -var-file="terraform.tfvars"
```

## 디렉토리 구조

```
service-test/
├── key/
│   ├── gcp.pem             # GCP 인증서 파일(선택적)
│   └── id_rsa.pub          # SSH 공개 키 파일
├── userdata/
│   └── user_data.sh        # 인스턴스 시작 스크립트
├── .terraform.lock.hcl     # Terraform 잠금 파일
├── backend.hcl             # 백엔드 구성
├── main.tf                 # 주 Terraform 구성 파일
├── output.tf               # 출력 변수 정의
├── providers.tf            # 공급자 구성
├── terraform.tfvars        # 변수 값 설정
└── variables.tf            # 변수 정의
```

## 원격 상태 참조

이 예제는 VPC 네트워크 구성을 위해 원격 상태를 참조합니다:

```hcl
data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket                      = "jh-lee-tf-remote-state-bucket"
    prefix                      = "vpc-tfstate/"
    impersonate_service_account = "terraform-sa@jh-lee-tf-project-2025.iam.gserviceaccount.com"
  }
}
```

## 필수 변수

`terraform.tfvars` 파일에 다음 변수를 설정해야 합니다:

```hcl
project_id            = "your-project-id"
region                = "us-central1"
service_account_email = "tf-vm-admin-sa@your-project-id.iam.gserviceaccount.com"

# MIG 변수
instance_group_manager_name = "test-mig"
base_instance_name          = "test-instance"
target_size                 = 2
instance_template_name      = "test-template"
machine_type                = "e2-medium"
source_image                = "debian-cloud/debian-11"
disk_size                   = 20
tags                        = { "environment" = "test", "service" = "web" }

# 방화벽 변수
firewall_name          = "test-firewall"
tcp_udp_firewall_rules = [
  {
    protocol      = "tcp"
    ports         = ["22", "80", "443"]
    source_ranges = ["0.0.0.0/0"]
  }
]

# SSH 변수
gce_ssh_user = "user"

# 헬스 체크 변수
check_interval_sec = 5
timeout_sec        = 5
health_check_port  = 80
initial_delay_sec  = 300

# 로드 밸런서 변수
loadbalancer_name    = "test-lb"
backend_service_name = "test-backend"
domain_name          = ["example.com"]
create_https         = true

# ALB 헬스 체크 변수
alb_health_check_port  = 80
alb_check_interval_sec = 5
alb_timeout_sec        = 5
```

## 백엔드 구성

`backend.hcl` 파일에는 Terraform 상태 파일을 저장하기 위한 GCS 버킷 구성이 포함되어 있습니다:

```hcl
bucket                      = "your-tf-state-bucket"
prefix                      = "vm-tfstate/"
impersonate_service_account = "tf-vm-admin-sa@your-project-id.iam.gserviceaccount.com"
```

## 출력 변수

이 예제는 다음과 같은 출력 변수를 제공합니다:

- 인스턴스 그룹 정보
- 인스턴스 그룹 관리자 self_link
- 로드 밸런서 IP 주소
- HTTP 및 HTTPS 포워딩 규칙