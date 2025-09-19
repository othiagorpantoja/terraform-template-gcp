output "project_id" {
  description = "ID do projeto GCP"
  value       = google_project.project.project_id
}

output "project_number" {
  description = "Número do projeto GCP"
  value       = google_project.project.number
}

output "project_name" {
  description = "Nome do projeto GCP"
  value       = google_project.project.name
}

output "project_org_id" {
  description = "ID da organização do projeto"
  value       = google_project.project.org_id
}

output "project_folder_id" {
  description = "ID da pasta do projeto"
  value       = google_project.project.folder_id
}

output "project_billing_account" {
  description = "Conta de billing do projeto"
  value       = google_project.project.billing_account
}

output "project_sa_email" {
  description = "Email da Service Account do projeto"
  value       = var.create_project_sa ? google_service_account.project_sa[0].email : null
}

output "project_sa_name" {
  description = "Nome da Service Account do projeto"
  value       = var.create_project_sa ? google_service_account.project_sa[0].name : null
}

output "enabled_apis" {
  description = "Lista de APIs habilitadas"
  value       = var.enabled_apis
}
