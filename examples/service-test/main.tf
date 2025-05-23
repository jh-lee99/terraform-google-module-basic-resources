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

data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket                      = "jh-lee-tf-remote-state-bucket"
    prefix                      = "vpc-tfstate/"
    impersonate_service_account = "terraform-sa@jh-lee-tf-project-2025.iam.gserviceaccount.com"
  }
}

module "mig" {
  source = "../../modules/compute/mig"
  providers = {
    google = google
  }

  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_email

  instance_group_manager_name = var.instance_group_manager_name
  base_instance_name          = var.base_instance_name
  target_size                 = var.target_size

  instance_template_name = var.instance_template_name
  machine_type           = var.machine_type
  source_image           = var.source_image
  network_self_link      = data.terraform_remote_state.vpc.outputs.vpc_self_link
  subnet_self_link       = data.terraform_remote_state.vpc.outputs.private_subnet_self_links[0]
  disk_size              = var.disk_size
  startup_script         = "${path.cwd}/userdata/user_data.sh"
  tags                   = var.tags

  firewall_name          = var.firewall_name
  tcp_udp_firewall_rules = var.tcp_udp_firewall_rules
  icmp_firewall_rules    = var.icmp_firewall_rules

  gce_ssh_user         = var.gce_ssh_user
  gce_ssh_pub_key_file = "${path.cwd}/key/id_rsa.pub"

  check_interval_sec = var.check_interval_sec
  timeout_sec        = var.timeout_sec
  health_check_port  = var.health_check_port
  initial_delay_sec  = var.initial_delay_sec
}

module "region_lb" {
  depends_on = [module.mig]
  source     = "../../modules/compute/loadbalancer"
  providers = {
    google = google
  }

  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_email

  loadbalancer_name           = var.loadbalancer_name
  backend_service_name        = var.backend_service_name
  network_self_link           = data.terraform_remote_state.vpc.outputs.vpc_self_link
  proxy_only_subnet_self_link = data.terraform_remote_state.vpc.outputs.proxy_only_subnet_self_links

  health_check_port  = var.alb_health_check_port
  check_interval_sec = var.alb_check_interval_sec
  timeout_sec        = var.alb_timeout_sec

  mig_self_link = var.mig_self_link
  domain_name   = var.domain_name
  create_https  = var.create_https
}
