output "loadbalancer_http_ip" {
  value       = google_compute_address.load_balancer_ip.address
  description = "Load Balancer의 HTTP IP 주소"
}

output "http_forwarding_rule_self_link" {
  value       = google_compute_forwarding_rule.http_default.self_link
  description = "HTTP Forwarding Rule의 self_link"
}

output "https_forwarding_rule_self_link" {
  value       = var.create_https ? google_compute_forwarding_rule.https_default[0].self_link : null
  description = "HTTPS Forwarding Rule의 self_link (HTTPS가 활성화된 경우에만 제공)"
}

output "http_target_proxy_self_link" {
  value       = google_compute_region_target_http_proxy.http_default.self_link
  description = "HTTP Target Proxy의 self_link"
}

output "https_target_proxy_self_link" {
  value       = var.create_https ? google_compute_region_target_https_proxy.https_default[0].self_link : null
  description = "HTTPS Target Proxy의 self_link (HTTPS가 활성화된 경우에만 제공)"
}

output "url_map_self_link" {
  value       = google_compute_region_url_map.default.self_link
  description = "URL Map의 self_link"
}

output "health_check_self_link" {
  value       = google_compute_region_health_check.default.self_link
  description = "Health Check의 self_link"
}

output "backend_service_self_link" {
  value       = google_compute_region_backend_service.default.self_link
  description = "Backend Service의 self_link"
}
