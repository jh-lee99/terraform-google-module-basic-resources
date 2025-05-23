# outputs.tf
output "vpc_self_link" {
  description = "VPC 네트워크 self_link"
  value       = module.network.vpc_self_link
}

output "proxy_only_subnet_self_links" {
  description = "Public Subnet self_link 목록"
  value       = module.network.proxy_only_subnet_self_links
}

output "public_subnet_self_links" {
  description = "Public Subnet self_link 목록"
  value       = module.network.public_subnet_self_links
}

output "private_subnet_self_links" {
  description = "Private Subnet self_link 목록"
  value       = module.network.private_subnet_self_links
}

output "cloud_router_name" {
  description = "Cloud Router 이름"
  value       = var.create_nat ? module.network.cloud_router_name : null # create_nat가 false일 경우 null
}

output "cloud_nat_name" {
  description = "Cloud NAT 이름"
  value       = var.create_nat ? module.network.cloud_nat_name : null # create_nat가 false일 경우 null
}
