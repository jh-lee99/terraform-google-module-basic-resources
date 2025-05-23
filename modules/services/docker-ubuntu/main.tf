# Terraform 설정
terraform {
  required_version = "~> 1.10" # 필요한 Terraform 버전

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.21.0" # 필요한 Google provider 버전
    }
  }

  backend "gcs" {
    bucket                      = "YOUR_BUCKET_NAME"
    prefix                      = "BUCKET_PREFIX/"
    impersonate_service_account = "YOUR_VM_ADMIN_SA_EMAIL"
  }
}

resource "google_compute_instance" "default" {
  project      = var.project_id
  zone         = var.zone
  name         = var.instance_name
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.source_image
      size  = var.disk_size
      type  = "pd-standard" # 또는 pd-balanced, pd-ssd
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
    # public IP 자동 할당
    access_config {}
  }

  # 서비스 계정 연결
  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("LOCATION_OF_STARTUP_SCRIPT")

  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }


  tags = [for k, v in var.tags : v]
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
