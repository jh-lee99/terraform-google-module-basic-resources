# Terraform 설정 블록
# Terraform의 버전과 필요한 provider를 정의
terraform {
  required_version = "~> 1.10" # 필요한 Terraform 버전

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.21.0" # 필요한 Google provider 버전
    }
  }
}

# Backend Service 생성
# MIG(Managed Instance Group)를 백엔드로 지정합니다.
resource "google_compute_region_backend_service" "default" {
  name                  = var.backend_service_name
  project               = var.project_id
  region                = var.region
  protocol              = "HTTP"                                          # 백엔드와 통신할 프로토콜 설정, http로 설정하여 http 기반의 통신을 하도록 설정
  load_balancing_scheme = "EXTERNAL_MANAGED"                              # external load balancing
  health_checks         = [google_compute_region_health_check.default.id] # 헬스체크 연결

  backend {
    group           = var.mig_self_link # 백엔드 그룹 연결
    capacity_scaler = 1.0               # 백엔드 인스턴스 그룹의 용량 비율 설정
    balancing_mode  = "UTILIZATION"     # 부하 분산 방식
    max_utilization = 0.8               # 최대 사용률 설정
  }
}

# Backend Service에 대한 Health Check 생성
# 백엔드(MIG)의 상태를 점검합니다.
resource "google_compute_region_health_check" "default" {
  name    = "${var.backend_service_name}-health-check" # 헬스체크 이름
  project = var.project_id
  region  = var.region # 리전 헬스체크이므로 리전을 지정해 줘야 합니다.
  http_health_check {
    port         = var.health_check_port # 헬스체크에서 요청을 보낼 포트 지정. 헬스체크 포트는 해당 포트에 정상적으로 응답이 오는지 확인
    request_path = "/"                   # 요청을 보낼 경로 설정
  }
  check_interval_sec = var.check_interval_sec # 헬스체크 요청 간격 (초)
  timeout_sec        = var.timeout_sec        # 헬스체크 타임아웃 시간 (초)
}

# URL Map 생성
# 들어오는 요청을 백엔드 서비스로 라우팅하는 규칙을 정의합니다.
resource "google_compute_region_url_map" "default" {
  name            = "${var.loadbalancer_name}-url-map" # url map 이름
  project         = var.project_id
  region          = var.region                                       # 리전 url map이므로, 지역을 지정해 줘야 합니다.
  description     = "a description of the load balancer"             # 설명
  default_service = google_compute_region_backend_service.default.id # 모든 서비스는 백엔드 서비스로 향하도록 설정. 리전 리소스
  # host 규칙 설정
  # host 규칙은 호스트이름에 따라 요청을 특정 백엔드 서비스로 전달하도록 한다.
  host_rule {
    hosts        = ["*"]      # 모든 호스트에 적용
    path_matcher = "allpaths" # 모든 경로에 적용
  }

  # path matcher 정의. url map의 path matcher 는 path에 따라 특정 백엔드 서비스로 라우팅한다.
  # 모든 path의 요청에 대해 google_compute_region_backend_service.default 로 요청을 전달
  path_matcher {
    name            = "allpaths" # path matcher 이름
    default_service = google_compute_region_backend_service.default.id
    # path rule 정의
    path_rule {
      paths   = ["/*"]                                           # 모든 경로
      service = google_compute_region_backend_service.default.id # path rule에 해당하는 요청을 백엔드로 전달
    }
  }
}

# Target HTTP Proxy 생성
# HTTP 요청을 URL Map으로 전달하는 프록시를 정의합니다.
resource "google_compute_region_target_http_proxy" "http_default" {
  name    = "${var.loadbalancer_name}-http-target-proxy" # target proxy 이름
  project = var.project_id
  region  = var.region                               # 리전 target proxy이므로, 리전을 지정해 줘야 합니다.
  url_map = google_compute_region_url_map.default.id # url map 연결
}

# Target HTTPS Proxy 생성
# HTTPS 요청을 URL Map으로 전달하는 프록시를 정의합니다.
# https를 사용하는 경우에만 생성
resource "google_compute_region_target_https_proxy" "https_default" {
  count   = var.create_https ? 1 : 0                      # https 를 사용할 경우 생성
  name    = "${var.loadbalancer_name}-https-target-proxy" # target proxy 이름
  project = var.project_id
  region  = var.region                               # 리전 target proxy이므로, 리전을 지정해 줘야 합니다.
  url_map = google_compute_region_url_map.default.id # url map 연결
  # 인증서 연결. 인증서가 하나 이상 존재해야 한다.
  # google_compute_managed_ssl_certificate.default[*].id와 같이 설정하면 모든 인증서를 사용할 수 있다.
  # https를 사용하는 경우만 인증서를 연결
  ssl_certificates = var.create_https ? google_compute_managed_ssl_certificate.default[*].id : null
}

# Forwarding Rule (HTTP) 생성
# 들어오는 HTTP 요청을 Target HTTP Proxy로 전달하는 포워딩 규칙을 정의합니다.
resource "google_compute_forwarding_rule" "http_default" {
  name                  = "${var.loadbalancer_name}-http-forwarding-rule" # forwarding rule 이름
  project               = var.project_id
  region                = var.region                                              # 리전 포워딩 룰 이므로, 지역을 설정
  target                = google_compute_region_target_http_proxy.http_default.id # target proxy 연결
  network               = var.network_self_link
  port_range            = "80"               # 포트 범위
  ip_protocol           = "TCP"              # 프로토콜
  load_balancing_scheme = "EXTERNAL_MANAGED" # 외부 로드밸런싱
  # load balancer의 ip주소 지정. 변수로 받을 수 있음
  ip_address = google_compute_address.load_balancer_ip.id
}

# Forwarding Rule (HTTPS) 생성
# 들어오는 HTTPS 요청을 Target HTTPS Proxy로 전달하는 포워딩 규칙을 정의합니다.
# https를 사용하는 경우에만 생성
resource "google_compute_forwarding_rule" "https_default" {
  count                 = var.create_https ? 1 : 0                         # https 를 사용할 경우 생성
  name                  = "${var.loadbalancer_name}-https-forwarding-rule" # forwarding rule 이름
  project               = var.project_id
  region                = var.region                                                   # 리전 포워딩 룰 이므로, 지역을 설정
  target                = google_compute_region_target_https_proxy.https_default[0].id # target proxy 연결
  network               = var.network_self_link
  port_range            = "443"              # 포트 범위
  ip_protocol           = "TCP"              # 프로토콜
  load_balancing_scheme = "EXTERNAL_MANAGED" # 외부 로드밸런싱
  # load balancer의 ip주소 지정. 변수로 받을 수 있음
  ip_address = google_compute_address.load_balancer_ip.id
}

# ssl certificate를 생성한다.
# ssl certificate는 load balancer의 https에서 사용된다.
resource "google_compute_managed_ssl_certificate" "default" {
  count   = var.create_https && length(var.domain_name) > 0 ? 1 : 0 # https를 사용하고, var.domain_name에 값이 있는 경우만 생성
  project = var.project_id
  name    = "${var.loadbalancer_name}-certificate" # ssl certificate 이름
  managed {
    # domain_name은 로드밸런서에 연결할 도메인
    domains = var.domain_name
  }
}

# 로드밸런서의 global ip주소를 생성한다. 
resource "google_compute_address" "load_balancer_ip" {
  project      = var.project_id
  name         = "${var.loadbalancer_name}-ip" # ip이름
  address_type = "EXTERNAL"                    # 외부 ip주소
  ip_version   = "IPV4"                        # ip version
}
