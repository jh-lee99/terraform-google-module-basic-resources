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
  default     = "asia-northeast3"
}

variable "service_account_email" {
  description = "email adress of the service account used for terraform"
  type        = string
}

variable "zone" {
  type        = string
  description = "asia-northeast3-[a,b,c]"
}

##############
#  instance  #
##############
variable "instance_name" {
  description = "인스턴스 이름"
  type        = string
  default     = "docker-ubuntu"
}

variable "machine_type" {
  description = "머신 타입"
  type        = string
  default     = "n2-standard-2" // GCP에서 t3.micro에 해당하는 머신 타입.  적절한 머신 타입 선택 필요.
}

variable "source_image" {
  description = "Ubuntu 이미지"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts" # 최신 LTS 버전 사용 권장. 필요에 따라 수정.
}

variable "network_self_link" {
  description = "VPC 네트워크 self link"
  type        = string
}

variable "subnet_self_link" {
  description = "서브넷 self link"
  type        = string
}

variable "disk_size" {
  description = "디스크 크기 (GB)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "태그"
  type        = map(string)
  default = {
    Name        = "ubuntu-instance",
    Environment = "dev"
  }
}

##########
#  user  #
##########
variable "gce_ssh_user" {
  type        = string
  description = "접근할 유저"
  default     = "ubuntu" # 최신 LTS 버전 사용 권장. 필요에 따라 수정.
}

variable "gce_ssh_pub_key_file" {
  type        = string
  description = "공개키 파일 위치"
}

##############
#  firewall  #
##############
variable "firewall_name" {
  default = "default-firewall"
}

# icmp 와 tcp/udp 규칙을 분리하여 변수 설정.
variable "tcp_udp_firewall_rules" {
  type = list(object({
    protocol      = string
    ports         = list(string)
    source_ranges = list(string)
  }))
  default = [
    {
      protocol      = "tcp",
      ports         = ["22", "80", "443"],
      source_ranges = ["0.0.0.0/0"]
    },
    {
      protocol      = "udp",
      ports         = ["53"],
      source_ranges = ["0.0.0.0/0"]
    },
  ]
}

variable "icmp_firewall_rules" {
  type = list(object({
    protocol      = string
    source_ranges = list(string)
  }))
  default = [
    {
      protocol      = "icmp",
      source_ranges = ["0.0.0.0/0"]
    }
  ]
}
