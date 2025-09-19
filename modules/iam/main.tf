# GKE Node Service Account
resource "google_service_account" "gke" {
  account_id   = "${var.environment}-gke-sa"
  display_name = "GKE Node Service Account - ${var.environment}"
  description  = "Service Account para nodes do GKE"
  project      = var.project_id
}

# GKE Node IAM Roles
resource "google_project_iam_member" "gke_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/compute.viewer",
    "roles/container.nodeServiceAccount",
    "roles/storage.objectViewer"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke.email}"
}

# Cloud SQL Service Account
resource "google_service_account" "sql" {
  account_id   = "${var.environment}-sql-sa"
  display_name = "Cloud SQL Access SA - ${var.environment}"
  description  = "Service Account para acesso ao Cloud SQL"
  project      = var.project_id
}

# Cloud SQL IAM Roles
resource "google_project_iam_member" "sql_roles" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.sql.email}"
}

# Application Service Account (for Workload Identity)
resource "google_service_account" "app" {
  account_id   = "${var.environment}-app-sa"
  display_name = "App Workload Identity SA - ${var.environment}"
  description  = "Service Account para workloads da aplicação"
  project      = var.project_id
}

# Application IAM Roles
resource "google_project_iam_member" "app_roles" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.app.email}"
}

# Storage Service Account
resource "google_service_account" "storage" {
  account_id   = "${var.environment}-storage-sa"
  display_name = "Storage SA - ${var.environment}"
  description  = "Service Account para operações de storage"
  project      = var.project_id
}

# Storage IAM Roles
resource "google_project_iam_member" "storage_roles" {
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/storage.legacyBucketReader"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.storage.email}"
}

# CI/CD Service Account
resource "google_service_account" "cicd" {
  count = var.create_cicd_sa ? 1 : 0

  account_id   = "${var.environment}-cicd-sa"
  display_name = "CI/CD SA - ${var.environment}"
  description  = "Service Account para CI/CD pipelines"
  project      = var.project_id
}

# CI/CD IAM Roles
resource "google_project_iam_member" "cicd_roles" {
  count = var.create_cicd_sa ? 1 : 0

  for_each = toset([
    "roles/container.developer",
    "roles/storage.objectAdmin",
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client",
    "roles/iam.serviceAccountUser"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cicd[0].email}"
}

# Workload Identity Bindings
resource "google_service_account_iam_binding" "gke_workload_identity" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]"
  ]
}

# Custom IAM Roles (if needed)
resource "google_project_iam_custom_role" "custom_roles" {
  for_each = var.custom_roles

  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  project     = var.project_id
}

# IAM Policy Bindings for Custom Roles
resource "google_project_iam_member" "custom_role_bindings" {
  for_each = var.custom_role_bindings

  project = var.project_id
  role    = "projects/${var.project_id}/roles/${each.key}"
  member  = each.value.member
}
