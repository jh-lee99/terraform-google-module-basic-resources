output "mig_self_link" {
  value = google_compute_region_instance_group_manager.default.self_link
}

output "instance_group_manager_name" {
  value = google_compute_region_instance_group_manager.default.name
}
output "instance_group_name" {
  value = google_compute_region_instance_group_manager.default.instance_group
}

output "instance_group_manager_id" {
  value = google_compute_region_instance_group_manager.default.id
}

output "instance_template_name" {
  value = google_compute_instance_template.default.name
}

output "instance_template_id" {
  value = google_compute_instance_template.default.id
}
