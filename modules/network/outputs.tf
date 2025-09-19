output "vpc_name" {
  description = "Nome da VPC"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {
  description = "ID da VPC"
  value       = google_compute_network.vpc.id
}

output "private_subnet_name" {
  description = "Nome da subnet privada"
  value       = google_compute_subnetwork.private.name
}

output "private_subnet_id" {
  description = "ID da subnet privada"
  value       = google_compute_subnetwork.private.id
}

output "public_subnet_name" {
  description = "Nome da subnet pública"
  value       = google_compute_subnetwork.public.name
}

output "public_subnet_id" {
  description = "ID da subnet pública"
  value       = google_compute_subnetwork.public.id
}

output "pods_range_name" {
  description = "Nome do range de pods"
  value       = google_compute_subnetwork.private.secondary_ip_range[0].range_name
}

output "services_range_name" {
  description = "Nome do range de serviços"
  value       = google_compute_subnetwork.private.secondary_ip_range[1].range_name
}

output "nat_router_name" {
  description = "Nome do router NAT"
  value       = google_compute_router.nat_router.name
}

output "lb_ip_address" {
  description = "Endereço IP do Load Balancer"
  value       = google_compute_global_address.lb_ip.address
}
