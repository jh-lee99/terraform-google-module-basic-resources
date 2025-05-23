# VPC 테스트 예제

이 예제는 Google Cloud Platform(GCP)에서 VPC 네트워크 모듈을 사용하여 VPC 네트워크와 관련 리소스를 생성하는 방법을 보여줍니다.

## 개요

이 예제는 다음과 같은 리소스를 생성합니다:

- VPC 네트워크
- 프록시 전용 서브넷 (로드 밸런서용)
- 퍼블릭 서브넷 (외부 접근 가능한 리소스용)
- 프라이빗 서브넷 (내부 리소스용)
- Cloud Router 및 Cloud NAT (선택적)

## 사용 방법

1. `terraform.tfvars` 파일을 수정하여 필요한 변수 값을 설정합니다.
2. 다음 명령을 실행하여 Terraform 초기화 및 적용:

```bash
# 백엔드 구성으로 초기화
terraform init -backend-config=backend.hcl

# 계획 확인
terraform plan -var-file="terraform.tfvars"

# 인프라 생성
terraform apply -var-file="terraform.tfvars"
```

## 필수 변수

`terraform.tfvars` 파일에 다음 변수를 설정해야 합니다:

```hcl
project_id            = "your-project-id"
region                = "us-central1"
service_account_email = "terraform-sa@your-project-id.iam.gserviceaccount.com"

vpc_name     = "my-vpc"
vpc_cidr     = "10.0.0.0/16"
routing_mode = "GLOBAL"
mtu          = 1460

proxy_only_subnets_name = "proxy-subnet"
proxy_only_subnets_cidr = "10.0.0.0/24"
public_subnets_name     = "public-subnet"
public_subnets_cidr     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_name    = "private-subnet"
private_subnets_cidr    = ["10.0.3.0/24", "10.0.4.0/24"]

create_nat                         = true
nat_ip_allocate_option             = "AUTO_ONLY"
source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
```

## 백엔드 구성

`backend.hcl` 파일에는 Terraform 상태 파일을 저장하기 위한 GCS 버킷 구성이 포함되어 있습니다:

```hcl
bucket                      = "your-tf-state-bucket"
prefix                      = "vpc-tfstate/"
impersonate_service_account = "terraform-sa@your-project-id.iam.gserviceaccount.com"
```

## 출력 변수

이 예제는 다음과 같은 출력 변수를 제공합니다:

- VPC 네트워크 self_link
- 퍼블릭 서브넷 self_link 목록
- 프라이빗 서브넷 self_link 목록
- 프록시 전용 서브넷 self_link