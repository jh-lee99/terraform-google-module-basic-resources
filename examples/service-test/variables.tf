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

############
#  remote  #
############
variable "remote_state_bucket_name" {

}

###########
#   MIG   #
###########
variable "instance_group_manager_name" {
  description = "MIG 이름"
  type        = string
}

variable "base_instance_name" {
  description = "VM base name"
  type        = string
}

variable "target_size" {
  description = "value of target size"
  type        = number
}

#######################
#  instance template  #
#######################
variable "instance_template_name" {
  description = "instance template name"
  type        = string
}

variable "machine_type" {
  description = "vm machine type"
  type        = string
}

variable "source_image" {
  description = "source image for vm"
  type        = string
}

# variable "network_self_link" {
#   description = "network self link"
#   type        = string
# }

# variable "subnet_self_link" {
#   description = "subnet self link"
#   type        = string
# }

variable "disk_size" {
  description = "Disk size"
  type        = number
}

# variable "startup_script" {
#   description = "./userdata/user_data.sh"
#   type        = string
# }

variable "tags" {
  description = <<-EOT
    인스턴스에 부여할 태그를 정의합니다.

    예시: { name = "ubuntu-instance", Environment = "dev" }
    EOT

  type = map(string)
}

##############
#  firewall  #
##############
variable "firewall_name" {
  description = "value of firewall name"
  type        = string
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
  description = "접근할 유저"
  type        = string
}

# variable "gce_ssh_pub_key_file" {
#   description = "공개키 파일 위치"
#   type        = string
# }

################
# health check #
################
variable "check_interval_sec" {
  description = "health check check_interval_sec"
  type        = number
}
variable "timeout_sec" {
  description = "health check timeout_sec"
  type        = number
}
variable "health_check_port" {
  description = "health check port"
  type        = number
}
variable "initial_delay_sec" {
  description = "initial delay for health check"
  type        = number
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

# variable "proxy_only_subnet_self_link" {
#   description = "value of proxy only subnet self link"
#   type        = string
# }

# Health Check 관련 변수
variable "alb_health_check_port" {
  description = "헬스 체크 포트"
  type        = number
}

variable "alb_check_interval_sec" {
  description = "헬스 체크 간격 (초)"
  type        = number
}

variable "alb_timeout_sec" {
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
