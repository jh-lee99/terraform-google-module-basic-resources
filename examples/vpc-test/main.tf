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
  backend "gcs" {
    bucket                      = "jh-lee-tf-remote-state-bucket"
    prefix                      = "vpc-tfstate/"
    impersonate_service_account = "terraform-sa@jh-lee-tf-project-2025.iam.gserviceaccount.com"
  }
}

module "network" {
  source                = "../../modules/networking/vpc"
  project_id            = var.project_id
  region                = var.region
  service_account_email = var.service_account_email

  vpc_name     = var.vpc_name
  vpc_cidr     = var.vpc_cidr
  routing_mode = var.routing_mode
  mtu          = var.mtu

  proxy_only_subnets_name = var.proxy_only_subnets_name
  proxy_only_subnets_cidr = var.proxy_only_subnets_cidr
  public_subnets_name     = var.public_subnets_name
  public_subnets_cidr     = var.public_subnets_cidr
  private_subnets_name    = var.private_subnets_name
  private_subnets_cidr    = var.private_subnets_cidr

  create_nat                         = var.create_nat
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
}
