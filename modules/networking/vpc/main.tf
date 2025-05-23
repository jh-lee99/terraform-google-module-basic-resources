# Terraform 설정
terraform {
  required_version = "~> 1.10" # 필요한 Terraform 버전

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.21.0" # 필요한 Google provider 버전
    }
  }
}

# VPC 네트워크 생성
resource "google_compute_network" "vpc" {
  project                 = var.project_id   # 프로젝트 ID
  name                    = var.vpc_name     # VPC 네트워크 이름
  auto_create_subnetworks = false            # 자동 서브넷 생성 비활성화
  mtu                     = var.mtu          # MTU (기본값 1460)
  routing_mode            = var.routing_mode # 라우팅 모드 (REGIONAL 또는 GLOBAL)
}

resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "${var.proxy_only_subnets_name}-1"
  ip_cidr_range = var.proxy_only_subnets_cidr # 사용하지 않는 CIDR 범위 사용
  region        = var.region
  network       = google_compute_network.vpc.self_link # VPC 네트워크 연결
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# Public Subnet 생성
resource "google_compute_subnetwork" "public" {
  count         = length(var.public_subnets_cidr)                 # count 개수의 서브넷 생성
  project       = var.project_id                                  # 프로젝트 ID
  name          = "${var.public_subnets_name}-${count.index + 1}" # 서브넷 이름 (public-subnet-1, public-subnet-2)
  ip_cidr_range = var.public_subnets_cidr[count.index]            # VPC CIDR 블록에서 서브넷 CIDR 할당
  region        = var.region                                      # 리전
  network       = google_compute_network.vpc.self_link            # VPC 네트워크 연결
}

# Private Subnet 생성
resource "google_compute_subnetwork" "private" {
  count         = length(var.private_subnets_cidr)                 # count 개수의 서브넷 생성
  project       = var.project_id                                   # 프로젝트 ID
  name          = "${var.private_subnets_name}-${count.index + 1}" # 서브넷 이름 (private-subnet-1, private-subnet-2)
  ip_cidr_range = var.private_subnets_cidr[count.index]            # VPC CIDR 블록에서 서브넷 CIDR 할당 (public subnet과 겹치지 않게)
  region        = var.region                                       # 리전
  network       = google_compute_network.vpc.self_link             # VPC 네트워크 연결
}

# Cloud Router 생성
resource "google_compute_router" "router" {
  count   = var.create_nat ? 1 : 0
  project = var.project_id
  name    = var.create_nat ? "${var.vpc_name}-cloud-router" : null # VPC 이름 기반으로 Router 이름 설정, create_nat가 false일 경우 null
  region  = var.region
  # cloud router를 해당 네트워크에 위치시킴
  network = google_compute_network.vpc.self_link
  # bgp {
  #   asn = 64514 # ASN (필요에 따라 변경)
  # }
}

# Cloud NAT 생성
resource "google_compute_router_nat" "nat" {
  count                              = var.create_nat ? 1 : 0 # create_nat 변수에 따라 NAT 생성
  project                            = var.project_id
  name                               = var.create_nat ? "${var.vpc_name}-cloud-nat" : null # create_nat가 false일 경우 null
  router                             = google_compute_router.router[0].name                # 0번째 router 사용
  region                             = google_compute_router.router[0].region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
  depends_on                         = [google_compute_router.router] # Router 생성 후 NAT 생성
}
