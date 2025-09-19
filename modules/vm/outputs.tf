output "instance_name" {
  description = "Nome da instância"
  value       = var.create_static_ip ? google_compute_instance.with_static_ip[0].name : google_compute_instance.default.name
}

output "instance_id" {
  description = "ID da instância"
  value       = var.create_static_ip ? google_compute_instance.with_static_ip[0].id : google_compute_instance.default.id
}

output "instance_self_link" {
  description = "Self link da instância"
  value       = var.create_static_ip ? google_compute_instance.with_static_ip[0].self_link : google_compute_instance.default.self_link
}

output "instance_internal_ip" {
  description = "IP interno da instância"
  value       = var.create_static_ip ? google_compute_instance.with_static_ip[0].network_interface[0].network_ip : google_compute_instance.default.network_interface[0].network_ip
}

output "instance_external_ip" {
  description = "IP externo da instância"
  value       = var.create_static_ip ? google_compute_instance.with_static_ip[0].network_interface[0].access_config[0].nat_ip : google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "static_ip_address" {
  description = "Endereço do IP estático"
  value       = var.create_static_ip ? google_compute_address.static_ip[0].address : null
}

output "static_ip_name" {
  description = "Nome do IP estático"
  value       = var.create_static_ip ? google_compute_address.static_ip[0].name : null
}
