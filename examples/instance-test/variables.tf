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

variable "disk_size" {
  description = "디스크 크기 (GB)"
  type        = number
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

variable "startup_script" {
  description = "file(\"${path.module}/user_data.sh\")"
  type        = string
}

variable "tags" {
  description = <<-EOT
    인스턴스에 부여할 태그를 정의합니다.

    예시:
    {
      Name        = "ubuntu-instance",
      Environment = "dev"
    }
    EOT

  type = map(string)
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

##############
#  firewall  #
##############
variable "firewall_name" {
  description = "value of firewall name"
  type        = string
}

variable "tcp_udp_firewall_rules" {
  description = <<-EOT
    TCP/UDP 방화벽 규칙을 정의합니다.

    예시:
    ```
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
    ```
    EOT
  type = list(object({
    protocol      = string
    ports         = list(string)
    source_ranges = list(string)
  }))
}

variable "icmp_firewall_rules" {
  description = <<-EOT
    ICMP 방화벽 규칙을 정의합니다.

    예시:
    ```
    [
      {
        protocol      = "icmp",
        source_ranges = ["0.0.0.0/0"]
      }
    ]
    ```
    EOT
  type = list(object({
    protocol      = string
    source_ranges = list(string)
  }))
}
