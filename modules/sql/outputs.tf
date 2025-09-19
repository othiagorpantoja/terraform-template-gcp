output "instance_name" {
  description = "Nome da instância Cloud SQL"
  value       = google_sql_database_instance.postgres.name
}

output "instance_id" {
  description = "ID da instância Cloud SQL"
  value       = google_sql_database_instance.postgres.id
}

output "instance_connection_name" {
  description = "Nome de conexão da instância"
  value       = google_sql_database_instance.postgres.connection_name
}

output "private_ip_address" {
  description = "Endereço IP privado da instância"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "public_ip_address" {
  description = "Endereço IP público da instância"
  value       = google_sql_database_instance.postgres.public_ip_address
}

output "database_name" {
  description = "Nome do banco de dados"
  value       = google_sql_database.default_db.name
}

output "database_user" {
  description = "Usuário do banco de dados"
  value       = google_sql_user.admin.name
}

output "password_secret_id" {
  description = "ID do secret da senha"
  value       = google_secret_manager_secret.db_password.id
}

output "password_secret_name" {
  description = "Nome do secret da senha"
  value       = google_secret_manager_secret.db_password.name
}

output "connection_string_secret_id" {
  description = "ID do secret da connection string"
  value       = google_secret_manager_secret.db_connection_string.id
}

output "connection_string_secret_name" {
  description = "Nome do secret da connection string"
  value       = google_secret_manager_secret.db_connection_string.name
}
