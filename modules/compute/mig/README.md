# 관리형 인스턴스 그룹(MIG) 모듈

이 모듈은 Google Cloud Platform(GCP)에서 리전 관리형 인스턴스 그룹(MIG)과 관련 리소스를 생성하는 Terraform 모듈입니다.

## 주요 기능

- 리전 관리형 인스턴스 그룹 생성
- 인스턴스 템플릿 생성
- 자동 복구 정책 및 업데이트 정책 구성
- 방화벽 규칙 설정 (TCP/UDP 및 ICMP)

## 리소스

이 모듈은 다음과 같은 리소스를 생성합니다:

- `google_compute_region_instance_group_manager`: 리전 관리형 인스턴스 그룹
- `google_compute_instance_template`: 인스턴스 템플릿
- `google_compute_health_check`: 헬스 체크
- `google_compute_firewall`: TCP/UDP 및 ICMP 방화벽 규칙

## 사용 방법

```hcl
module "mig" {
  source = "../../modules/compute/mig"
  
  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_email

  instance_group_manager_name = "my-mig"
  base_instance_name          = "my-instance"
  target_size                 = 2

  instance_template_name = "my-template"
  machine_type           = "e2-medium"
  source_image           = "debian-cloud/debian-11"
  network_self_link      = var.network_self_link
  subnet_self_link       = var.subnet_self_link
  disk_size              = 20
  startup_script         = "${path.cwd}/userdata/user_data.sh"
  tags                   = { "environment" = "dev", "role" = "web" }

  firewall_name          = "my-firewall"
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

  gce_ssh_user         = "user"
  gce_ssh_pub_key_file = "${path.cwd}/key/id_rsa.pub"

  check_interval_sec = 5
  timeout_sec        = 5
  health_check_port  = 80
  initial_delay_sec  = 300
}
```

## 입력 변수

| 이름 | 설명 | 타입 | 필수 여부 |
|------|-------------|------|----------|
| project_id | 프로젝트 ID | string | 예 |
| region | GCP 리전 | string | 예 |
| service_account_email | 인스턴스에 연결할 서비스 계정 이메일 | string | 예 |
| instance_group_manager_name | 인스턴스 그룹 관리자 이름 | string | 예 |
| base_instance_name | 기본 인스턴스 이름 | string | 예 |
| target_size | 인스턴스 그룹 크기 | number | 예 |
| instance_template_name | 인스턴스 템플릿 이름 | string | 예 |
| machine_type | 머신 타입 | string | 예 |
| source_image | 소스 이미지 | string | 예 |
| network_self_link | VPC 네트워크 self_link | string | 예 |
| subnet_self_link | 서브넷 self_link | string | 예 |
| disk_size | 디스크 크기(GB) | number | 예 |
| startup_script | 시작 스크립트 경로 | string | 예 |
| tags | 인스턴스 태그 | map(string) | 예 |
| firewall_name | 방화벽 규칙 이름 | string | 예 |
| tcp_udp_firewall_rules | TCP/UDP 방화벽 규칙 목록 | list(object) | 예 |
| icmp_firewall_rules | ICMP 방화벽 규칙 목록 | list(object) | 아니오 |
| gce_ssh_user | SSH 사용자 이름 | string | 예 |
| gce_ssh_pub_key_file | SSH 공개 키 파일 경로 | string | 예 |
| check_interval_sec | 헬스 체크 간격(초) | number | 예 |
| timeout_sec | 헬스 체크 타임아웃(초) | number | 예 |
| health_check_port | 헬스 체크 포트 | number | 예 |
| initial_delay_sec | 초기 지연 시간(초) | number | 예 |

## 출력 변수

| 이름 | 설명 | 타입 |
|------|-------------|------|
| instance_group | 인스턴스 그룹 정보 | object |
| instance_group_manager_self_link | 인스턴스 그룹 관리자 self_link | string |