# Private Service Connection
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.environment}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${var.project_id}/global/networks/${var.network_name}"
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "projects/${var.project_id}/global/networks/${var.network_name}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Cloud SQL Instance
resource "google_sql_database_instance" "postgres" {
  name             = "${var.environment}-postgres"
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier                        = var.tier
    availability_type           = var.availability_type
    disk_type                  = var.disk_type
    disk_size                  = var.disk_size
    disk_autoresize            = true
    disk_autoresize_limit      = var.disk_autoresize_limit
    deletion_protection_enabled = var.deletion_protection

    # IP Configuration
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = "projects/${var.project_id}/global/networks/${var.network_name}"
      enable_private_path_for_google_cloud_services = true
    }

    # Backup Configuration
    backup_configuration {
      enabled                        = true
      start_time                     = var.backup_start_time
      location                       = var.backup_location
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }

    # Maintenance Window
    maintenance_window {
      day          = var.maintenance_day
      hour         = var.maintenance_hour
      update_track = var.maintenance_update_track
    }

    # Database Flags
    database_flags {
      name  = "log_statement"
      value = "all"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    # Insights Configuration
    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    # Performance Insights
    performance_insights_config {
      performance_insights_enabled = var.performance_insights_enabled
      performance_insights_retention_period = var.performance_insights_retention_period
    }
  }

  deletion_protection = var.deletion_protection

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Database
resource "google_sql_database" "default_db" {
  name     = var.database_name
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

# Database User
resource "google_sql_user" "admin" {
  name     = var.database_user
  instance = google_sql_database_instance.postgres.name
  password = var.database_password
  project  = var.project_id
}

# Secret Manager Secret for Database Password
resource "google_secret_manager_secret" "db_password" {
  name     = "${var.environment}-postgres-password"
  project  = var.project_id

  replication {
    automatic = true
  }

  labels = {
    environment = var.environment
    service     = "postgres"
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.database_password
}

# Secret Manager Secret for Connection String
resource "google_secret_manager_secret" "db_connection_string" {
  name     = "${var.environment}-postgres-connection-string"
  project  = var.project_id

  replication {
    automatic = true
  }

  labels = {
    environment = var.environment
    service     = "postgres"
  }
}

resource "google_secret_manager_secret_version" "db_connection_string_version" {
  secret      = google_secret_manager_secret.db_connection_string.id
  secret_data = "postgresql://${var.database_user}:${var.database_password}@${google_sql_database_instance.postgres.private_ip_address}:5432/${var.database_name}"
}
