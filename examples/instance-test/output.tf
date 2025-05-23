# modules/compute/docker-ubuntu/outputs.tf
output "instance_name" {
  value       = module.vm.instance_name
  description = "생성된 인스턴스 이름"
}

output "instance_id" {
  value       = module.vm.instance_id
  description = "생성된 인스턴스 ID"
}

output "instance_self_link" {
  value       = module.vm.instance_self_link
  description = "생성된 인스턴스 self link"
}

output "instance_ip" {
  value       = module.vm.instance_ip
  description = "인스턴스 공인 IP 주소"
}
