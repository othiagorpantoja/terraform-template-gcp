output "private_bucket_name" {
  description = "Nome do bucket privado"
  value       = google_storage_bucket.private.name
}

output "private_bucket_url" {
  description = "URL do bucket privado"
  value       = google_storage_bucket.private.url
}

output "public_bucket_name" {
  description = "Nome do bucket público"
  value       = google_storage_bucket.public.name
}

output "public_bucket_url" {
  description = "URL do bucket público"
  value       = google_storage_bucket.public.url
}

output "backup_bucket_name" {
  description = "Nome do bucket de backup"
  value       = var.create_backup_bucket ? google_storage_bucket.backup[0].name : null
}

output "backup_bucket_url" {
  description = "URL do bucket de backup"
  value       = var.create_backup_bucket ? google_storage_bucket.backup[0].url : null
}

output "logs_bucket_name" {
  description = "Nome do bucket de logs"
  value       = var.create_logs_bucket ? google_storage_bucket.logs[0].name : null
}

output "logs_bucket_url" {
  description = "URL do bucket de logs"
  value       = var.create_logs_bucket ? google_storage_bucket.logs[0].url : null
}
