# modules/compute/docker-ubuntu/outputs.tf
output "instance_name" {
  value       = google_compute_instance.default.name
  description = "생성된 인스턴스 이름"
}

output "instance_id" {
  value       = google_compute_instance.default.id
  description = "생성된 인스턴스 ID"
}

output "instance_self_link" {
  value       = google_compute_instance.default.self_link
  description = "생성된 인스턴스 self link"
}

output "instance_ip" {
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
  description = "인스턴스 공인 IP 주소"
}
