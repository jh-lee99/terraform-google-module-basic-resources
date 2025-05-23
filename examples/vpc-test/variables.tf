# variables.tf
variable "project_id" {
  description = "ID of the project in scope"
  type        = string
}

variable "region" {
  description = "GCP default region"
  type        = string
}

variable "service_account_email" {
  description = "email adress of the service account used for terraform"
  type        = string
}

variable "vpc_name" {
  description = "VPC 네트워크 이름"
  type        = string
}

variable "mtu" {
  description = "MTU (기본값 1460)"
  type        = number
  default     = 1460
}

variable "routing_mode" {
  description = "value"
  type        = string
  default     = "REGIONAL"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "proxy_only_subnets_name" {
  description = "proxy only subnet name"
  type        = string
}

variable "proxy_only_subnets_cidr" {
  description = "10.0.0.0/24"
  type        = string
}

variable "public_subnets_name" {
  description = "public subnet name"
  type        = string
  default     = "public-subnet"
}

variable "public_subnets_cidr" {
  description = "[\"10.0.1.0/24\", \"10.0.2.0/24\"]"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_name" {
  description = "private subnet name"
  type        = string
  default     = "private-subnet"
}

variable "private_subnets_cidr" {
  description = "[\"10.0.3.0/24\", \"10.0.4.0/24\"]"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "create_nat" {
  description = "Whether to create Cloud NAT. Defaults to true."
  type        = bool
  default     = true
}

variable "nat_ip_allocate_option" {
  description = "Possible values: [\"MANUAL_ONLY\", \"AUTO_ONLY\"]"
  default     = "AUTO_ONLY"
  type        = string
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Possible values: [\"ALL_SUBNETWORKS_ALL_IP_RANGES\", \"ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES\", \"LIST_OF_SUBNETWORKS\"]"
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  type        = string
}

# variable "router_asn" {
#   type        = number
#   description = "Cloud Router ASN"
#   default     = 64514
# }
