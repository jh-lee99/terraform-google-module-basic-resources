# outputs.tf
output "vpc_self_link" {
  description = "VPC 네트워크 self_link"
  value       = google_compute_network.vpc.self_link
}

output "proxy_only_subnet_self_links" {
  description = "Public Subnet self_link 목록"
  value       = google_compute_subnetwork.proxy_only_subnet.self_link
}

output "public_subnet_self_links" {
  description = "Public Subnet self_link 목록"
  value       = google_compute_subnetwork.public[*].self_link
}

output "private_subnet_self_links" {
  description = "Private Subnet self_link 목록"
  value       = google_compute_subnetwork.private[*].self_link
}

output "cloud_router_name" {
  description = "Cloud Router 이름"
  value       = var.create_nat ? google_compute_router.router[0].name : null # create_nat가 false일 경우 null
}

output "cloud_nat_name" {
  description = "Cloud NAT 이름"
  value       = var.create_nat ? google_compute_router_nat.nat[0].name : null # create_nat가 false일 경우 null
}
