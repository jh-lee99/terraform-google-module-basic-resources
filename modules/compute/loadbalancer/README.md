# 로드 밸런서 모듈

이 모듈은 Google Cloud Platform(GCP)에서 리전 외부 애플리케이션 로드 밸런서를 생성하는 Terraform 모듈입니다.

## 주요 기능

- 리전 외부 애플리케이션 로드 밸런서 생성
- HTTP 및 HTTPS(선택적) 지원
- 백엔드 서비스 및 헬스 체크 구성
- SSL 인증서 관리(HTTPS 사용 시)

## 리소스

이 모듈은 다음과 같은 리소스를 생성합니다:

- `google_compute_region_backend_service`: 백엔드 서비스
- `google_compute_region_health_check`: 헬스 체크
- `google_compute_region_url_map`: URL 맵
- `google_compute_region_target_http_proxy`: HTTP 프록시
- `google_compute_region_target_https_proxy`: HTTPS 프록시(선택적)
- `google_compute_forwarding_rule`: HTTP 및 HTTPS 포워딩 규칙
- `google_compute_managed_ssl_certificate`: SSL 인증서(HTTPS 사용 시)
- `google_compute_address`: 로드 밸런서 IP 주소

## 사용 방법

```hcl
module "region_lb" {
  source     = "../../modules/compute/loadbalancer"
  
  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_email

  loadbalancer_name           = "my-loadbalancer"
  backend_service_name        = "my-backend-service"
  network_self_link           = var.network_self_link
  proxy_only_subnet_self_link = var.proxy_only_subnet_self_link

  health_check_port  = 80
  check_interval_sec = 5
  timeout_sec        = 5

  mig_self_link = var.mig_self_link
  domain_name   = ["example.com"]
  create_https  = true
}
```

## 입력 변수

| 이름 | 설명 | 타입 | 필수 여부 |
|------|-------------|------|----------|
| project_id | 프로젝트 ID | string | 예 |
| region | GCP 리전 | string | 예 |
| service_account_email | 서비스 계정 이메일 | string | 예 |
| loadbalancer_name | 로드 밸런서 이름 | string | 예 |
| backend_service_name | 백엔드 서비스 이름 | string | 예 |
| network_self_link | VPC 네트워크 self_link | string | 예 |
| proxy_only_subnet_self_link | 프록시 전용 서브넷 self_link | string | 예 |
| health_check_port | 헬스 체크 포트 | number | 예 |
| check_interval_sec | 헬스 체크 간격(초) | number | 예 |
| timeout_sec | 헬스 체크 타임아웃(초) | number | 예 |
| mig_self_link | 관리형 인스턴스 그룹 self_link | string | 예 |
| domain_name | 도메인 이름 목록(HTTPS 사용 시) | list(string) | 아니오 |
| create_https | HTTPS 사용 여부 | bool | 아니오 |

## 출력 변수

| 이름 | 설명 | 타입 |
|------|-------------|------|
| load_balancer_ip | 로드 밸런서 IP 주소 | string |
| http_forwarding_rule | HTTP 포워딩 규칙 | string |
| https_forwarding_rule | HTTPS 포워딩 규칙(HTTPS 사용 시) | string |