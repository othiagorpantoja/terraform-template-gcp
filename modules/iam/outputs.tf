output "gke_service_account_email" {
  description = "Email da Service Account do GKE"
  value       = google_service_account.gke.email
}

output "gke_service_account_name" {
  description = "Nome da Service Account do GKE"
  value       = google_service_account.gke.name
}

output "sql_service_account_email" {
  description = "Email da Service Account do Cloud SQL"
  value       = google_service_account.sql.email
}

output "sql_service_account_name" {
  description = "Nome da Service Account do Cloud SQL"
  value       = google_service_account.sql.name
}

output "app_service_account_email" {
  description = "Email da Service Account da aplicação"
  value       = google_service_account.app.email
}

output "app_service_account_name" {
  description = "Nome da Service Account da aplicação"
  value       = google_service_account.app.name
}

output "storage_service_account_email" {
  description = "Email da Service Account do Storage"
  value       = google_service_account.storage.email
}

output "storage_service_account_name" {
  description = "Nome da Service Account do Storage"
  value       = google_service_account.storage.name
}

output "cicd_service_account_email" {
  description = "Email da Service Account do CI/CD"
  value       = var.create_cicd_sa ? google_service_account.cicd[0].email : null
}

output "cicd_service_account_name" {
  description = "Nome da Service Account do CI/CD"
  value       = var.create_cicd_sa ? google_service_account.cicd[0].name : null
}

output "workload_identity_pool" {
  description = "Workload Identity Pool"
  value       = "${var.project_id}.svc.id.goog"
}
