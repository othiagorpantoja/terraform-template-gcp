output "project_id" {
  description = "ID do projeto GCP"
  value       = var.create_project ? module.project[0].project_id : var.project_id
}

output "gke_cluster_name" {
  description = "Nome do cluster GKE"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "Endpoint do cluster GKE"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "Certificado CA do cluster GKE"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "sql_instance_name" {
  description = "Nome da instância Cloud SQL"
  value       = module.sql.instance_name
}

output "sql_private_ip" {
  description = "IP privado da instância Cloud SQL"
  value       = module.sql.private_ip_address
}

output "load_balancer_ip" {
  description = "IP do Load Balancer"
  value       = module.loadbalancer.load_balancer_ip
}

output "bastion_external_ip" {
  description = "IP externo do bastion host"
  value       = module.vm.instance_external_ip
}

output "private_bucket_name" {
  description = "Nome do bucket privado"
  value       = module.storage.private_bucket_name
}

output "public_bucket_name" {
  description = "Nome do bucket público"
  value       = module.storage.public_bucket_name
}

output "backup_bucket_name" {
  description = "Nome do bucket de backup"
  value       = module.storage.backup_bucket_name
}

output "logs_bucket_name" {
  description = "Nome do bucket de logs"
  value       = module.storage.logs_bucket_name
}

output "vpc_name" {
  description = "Nome da VPC"
  value       = module.network.vpc_name
}

output "private_subnet_name" {
  description = "Nome da subnet privada"
  value       = module.network.private_subnet_name
}

output "public_subnet_name" {
  description = "Nome da subnet pública"
  value       = module.network.public_subnet_name
}

output "gke_service_account_email" {
  description = "Email da Service Account do GKE"
  value       = module.iam.gke_service_account_email
}

output "app_service_account_email" {
  description = "Email da Service Account da aplicação"
  value       = module.iam.app_service_account_email
}

output "sql_password_secret_name" {
  description = "Nome do secret da senha do SQL"
  value       = module.sql.password_secret_name
}

output "connection_string_secret_name" {
  description = "Nome do secret da connection string"
  value       = module.sql.connection_string_secret_name
}
