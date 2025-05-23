############
#  common  #
############
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

#################
# Load Balancer #
#################
variable "loadbalancer_name" {
  description = "로드 밸런서 이름"
  type        = string
}

# Backend Service 관련 변수
variable "backend_service_name" {
  description = "백엔드 서비스 이름"
  type        = string
}

variable "network_self_link" {
  description = "value of network self link"
  type        = string
}

variable "proxy_only_subnet_self_link" {
  description = "value of proxy only subnet self link"
  type        = string
}

# Health Check 관련 변수
variable "health_check_port" {
  description = "헬스 체크 포트"
  type        = number
}

variable "check_interval_sec" {
  description = "헬스 체크 간격 (초)"
  type        = number
}

variable "timeout_sec" {
  description = "헬스 체크 타임아웃 (초)"
  type        = number
}

# MIG 관련 변수
variable "mig_self_link" {
  description = "MIG self_link"
  type        = string
}

# domain name
variable "domain_name" {
  description = "domain name for ssl"
  type        = list(string)
}

# create https variable
variable "create_https" {
  description = "Whether to create https for loadbalancer. Defaults to false."
  type        = bool
}
