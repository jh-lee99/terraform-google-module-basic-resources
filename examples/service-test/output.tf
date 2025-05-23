###########
#   MIG   #
###########
output "mig_self_link" {
  value = module.mig.mig_self_link
}

output "instance_group_manager_name" {
  value = module.mig.instance_group_manager_name
}
output "instance_group_name" {
  value = module.mig.instance_group_name
}

output "instance_group_manager_id" {
  value = module.mig.instance_group_manager_id
}

output "instance_template_name" {
  value = module.mig.instance_template_name
}

output "instance_template_id" {
  value = module.mig.instance_template_id
}

#################
# Load Balancer #
#################
output "loadbalancer_http_ip" {
  value       = module.region_lb.loadbalancer_http_ip
  description = "Load Balancer의 HTTP IP 주소"
}

output "http_forwarding_rule_self_link" {
  value       = module.region_lb.http_forwarding_rule_self_link
  description = "HTTP Forwarding Rule의 self_link"
}

output "https_forwarding_rule_self_link" {
  value       = module.region_lb.https_forwarding_rule_self_link
  description = "HTTPS Forwarding Rule의 self_link (HTTPS가 활성화된 경우에만 제공)"
}

output "http_target_proxy_self_link" {
  value       = module.region_lb.http_target_proxy_self_link
  description = "HTTP Target Proxy의 self_link"
}

output "https_target_proxy_self_link" {
  value       = module.region_lb.https_target_proxy_self_link
  description = "HTTPS Target Proxy의 self_link (HTTPS가 활성화된 경우에만 제공)"
}

output "url_map_self_link" {
  value       = module.region_lb.url_map_self_link
  description = "URL Map의 self_link"
}

output "health_check_self_link" {
  value       = module.region_lb.health_check_self_link
  description = "Health Check의 self_link"
}

output "backend_service_self_link" {
  value       = module.region_lb.backend_service_self_link
  description = "Backend Service의 self_link"
}
