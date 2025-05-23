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

# 리전의 zone 리스트를 가져오는 data 블럭 추가
data "google_compute_zones" "available" {
  region = var.region
}

# 리전 MIG(Managed Instance Group) 리소스 생성
resource "google_compute_region_instance_group_manager" "default" {
  name               = var.instance_group_manager_name
  base_instance_name = var.base_instance_name
  project            = var.project_id
  region             = var.region
  # MIG의 인스턴스들을 분산시킬 영역(zone)을 지정. 리전 MIG이므로 여러 영역에 걸쳐 배포가능
  distribution_policy_zones      = data.google_compute_zones.available.names
  list_managed_instances_results = "PAGELESS"

  target_size = var.target_size

  # MIG의 버전 설정
  version {
    # name              = var.instance_group_manager_name
    instance_template = google_compute_instance_template.default.id
  }

  # 자동 복구 정책 설정
  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = var.initial_delay_sec # 헬스 체크 시작 전 초기 지연 시간 (초)
  }

  update_policy {
    type                         = "OPPORTUNISTIC"
    instance_redistribution_type = "NONE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 0 # 업데이트 중 사용 가능한 인스턴스 최대 수
    max_unavailable_fixed        = 3 # 업데이트 중 사용 불가능한 인스턴스 최대 수
    replacement_method           = "RECREATE"
  }
}

# instance template 리소스 생성
resource "google_compute_instance_template" "default" {
  name_prefix  = var.instance_template_name
  project      = var.project_id
  machine_type = var.machine_type
  lifecycle {
    create_before_destroy = true
  }

  # instance template의 디스크 설정
  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
    type         = "PERSISTENT" # "SCRATCH" or "PERSISTENT"
  }

  # instance template의 네트워크 인터페이스 설정
  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnet_self_link
    # public ip 할당, 만약 필요없다면 access_config 전체 주석처리.
    # access_config {
    #   nat_ip = "EXTERNAL" 
    # }
  }

  # instance template의 서비스 계정 설정
  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  # instance template의 메타데이터 설정 (시작 스크립트)
  metadata_startup_script = file(var.startup_script)

  # instance template의 메타데이터 설정 (SSH 키)
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  tags = [for k, v in var.tags : v]
}

# MIG에 대한 헬스 체크 설정
resource "google_compute_health_check" "default" {
  name               = "${var.instance_group_manager_name}-health-check"
  check_interval_sec = var.check_interval_sec # 헬스 체크 간격 (초)
  timeout_sec        = var.timeout_sec        # 타임아웃 (초)
  http_health_check {
    port = var.health_check_port # 헬스 체크 포트
  }
}

resource "google_compute_firewall" "tcp_udp_default" {
  project     = var.project_id
  network     = var.network_self_link
  name        = "${var.firewall_name}-tcp-udp"
  target_tags = [for k, v in var.tags : v]

  dynamic "allow" {
    for_each = var.tcp_udp_firewall_rules
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  source_ranges = flatten([for rule in var.tcp_udp_firewall_rules : rule.source_ranges])
}

# icmp 규칙
resource "google_compute_firewall" "icmp_default" {
  count       = length(var.icmp_firewall_rules) > 0 ? 1 : 0 # icmp_firewall_rules 이 있을 경우만 생성
  project     = var.project_id
  network     = var.network_self_link
  name        = "${var.firewall_name}-icmp"
  target_tags = [for k, v in var.tags : v]

  allow {
    protocol = "icmp"
  }

  source_ranges = flatten([for rule in var.icmp_firewall_rules : rule.source_ranges])
}
