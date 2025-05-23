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

variable "zone" {
  description = "asia-northeast3-[a,b,c]"
  type        = string
}

##############
#  instance  #
##############
variable "instance_name" {
  description = "인스턴스 이름"
  type        = string
}

variable "machine_type" {
  description = "머신 타입"
  type        = string
}

variable "boot_disk_type" {
  description = "pd-standard, pd-ssd or pd-balanced"
  type        = string
}

variable "source_image" {
  description = "Ubuntu 이미지"
  type        = string
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
}

variable "startup_script" {
  description = "./userdata/user_data.sh"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = <<-EOT
  {
    Name        = "ubuntu-instance",
    Environment = "dev"
  }
  EOT
}

##############
#  firewall  #
##############
variable "firewall_name" {
  description = "default-firewall"
}

# icmp 와 tcp/udp 규칙을 분리하여 변수 설정.
variable "tcp_udp_firewall_rules" {
  type = list(object({
    protocol      = string
    ports         = list(string)
    source_ranges = list(string)
  }))
  description = <<-EOT
  [
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
  EOT
}

variable "icmp_firewall_rules" {
  type = list(object({
    protocol      = string
    source_ranges = list(string)
  }))
  description = <<-EOT
  [
    {
      protocol      = "icmp",
      source_ranges = ["0.0.0.0/0"]
    }
  ]
  EOT
}

##########
#  user  #
##########
variable "gce_ssh_user" {
  type        = string
  description = "접근할 유저"
}

variable "gce_ssh_pub_key_file" {
  type        = string
  description = "공개키 파일 위치"
}
