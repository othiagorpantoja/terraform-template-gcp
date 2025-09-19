output "cluster_name" {
  description = "Nome do cluster GKE"
  value       = google_container_cluster.primary.name
}

output "cluster_id" {
  description = "ID do cluster GKE"
  value       = google_container_cluster.primary.id
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificado CA do cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Localização do cluster"
  value       = google_container_cluster.primary.location
}

output "cluster_network" {
  description = "Rede do cluster"
  value       = google_container_cluster.primary.network
}

output "cluster_subnetwork" {
  description = "Subnet do cluster"
  value       = google_container_cluster.primary.subnetwork
}

output "node_pool_name" {
  description = "Nome do node pool principal"
  value       = google_container_node_pool.primary_nodes.name
}

output "node_pool_id" {
  description = "ID do node pool principal"
  value       = google_container_node_pool.primary_nodes.id
}

output "system_node_pool_name" {
  description = "Nome do node pool do sistema"
  value       = var.create_system_node_pool ? google_container_node_pool.system_nodes[0].name : null
}

output "system_node_pool_id" {
  description = "ID do node pool do sistema"
  value       = var.create_system_node_pool ? google_container_node_pool.system_nodes[0].id : null
}

output "workload_pool" {
  description = "Workload pool para Workload Identity"
  value       = "${var.project_id}.svc.id.goog"
}
