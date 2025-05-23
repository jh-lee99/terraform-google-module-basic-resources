# VPC 네트워크 모듈

이 모듈은 Google Cloud Platform(GCP)에서 VPC 네트워크 및 관련 리소스를 생성하는 Terraform 모듈입니다.

## 주요 기능

- VPC 네트워크 생성
- 프록시 전용 서브넷 생성 (로드 밸런서용)
- 퍼블릭 서브넷 생성 (외부 접근 가능한 리소스용)
- 프라이빗 서브넷 생성 (내부 리소스용)
- Cloud Router 및 Cloud NAT 구성 (선택적)

## 리소스

이 모듈은 다음과 같은 리소스를 생성합니다:

- `google_compute_network`: VPC 네트워크
- `google_compute_subnetwork`: 프록시 전용, 퍼블릭, 프라이빗 서브넷
- `google_compute_router`: Cloud Router (create_nat이 true인 경우)
- `google_compute_router_nat`: Cloud NAT (create_nat이 true인 경우)

## 사용 방법

```hcl
module "network" {
  source                = "../../modules/networking/vpc"
  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_email

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
}
```

## 입력 변수

| 이름 | 설명 | 타입 | 필수 여부 |
|------|-------------|------|----------|
| project_id | 프로젝트 ID | string | 예 |
| region | GCP 리전 | string | 예 |
| service_account_email | Terraform 실행에 사용되는 서비스 계정 이메일 | string | 예 |
| vpc_name | VPC 네트워크 이름 | string | 예 |
| vpc_cidr | VPC CIDR 블록 | string | 예 |
| routing_mode | 라우팅 모드 (REGIONAL 또는 GLOBAL) | string | 예 |
| mtu | MTU 값 | number | 아니오 (기본값: 1460) |
| proxy_only_subnets_name | 프록시 전용 서브넷 이름 | string | 예 |
| proxy_only_subnets_cidr | 프록시 전용 서브넷 CIDR | string | 예 |
| public_subnets_name | 퍼블릭 서브넷 이름 | string | 예 |
| public_subnets_cidr | 퍼블릭 서브넷 CIDR 목록 | list(string) | 예 |
| private_subnets_name | 프라이빗 서브넷 이름 | string | 예 |
| private_subnets_cidr | 프라이빗 서브넷 CIDR 목록 | list(string) | 예 |
| create_nat | Cloud NAT 생성 여부 | bool | 예 |
| nat_ip_allocate_option | NAT IP 할당 옵션 | string | 예 (create_nat이 true인 경우) |
| source_subnetwork_ip_ranges_to_nat | NAT에 사용할 서브넷 IP 범위 | string | 예 (create_nat이 true인 경우) |
