output "load_balancer_ip" {
  description = "Endereço IP do Load Balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "load_balancer_ip_name" {
  description = "Nome do endereço IP do Load Balancer"
  value       = google_compute_global_address.lb_ip.name
}

output "backend_service_name" {
  description = "Nome do backend service"
  value       = google_compute_backend_service.default.name
}

output "backend_service_id" {
  description = "ID do backend service"
  value       = google_compute_backend_service.default.id
}

output "url_map_name" {
  description = "Nome do URL map"
  value       = google_compute_url_map.default.name
}

output "url_map_id" {
  description = "ID do URL map"
  value       = google_compute_url_map.default.id
}

output "http_proxy_name" {
  description = "Nome do proxy HTTP"
  value       = google_compute_target_http_proxy.default.name
}

output "https_proxy_name" {
  description = "Nome do proxy HTTPS"
  value       = var.enable_https ? google_compute_target_https_proxy.default[0].name : null
}

output "http_forwarding_rule_name" {
  description = "Nome da regra de forwarding HTTP"
  value       = google_compute_global_forwarding_rule.http.name
}

output "https_forwarding_rule_name" {
  description = "Nome da regra de forwarding HTTPS"
  value       = var.enable_https ? google_compute_global_forwarding_rule.https[0].name : null
}

output "ssl_certificate_name" {
  description = "Nome do certificado SSL"
  value       = var.enable_https ? google_compute_managed_ssl_certificate.default[0].name : null
}

output "neg_name" {
  description = "Nome do Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.gke_neg.name
}

output "neg_id" {
  description = "ID do Network Endpoint Group"
  value       = google_compute_region_network_endpoint_group.gke_neg.id
}
