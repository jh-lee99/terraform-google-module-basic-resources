# Terraform 설정
terraform {
  required_version = "~> 1.10" # 필요한 Terraform 버전

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.21.0" # 필요한 Google provider 버전
    }
  }

  # terraform init -backend-config=backend.hcl
  # terraform apply -var-file="terraform.tfvars"

  backend "gcs" {
    bucket                      = "jh-lee-tf-remote-state-bucket"
    prefix                      = "vm-tfstate/"
    impersonate_service_account = "tf-vm-admin-sa@jh-lee-tf-project-2025.iam.gserviceaccount.com"
  }
}

module "vm" {
  source                = "../../modules/compute/instance"
  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_email
  zone                  = var.zone

  instance_name     = var.instance_name
  machine_type      = var.machine_type
  boot_disk_type    = var.boot_disk_type
  source_image      = var.source_image
  network_self_link = var.network_self_link
  subnet_self_link  = var.subnet_self_link
  disk_size         = var.disk_size
  startup_script    = "${path.cwd}/userdata/user_data.sh"
  tags              = var.tags

  gce_ssh_user         = var.gce_ssh_user
  gce_ssh_pub_key_file = "${path.cwd}/key/id_rsa.pub"

  firewall_name          = var.firewall_name
  tcp_udp_firewall_rules = var.tcp_udp_firewall_rules
  icmp_firewall_rules    = var.icmp_firewall_rules
}
