# 컴퓨트 인스턴스 모듈

이 모듈은 Google Cloud Platform(GCP)에서 컴퓨트 인스턴스(VM)와 관련 방화벽 규칙을 생성하는 Terraform 모듈입니다.

## 주요 기능

- 단일 컴퓨트 인스턴스(VM) 생성
- 인스턴스에 대한 방화벽 규칙 설정 (TCP/UDP 및 ICMP)
- SSH 키 설정 및 시작 스크립트 지원

## 리소스

이 모듈은 다음과 같은 리소스를 생성합니다:

- `google_compute_instance`: 컴퓨트 인스턴스(VM)
- `google_compute_firewall`: TCP/UDP 및 ICMP 방화벽 규칙

## 사용 방법

```hcl
module "vm" {
  source                = "../../modules/compute/instance"
  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_email
  zone                  = var.zone

  instance_name     = "my-instance"
  machine_type      = "e2-medium"
  boot_disk_type    = "pd-standard"
  source_image      = "debian-cloud/debian-11"
  network_self_link = var.network_self_link
  subnet_self_link  = var.subnet_self_link
  disk_size         = 20
  startup_script    = "${path.cwd}/userdata/user_data.sh"
  tags              = { "environment" = "dev", "role" = "web" }

  gce_ssh_user         = "user"
  gce_ssh_pub_key_file = "${path.cwd}/key/id_rsa.pub"

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
}
```

## 입력 변수

| 이름 | 설명 | 타입 | 필수 여부 |
|------|-------------|------|----------|
| project_id | 프로젝트 ID | string | 예 |
| region | GCP 리전 | string | 예 |
| service_account_email | 인스턴스에 연결할 서비스 계정 이메일 | string | 예 |
| zone | 인스턴스를 생성할 영역 | string | 예 |
| instance_name | 인스턴스 이름 | string | 예 |
| machine_type | 머신 타입 (예: e2-medium) | string | 예 |
| boot_disk_type | 부팅 디스크 타입 (pd-standard, pd-balanced, pd-ssd) | string | 예 |
| source_image | 소스 이미지 | string | 예 |
| network_self_link | VPC 네트워크 self_link | string | 예 |
| subnet_self_link | 서브넷 self_link | string | 예 |
| disk_size | 디스크 크기(GB) | number | 예 |
| startup_script | 시작 스크립트 경로 | string | 예 |
| tags | 인스턴스 태그 | map(string) | 예 |
| gce_ssh_user | SSH 사용자 이름 | string | 예 |
| gce_ssh_pub_key_file | SSH 공개 키 파일 경로 | string | 예 |
| firewall_name | 방화벽 규칙 이름 | string | 예 |
| tcp_udp_firewall_rules | TCP/UDP 방화벽 규칙 목록 | list(object) | 예 |
| icmp_firewall_rules | ICMP 방화벽 규칙 목록 | list(object) | 아니오 |