# 인스턴스 테스트 예제

이 예제는 Google Cloud Platform(GCP)에서 컴퓨트 인스턴스 모듈을 사용하여 가상 머신(VM)과 관련 리소스를 생성하는 방법을 보여줍니다.

## 개요

이 예제는 다음과 같은 리소스를 생성합니다:

- 컴퓨트 인스턴스(VM)
- 인스턴스에 대한 방화벽 규칙 (TCP/UDP 및 ICMP)
- SSH 키 설정 및 시작 스크립트 적용

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
instance-test/
├── key/
│   └── id_rsa.pub          # SSH 공개 키 파일
├── userdata/
│   └── user_data.sh        # 인스턴스 시작 스크립트
├── main.tf                 # 주 Terraform 구성 파일
├── output.tf               # 출력 변수 정의
├── providers.tf            # 공급자 구성
├── terraform.tfvars        # 변수 값 설정
└── variables.tf            # 변수 정의
```

## 필수 변수

`terraform.tfvars` 파일에 다음 변수를 설정해야 합니다:

```hcl
project_id            = "your-project-id"
region                = "us-central1"
zone                  = "us-central1-a"
service_account_email = "tf-vm-admin-sa@your-project-id.iam.gserviceaccount.com"

instance_name     = "test-instance"
machine_type      = "e2-medium"
boot_disk_type    = "pd-standard"
source_image      = "debian-cloud/debian-11"
network_self_link = "projects/your-project-id/global/networks/your-vpc"
subnet_self_link  = "projects/your-project-id/regions/us-central1/subnetworks/your-subnet"
disk_size         = 20
tags              = { "environment" = "test", "role" = "web" }

gce_ssh_user = "user"

firewall_name          = "test-firewall"
tcp_udp_firewall_rules = [
  {
    protocol      = "tcp"
    ports         = ["22", "80", "443"]
    source_ranges = ["0.0.0.0/0"]
  }
]
icmp_firewall_rules    = [
  {
    source_ranges = ["0.0.0.0/0"]
  }
]
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

- 인스턴스 ID
- 인스턴스 이름
- 인스턴스 self_link
- 인스턴스 외부 IP 주소